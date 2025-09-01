// // import 'package:flutter/material.dart';

// // class HomePage extends StatefulWidget {
// //   @override
// //   _HomePageState createState() => _HomePageState();
// // }

// // class _HomePageState extends State<HomePage> {
// //   final TextEditingController _nameController = TextEditingController();
// //   final TextEditingController _phoneController = TextEditingController();
// //   String? _selectedBloodGroup;

// //   final List<String> _bloodGroups = [
// //     'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
// //   ];

// //   void _saveData() {
// //     String name = _nameController.text.trim();
// //     String phone = _phoneController.text.trim();

// //     if (name.isEmpty || phone.isEmpty || _selectedBloodGroup == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Please fill all fields!')),
// //       );
// //       return;
// //     }

// //     if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Enter a valid phone number!')),
// //       );
// //       return;
// //     }

// //     // Save logic here
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('Saved Successfully!')),
// //     );

// //     // Clear fields after saving
// //     _nameController.clear();
// //     _phoneController.clear();
// //     setState(() {
// //       _selectedBloodGroup = null;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.red,
// //         title: Text('Home Page',style: TextStyle(color: Colors.white),
// //         ),
// //         centerTitle: true,
// //         ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             TextField(
// //               controller: _nameController,
// //               decoration: InputDecoration(
// //                 labelText: 'Name',
// //                 border: OutlineInputBorder(),
// //               ),
// //             ),
// //             SizedBox(height: 10),
// //             TextField(
// //               controller: _phoneController,
// //               keyboardType: TextInputType.phone,
// //               decoration: InputDecoration(
// //                 labelText: 'Phone Number',
// //                 border: OutlineInputBorder(),
// //               ),
// //             ),
// //             SizedBox(height: 10),
// //             DropdownButtonFormField<String>(
// //               decoration: InputDecoration(
// //                 labelText: 'Select Blood Group',
// //                 border: OutlineInputBorder(),
// //               ),
// //               value: _selectedBloodGroup,
// //               items: _bloodGroups.map((String bg) {
// //                 return DropdownMenuItem(
// //                   value: bg,
// //                   child: Text(bg),
// //                 );
// //               }).toList(),
// //               onChanged: (String? newValue) {
// //                 setState(() {
// //                   _selectedBloodGroup = newValue;
// //                 });
// //               },
// //             ),
// //             SizedBox(height: 20),
// //             Center(
// //               child: ElevatedButton(
// //                 onPressed: _saveData,
// //                 child: Text('Save'),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'detail.dart'; // Import DetailsPage

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   String? _selectedBloodGroup;

//   final List<String> _bloodGroups = [
//     'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
//   ];

//   void _saveData() async {
//     try {
//       await FirebaseFirestore.instance.collection('users').add({
//         'name': _nameController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'bloodGroup': _selectedBloodGroup,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Saved Successfully!')),
//       );

//       // Clear fields after saving
//       _nameController.clear();
//       _phoneController.clear();
//       setState(() {
//         _selectedBloodGroup = null;
//       });

//       // Navigate to DetailsPage to display saved data
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => DetailsPage()),
//       );
//     } catch (e) {
//       print("Error saving data: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving data!')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.red,
//         title: Text('Home Page', style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: _phoneController,
//               keyboardType: TextInputType.phone,
//               decoration: InputDecoration(
//                 labelText: 'Phone Number',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//             DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 labelText: 'Select Blood Group',
//                 border: OutlineInputBorder(),
//               ),
//               value: _selectedBloodGroup,
//               items: _bloodGroups.map((String bg) {
//                 return DropdownMenuItem(
//                   value: bg,
//                   child: Text(bg),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedBloodGroup = newValue;
//                 });
//               },
//             ),
//             SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: _saveData,
//                 child: Text('Save'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
