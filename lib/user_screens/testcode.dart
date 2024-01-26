// // StreamBuilder<QuerySnapshot>(
// //                   stream: FirebaseFirestore.instance
// //                       .collection('orders')
// //                       .where('user-id', isEqualTo: 'dI98g5eWiNVce6U3zyJqz90ySPp1')
// //                       .snapshots(),
// //                   builder: (context, snapshot) {
// //                     if (snapshot.connectionState == ConnectionState.active) {
// //                       if (snapshot.hasData && snapshot.data != null) {
// //                         if (snapshot.data!.docs.isEmpty) {
// //                           return const Center(
// //                             child: Text('No Orders available'),
// //                           );
// //                         }
// //                         return ListView.builder(
// //                           padding: EdgeInsets.zero,
// //                           itemCount: snapshot.data!.docs.length,
// //                           itemBuilder: (context, index) {
// //                             Map<String, dynamic> orderMap = snapshot.data!.docs[index].data() as Map<String, dynamic>;
// //                             List<dynamic>? itemList = orderMap['items'];

// //                             if (itemList == null || itemList.isEmpty) {
// //                               return const SizedBox.shrink(); // or any other placeholder widget
// //                             }

// //                             for (Map<String, dynamic>? elements in itemList) {
// //                               if (elements == null) {
// //                                 continue; // Skip null elements
// //                               }

// //                               String? itemId = elements['item-id'];
// //                               if (itemId == null) {
// //                                 continue; // Skip null item ids
// //                               }

// //                               return FutureBuilder(
// //                                 future: FirebaseFirestore.instance.collection('menu').doc(itemId).get(),
// //                                 builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
// //                                   if (snapshot.connectionState == ConnectionState.done) {
// //                                     if (!snapshot.hasData || snapshot.data == null) {
// //                                       return CartItemDesignPart2(
// //                                         cookName: 'default',
// //                                         imageUrl: 'default',
// //                                         itemId: 'def',
// //                                         name: 'default',
// //                                         price: 8,
// //                                         quantity: elements['quantity'] ?? 0,
// //                                       );
// //                                     }

// //                                     Map<String, dynamic>? menuItems = snapshot.data?.data() as Map<String, dynamic>?;

// //                                     return CartItemDesignPart2(
// //                                       cookName: 'not required',
// //                                       imageUrl: menuItems?['image'] ?? 'default',
// //                                       itemId: 'notreq',
// //                                       name: menuItems?['Name'] ?? 'default',
// //                                       price: menuItems?['Price'] ?? 8,
// //                                       quantity: elements['quantity'] ?? 0,
// //                                     );
// //                                   } else {
// //                                     // Handle other connection states if needed
// //                                     return CircularProgressIndicator(); // Placeholder widget
// //                                   }
// //                                 },
// //                               );
// //                             }

// //                             // Return a default widget if itemList is empty or null
// //                             return const SizedBox.shrink(); // or any other placeholder widget
// //                           },
// //                         );
// //                       }
// //                     }
// //                     return Container();
// //                   },
// //                 ),




// import 'package:cloud_firestore/cloud_firestore.dart';

// // Function to copy a document from source collection to destination collection
// Future<void> copyDocument(String sourceCollection, String destinationCollection, String documentId) async {
//   // Reference to the source document
//   DocumentReference sourceDocumentRef = FirebaseFirestore.instance.collection(sourceCollection).doc(documentId);

//   // Get the source document snapshot
//   DocumentSnapshot sourceSnapshot = await sourceDocumentRef.get();

//   // Check if the source document exists
//   if (sourceSnapshot.exists) {
//     // Data from the source document
//     Map<String, dynamic> documentData = sourceSnapshot.data() as Map<String, dynamic>;

//     // Reference to the destination document
//     DocumentReference destinationDocumentRef = FirebaseFirestore.instance.collection(destinationCollection).doc();

//     // Set data in the destination document
//     await destinationDocumentRef.set(documentData);
//   } else {
//     // Handle if the source document does not exist
//     print('Source document does not exist');
//   }
// }

// // Example usage
// void main() {
//   String sourceCollection = 'source_collection';
//   String destinationCollection = 'destination_collection';
//   String documentId = 'your_document_id';

//   copyDocument(sourceCollection, destinationCollection, documentId);
// }



// import 'package:cloud_firestore/cloud_firestore.dart';

// // Function to copy a document from source collection to destination collection with the same document ID
// Future<void> copyDocumentWithSameId(String sourceCollection, String destinationCollection, String documentId) async {
//   // Reference to the source document
//   DocumentReference sourceDocumentRef = FirebaseFirestore.instance.collection(sourceCollection).doc(documentId);

//   // Get the source document snapshot
//   DocumentSnapshot sourceSnapshot = await sourceDocumentRef.get();

//   // Check if the source document exists
//   if (sourceSnapshot.exists) {
//     // Data from the source document
//     Map<String, dynamic> documentData = sourceSnapshot.data() as Map<String, dynamic>;

//     // Reference to the destination document with the same ID
//     DocumentReference destinationDocumentRef = FirebaseFirestore.instance.collection(destinationCollection).doc(documentId);

//     // Set data in the destination document with the same ID
//     await destinationDocumentRef.set(documentData);
//   } else {
//     // Handle if the source document does not exist
//     print('Source document does not exist');
//   }
// }

// // Example usage
// void main() {
//   String sourceCollection = 'source_collection';
//   String destinationCollection = 'destination_collection';
//   String documentId = 'your_document_id';

//   copyDocumentWithSameId(sourceCollection, destinationCollection, documentId);
// }
