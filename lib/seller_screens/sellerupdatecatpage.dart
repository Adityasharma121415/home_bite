import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_bite/seller_screens/seller_dynamic_menu.dart';

class SellerCategoryPage extends StatefulWidget {
  const SellerCategoryPage({required this.categorytype, super.key});
  final String categorytype;

  @override
  State<SellerCategoryPage> createState() {
    return _SellerCategoryPageState();
  }
}

class _SellerCategoryPageState extends State<SellerCategoryPage> {
  @override
  Widget build(context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
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
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                            color: const Color.fromARGB(255, 214, 0, 0),
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
                              onPressed: () {},
                              icon: const Icon(
                                Icons.add_box_outlined,
                              ),
                              label: const Text('Add Category'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Text(
                        widget.categorytype,
                        style: GoogleFonts.salsa(
                            textStyle: const TextStyle(fontSize: 38)),
                      ),
                      
                      
                    ],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: 620,
                    child: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(widget.categorytype.toLowerCase())
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                  
                            // Loading indicator while fetching data
                          }
                  
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                  
                          final categories = snapshot.data!.docs;
                  
                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: categories.length,
                            itemBuilder: (BuildContext context, index) {
                              return GridItem(categories[index]);
                            },
                          );
                        },
                      ),
                    ),
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

class GridItem extends StatelessWidget {
  final QueryDocumentSnapshot category;

  const GridItem(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9.0),
      child: GestureDetector(
        onTap: () {
          //put the functionality t move to different page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellerDynamicMenuPage(
                  categoryid: category['category-id'],
                  categoryName: category['category'].toString()),
            ),
          );
        },
        child: Container(
          color: const Color.fromARGB(255, 40, 40, 41),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 12,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.network(
                    category['displayimg'], // Assuming Displayimg is a URL
                    width: 164,
                    height: 164,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  category['category'].toString().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
