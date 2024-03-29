import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_bite/user_screens/dynamic_screen_functions.dart';
import 'package:home_bite/user_screens/my_cart_screen.dart';

class SearchScreen extends StatelessWidget {
  final String searchTerm;

  const SearchScreen({Key? key, required this.searchTerm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyCartPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Go to Cart'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Search Results for "$searchTerm":',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('menu')
                    .where('Name', isEqualTo: searchTerm)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No results found.'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot item = snapshot.data!.docs[index];
                      Map<String, dynamic> itemDetails =
                          item.data() as Map<String, dynamic>;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('cooks')
                            .doc(itemDetails['cook-id'])
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> cookSnapshot) {
                          if (cookSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(); // Show nothing while waiting
                          }

                          if (cookSnapshot.hasError) {
                            return Text('Error: ${cookSnapshot.error}');
                          }

                          if (!cookSnapshot.hasData) {
                            return SizedBox(); // Show nothing if data not available
                          }

                          Map<String, dynamic>? cookData =
                              cookSnapshot.data!.data() as Map<String, dynamic>?;

                          return SellerEachItemListElement(
                            cookName: cookData?['name'] ?? "",
                            image: itemDetails['image'],
                            location: cookData?['Location'] ?? "",
                            name: itemDetails['Name'],
                            price: itemDetails['Price'],
                            rating: itemDetails['Rating'],
                            itemid: itemDetails['item-id'],
                            isVeg: itemDetails["isVeg"]?? true,
                          );
                        },
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
