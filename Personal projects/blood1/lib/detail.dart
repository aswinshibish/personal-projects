
// // import 'package:blood09/home.dart';
// // import 'package:flutter/material.dart';
// // // Import the HomePage file

// // class DetailsPage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.red,
// //         title: Text('Details Page',
// //         style: TextStyle(color: Colors.white),
// //         ),
// //         centerTitle: true,
// //         actions: [
// //           FloatingActionButton(
// //             mini: true, // Makes it smaller to fit in the AppBar
// //             onPressed: () {
// //               Navigator.push(
// //                 context,
// //                 MaterialPageRoute(builder: (context) => HomePage()),
// //               );
// //             },
// //             child: Icon(Icons.add),
// //             foregroundColor: Colors.white,
// //             backgroundColor: Colors.red,
// //             elevation: 15, // Removes extra shadow
// //           ),
// //         ],
// //       ),
// //       body: Center(
// //         child: Text(
// //           'Welcome to the Details Page!',
// //           style: TextStyle(fontSize: 18),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'home.dart'; // Import HomePage

// class DetailsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.red,
//         title: Text(
//           'Details Page',
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => HomePage()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             .orderBy('timestamp', descending: true) // Show latest first
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No data available'));
//           }

//           var users = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: users.length,
//             itemBuilder: (context, index) {
//               var user = users[index].data() as Map<String, dynamic>;

//               return Card(
//                 margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 child: ListTile(
//                   title: Text(user['name'] ?? 'No Name'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Phone: ${user['phone'] ?? 'No Phone'}'),
//                       Text('Blood Group: ${user['bloodGroup'] ?? 'N/A'}'),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
