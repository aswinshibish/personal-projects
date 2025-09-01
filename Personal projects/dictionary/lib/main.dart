
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(DictionaryApp());
}

class DictionaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DictionaryHomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Text(
              "Dictionary App",
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DictionaryHomePage extends StatefulWidget {
  @override
  _DictionaryHomePageState createState() => _DictionaryHomePageState();
}

class _DictionaryHomePageState extends State<DictionaryHomePage> {
  final TextEditingController _controller = TextEditingController();
  String? _searchedWord;
  String? _definition;
  bool _isLoading = false;

  // Set to track deleted doc IDs (for local hiding only)
  Set<String> _deletedIds = {};

  Future<void> _searchWord() async {
    final word = _controller.text.trim();
    if (word.isEmpty) return;

    setState(() {
      _isLoading = true;
      _definition = null;
    });

    try {
      final definition = await _getDefinitionFromAPI(word);
      setState(() {
        _searchedWord = word;
        _definition = definition;
      });
    } catch (e) {
      setState(() {
        _definition = 'Error: Unable to fetch definition.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getDefinitionFromAPI(String word) async {
    final url =
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final meanings = data[0]['meanings'] as List;
      final definitions = meanings[0]['definitions'] as List;
      return definitions[0]['definition'];
    } else {
      throw Exception('Failed to fetch definition');
    }
  }

  Future<void> _saveWord() async {
    if (_searchedWord != null && _definition != null) {
      try {
        await FirebaseFirestore.instance.collection('saved_words').add({
          'word': _searchedWord,
          'meaning': _definition,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved successfully!')),
        );
        _clearFields();
      } catch (e) {
        print('Error saving word: $e');
      }
    }
  }

  void _clearFields() {
    setState(() {
      _controller.clear();
      _searchedWord = null;
      _definition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Dictionary',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    labelText: 'Enter a word',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onSubmitted: (_) => _searchWord(),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _searchWord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Search'),
                ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                if (_definition != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Definition:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        _definition!,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _saveWord,
                        child: Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                Divider(color: Colors.white),
                Text(
                  'Saved Words',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('saved_words')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child:
                                CircularProgressIndicator(color: Colors.white));
                      }

                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Error loading saved words.',
                                style: TextStyle(color: Colors.white)));
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return Center(
                            child: Text('No words saved yet.',
                                style: TextStyle(color: Colors.white)));
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];

                          // Skip if deleted from local view
                          if (_deletedIds.contains(doc.id)) return SizedBox();

                          final data = doc.data() as Map<String, dynamic>;
                          final word = data['word'] ?? '';
                          final meaning = data['meaning'] ?? '';

                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                            margin: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 4),
                            child: ListTile(
                              title: Text(
                                word,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple),
                              ),
                              subtitle: Text(meaning),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _deletedIds.add(doc.id); // Hide locally
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Deleted "$word" from device')),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
