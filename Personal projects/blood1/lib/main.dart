
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BloodDonationApp()),
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
      backgroundColor: Colors.red[900],
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Text(
            'Blood Donation',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class BloodDonationApp extends StatefulWidget {
  const BloodDonationApp({super.key});

  @override
  State<BloodDonationApp> createState() => _BloodDonationAppState();
}

class _BloodDonationAppState extends State<BloodDonationApp> {
  final CollectionReference donors = FirebaseFirestore.instance.collection('donors');

  List<DocumentSnapshot> localDonors = [];

  @override
  void initState() {
    super.initState();
    donors.snapshots().listen((snapshot) {
      setState(() {
        localDonors = snapshot.docs;
      });
    });
  }

  void showEditDialog(String docId, Map<String, dynamic> data) {
    final TextEditingController nameController = TextEditingController(text: data['name']);
    final TextEditingController contactController = TextEditingController(text: data['contact']);
    String selectedBloodGroup = data['bloodGroup'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Donor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Contact'),
                maxLength: 10,
              ),
              DropdownButton<String>(
                value: selectedBloodGroup,
                isExpanded: true,
                items: <String>['A+', 'B+', 'O+', 'AB+', 'A-', 'AB-', 'B-', 'O-']
                    .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedBloodGroup = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
              onPressed: () async {
                await donors.doc(docId).update({
                  'name': nameController.text.trim(),
                  'contact': contactController.text.trim(),
                  'bloodGroup': selectedBloodGroup,
                });
                Navigator.pop(context);
              },
              child: Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void showAddDonorDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController contactController = TextEditingController();
    String? selectedBloodGroup;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Donor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Contact'),
                maxLength: 10,
              ),
              DropdownButton<String>(
                value: selectedBloodGroup,
                hint: Text('Select Blood Group'),
                isExpanded: true,
                items: <String>['A+', 'B+', 'O+', 'AB+', 'A-', 'AB-', 'B-', 'O-']
                    .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedBloodGroup = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty &&
                    RegExp(r'^\d{10}$').hasMatch(contactController.text.trim()) &&
                    selectedBloodGroup != null) {
                  await donors.add({
                    'name': nameController.text.trim(),
                    'contact': contactController.text.trim(),
                    'bloodGroup': selectedBloodGroup,
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: const Text("Donation",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white70,
        child: Icon(Icons.add, color: Colors.red[900]),
        onPressed: showAddDonorDialog,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: localDonors.isEmpty
          ? Center(child: Text('No donors added yet.'))
          : ListView.builder(
              itemCount: localDonors.length,
              itemBuilder: (context, index) {
                final doc = localDonors[index];
                final data = doc.data() as Map<String, dynamic>;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                      child: Text(data['bloodGroup'], style: TextStyle(fontSize: 18)),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['name'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        Text(data['contact']),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showEditDialog(doc.id, data),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              localDonors.removeAt(index); // only remove from local list
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
