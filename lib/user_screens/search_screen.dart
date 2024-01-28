import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_bite/user_screens/dynamic_screen_functions.dart';
import 'package:home_bite/user_screens/my_cart_screen.dart';

class SearchScreen extends StatefulWidget {
  final String searchTerm;

  const SearchScreen({super.key, required this.searchTerm});

  @override
  State<SearchScreen> createState(){
    return _SearchScreenState();
  }
  
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    // Call the method to get search results when the widget is created
    getSearchResults();
  }

  void getSearchResults() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('menu')
          .where('Name', isEqualTo: widget.searchTerm)
          .get();

      setState(() {
        // Extract item details from the query snapshot and update the list
        searchResults = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (error) {
      print('Error getting search results: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            
            children: [
              Row(children: [
                IconButton(onPressed: (){
                  Navigator.pop(context);
                }, icon: Icon(Icons.arrow_back),)
                ,
                const Spacer(),
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
                            shadowColor: MaterialStatePropertyAll(Colors.white),
                          ),
                          onPressed: () async {
                            await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyCartPage(),
                              ),
                            );
                            setState(() {
                              
                            });
                          },
                          icon: const Icon(
                            Icons.shopping_cart,
                          ),
                          label: const Text('Go to Cart'),
                        ),
                      ),
              ],),
              SizedBox(height: 20,),
              Text(
                'Search Results for "${widget.searchTerm}" :',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(padding: EdgeInsets.zero,
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> itemDetails = searchResults[index];
        
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('cooks')
                          .doc(itemDetails['cook-id'])
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> cookSnapshot) {
                        if (cookSnapshot.connectionState ==
                            ConnectionState.done) {
                          Map<String, dynamic>? cookData =
                              cookSnapshot.data?.data() as Map<String, dynamic>?;
        
                          return SellerEachItemListElement(
                            cookName: cookData!["name"],
                            image: itemDetails["image"],
                            location: cookData["Location"],
                            name: itemDetails["Name"],
                            price: itemDetails["Price"],
                            rating: itemDetails["Rating"],
                            itemid: itemDetails["item-id"],
                          );
                        } else {
                          return SellerEachItemListElement(
                            cookName: "",
                            image: itemDetails["image"],
                            location: "",
                            name: itemDetails["Name"],
                            price: itemDetails["Price"],
                            rating: itemDetails["Rating"],
                            itemid: itemDetails["item-id"],
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
