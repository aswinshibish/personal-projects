// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: ContactApp(),
//   ));
// }

// class ContactApp extends StatefulWidget {
//   @override
//   _ContactAppState createState() => _ContactAppState();
// }

// class _ContactAppState extends State<ContactApp> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   String? _editingId;

//   Future<void> _saveContact() async {
//     if (_formKey.currentState!.validate()) {
//       final contact = {
//         'name': _nameController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'timestamp': FieldValue.serverTimestamp(),
//       };

//       if (_editingId == null) {
//         await FirebaseFirestore.instance.collection('contacts').add(contact);
//       } else {
//         await FirebaseFirestore.instance
//             .collection('contacts')
//             .doc(_editingId)
//             .update(contact);
//         _editingId = null;
//       }

//       _nameController.clear();
//       _phoneController.clear();
//       setState(() {});
//     }
//   }

//   void _editContact(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     _nameController.text = data['name'] ?? '';
//     _phoneController.text = data['phone'] ?? '';
//     setState(() {
//       _editingId = doc.id;
//     });
//   }

//   Future<void> _deleteContact(String id) async {
//     await FirebaseFirestore.instance.collection('contacts').doc(id).delete();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Contact App'),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: InputDecoration(labelText: 'Name'),
//                     validator: (val) {
//                       if (val == null || val.trim().isEmpty) {
//                         return 'Name is required';
//                       }
//                       return null;
//                     },
//                   ),
//                   TextFormField(
//                     controller: _phoneController,
//                     decoration: InputDecoration(labelText: 'Phone Number'),
//                     keyboardType: TextInputType.phone,
//                     validator: (val) {
//                       if (val == null || val.trim().isEmpty) {
//                         return 'Phone number is required';
//                       } else if (!RegExp(r'^\d{10}$').hasMatch(val)) {
//                         return 'Enter a valid 10-digit number';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: _saveContact,
//                     child: Text(_editingId == null ? 'Add Contact' : 'Update Contact'),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('contacts')
//                     .orderBy('timestamp', descending: true)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

//                   final docs = snapshot.data!.docs;

//                   if (docs.isEmpty) {
//                     return Center(child: Text('No contacts found.'));
//                   }

//                   return ListView.builder(
//                     itemCount: docs.length,
//                     itemBuilder: (context, index) {
//                       final doc = docs[index];
//                       final data = doc.data() as Map<String, dynamic>;

//                       return Card(
//                         child: ListTile(
//                           title: Text(data['name'] ?? ''),
//                           subtitle: Text(data['phone'] ?? ''),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.edit, color: Colors.blue),
//                                 onPressed: () => _editContact(doc),
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () => _deleteContact(doc.id),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ContactApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: Text(
            'Contact Diary',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
class ContactApp extends StatefulWidget {
  @override
  _ContactAppState createState() => _ContactAppState();
}

class _ContactAppState extends State<ContactApp> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _editingId;

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      final contact = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (_editingId == null) {
        await FirebaseFirestore.instance.collection('contacts').add(contact);
      } else {
        await FirebaseFirestore.instance
            .collection('contacts')
            .doc(_editingId)
            .update(contact);
        _editingId = null;
      }

      _nameController.clear();
      _phoneController.clear();
      setState(() {});
    }
  }

  void _editContact(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    _nameController.text = data['name'] ?? '';
    _phoneController.text = data['phone'] ?? '';
    setState(() {
      _editingId = doc.id;
    });
  }

  Future<void> _deleteContact(String id) async {
    await FirebaseFirestore.instance.collection('contacts').doc(id).delete();
  }

  Future<void> _callNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Could not launch dialer")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact App'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Phone number is required';
                          } else if (!RegExp(r'^\d{10}$').hasMatch(val)) {
                            return 'Enter a valid 10-digit number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _saveContact,
                        icon: Icon(_editingId == null ? Icons.add : Icons.save),
                        label: Text(
                            _editingId == null ? 'Add Contact' : 'Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                       
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('contacts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(child: Text('No contacts found.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(data['name'] ?? ''),
                          subtitle: Text(data['phone'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.call, color: Colors.green),
                                onPressed: () =>
                                    _callNumber(data['phone'] ?? ''),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editContact(doc),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteContact(doc.id),
                              ),
                            ],
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
    );
  }
}
