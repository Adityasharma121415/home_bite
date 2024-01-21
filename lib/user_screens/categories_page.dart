import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_bite/user_screens/dynamic_menulist.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({required this.categorytype, super.key});
  final String categorytype;

  @override
  State<CategoryPage> createState() {
    return _CategoryPageState();
  }
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(context) {
    void changethePage() {
      Navigator.pop(context);
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 205,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: changethePage,
                            icon: const Icon(Icons.arrow_back),
                            color: const Color.fromARGB(255, 214, 0, 0),
                          ),
                          const SizedBox(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  size: 24,
                                ),
                                SizedBox(width: 15),
                              ],
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
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 68,
                        width: 400,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            textAlignVertical: TextAlignVertical.bottom,
                            controller: SearchController(),
                            decoration: const InputDecoration(
                              labelText: 'Search',
                              hintText: 'Enter your search term',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
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
                            return GridItem(
                                categories[index], widget.categorytype);
                          },
                        );
                      },
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
  final String type;

  const GridItem(this.category, this.type, {super.key});

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
              builder: (context) => DynamicMenuPage(type: (type.toLowerCase() == 'categories')?'category-id':'cook-id',
                categoryid: (type.toLowerCase() == 'categories')
                    ? category['category-id']
                    : category['cook-id'],
                categoryName: (type.toLowerCase() == 'categories')
                    ? category['category'].toString()
                    : category['name'].toString(),
              ),
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
                  (type.toLowerCase() == 'categories')
                      ? category['category'].toString().toUpperCase()
                      : category['name'].toString().toUpperCase(),
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
