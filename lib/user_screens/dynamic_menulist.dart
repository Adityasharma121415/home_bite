import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_bite/user_screens/dynamic_screen_functions.dart';
import 'package:home_bite/user_screens/my_cart_screen.dart';

class DynamicMenuPage extends StatefulWidget {
  const DynamicMenuPage(
      {required this.categoryName,
      super.key,
      required this.categoryid,
      required this.type});
  final String categoryName;
  final String categoryid;
  final String type;

  @override
  State<DynamicMenuPage> createState() {
    return _DynamicMenuPageState();
  }
}

class _DynamicMenuPageState extends State<DynamicMenuPage> {
  @override
  Widget build(context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyCartPage(),
            ),
          );
          setState(() {});
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: Color.fromARGB(255, 8, 92, 5),
        child: const Icon(Icons.shopping_cart_checkout),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 150,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color.fromARGB(255, 214, 0, 0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      // SizedBox(
                      //   child: ElevatedButton.icon(
                      //     style: const ButtonStyle(
                      //       shape: MaterialStatePropertyAll(
                      //         RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(15),
                      //           ),
                      //         ),
                      //       ),
                      //       shadowColor: MaterialStatePropertyAll(Colors.white),
                      //     ),
                      //     onPressed: () async {
                      //       await Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (context) => const MyCartPage(),
                      //         ),
                      //       );
                      //       setState(() {

                      //       });
                      //     },
                      //     icon: const Icon(
                      //       Icons.shopping_cart,
                      //     ),
                      //     label: const Text('Go to Cart'),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    widget.categoryName,
                    style: GoogleFonts.salsa(
                        textStyle: const TextStyle(fontSize: 38)),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("menu")
                      .where(widget.type, isEqualTo: widget.categoryid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData && snapshot.data != null) {
                        if (snapshot.data!.docs.isEmpty) {
                          // Display a message or widget when no items are found
                          return const Center(
                            child: Text("No items found in this category."),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> userMap =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('cooks')
                                  .doc(userMap['cook-id'])
                                  .get(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot>
                                      cookSnapshot) {
                                if (cookSnapshot.connectionState ==
                                    ConnectionState.done) {
                                  Map<String, dynamic>? cookData =
                                      cookSnapshot.data?.data()
                                          as Map<String, dynamic>?;

                                  return SellerEachItemListElement(
                                    cookName: cookData!["name"],
                                    image: userMap["image"],
                                    location: cookData["Location"],
                                    name: userMap["Name"],
                                    price: userMap["Price"],
                                    rating: userMap["Rating"],
                                    itemid: userMap["item-id"],
                                    isVeg: userMap["isVeg"] ?? true,
                                  );
                                } else {
                                  return SellerEachItemListElement(
                                    cookName: "",
                                    image: userMap["image"],
                                    location: "",
                                    name: userMap["Name"],
                                    price: userMap["Price"],
                                    rating: userMap["Rating"],
                                    itemid: userMap["item-id"],
                                    isVeg: userMap["isVeg"] ?? true,
                                  );
                                }
                              },
                            );
                          },
                        );
                      } else {
                        return const Text('No Data found');
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
