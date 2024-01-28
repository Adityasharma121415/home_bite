import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_bite/seller_screens/seller_add_item_tomenu.dart';
import 'package:home_bite/seller_screens/seller_dynamic_menu_functions.dart';

class SellerDynamicMenuPage extends StatefulWidget {
  const SellerDynamicMenuPage({
    required this.categoryName,
    super.key,
    required this.categoryid,
  });
  final String categoryName;
  final String categoryid;

  @override
  State<SellerDynamicMenuPage> createState() {
    return _SellerDynamicMenuPageState();
  }
}

class _SellerDynamicMenuPageState extends State<SellerDynamicMenuPage> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
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
                        SizedBox(
                          child: ElevatedButton.icon(
                            style: const ButtonStyle(
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                              ),
                              shadowColor:
                                  MaterialStatePropertyAll(Colors.white),
                            ),
                            onPressed: () {
                              addNewItem(context, widget.categoryid,
                                  user!.uid); //to be replaced by actual cookid
                            },
                            icon: const Icon(
                              Icons.add_box_outlined,
                            ),
                            label: const Text('Add Item'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Text(
                      widget.categoryName,
                      style: GoogleFonts.salsa(
                        textStyle: const TextStyle(fontSize: 38),
                      ),
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
                        .where('category-id', isEqualTo: widget.categoryid)
                        .where('cook-id',
                            isEqualTo:
                                user!.uid) //tobe replaced by actual cook id
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData && snapshot.data != null) {
                          if (snapshot.data!.docs.isEmpty) {
                            // Display a message or widget when no items are found
                            return const Center(
                              child: Text(
                                  "You don't have any items in this category."),
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
      ),
    );
  }
}
