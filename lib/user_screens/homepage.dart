import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_bite/user_screens/categories_page.dart';
import 'package:home_bite/user_screens/loginpage.dart';
import 'package:home_bite/user_screens/search_screen.dart';
import 'package:home_bite/user_screens/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(
          () {
            _userName = userDoc['name'];
          },
        );
      }
    }
  }

  void _searchItems() async {
    String searchTerm = _searchController.text.trim();

    if (searchTerm.isNotEmpty) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('menu')
            .where('Name', isEqualTo: searchTerm)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(searchTerm: searchTerm),
            ),
          );

          _searchController.clear();
        } else {
          // Show a message or take action if no matching item found
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'No match found',
                ),
                titleTextStyle:
                    const TextStyle(fontSize: 18, color: Colors.black),
                content: const SizedBox(
                  width: 210,
                  height: 50,
                  child: Center(
                    child: Text(
                        'Try correcting the spelling. Consider case sensitivity.'),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        print('Error searching items: $error');
      }
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('B.M.S College of Engineering'),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const UserProfile();
                      },
                    ));
                  },
                  child: Image.asset('assets/images/profile.png',
                      width: 100, height: 100)),
              const SizedBox(height: 10),
              Text(
                'Welcome $_userName',
                style:
                    GoogleFonts.salsa(textStyle: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 68,
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.bottom,
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      hintText: 'Enter your search term',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _searchItems(),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              SizedBox(
                height: 530,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CategoryPage(categorytype: 'Cooks'),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: const MaterialStatePropertyAll(
                            Color.fromARGB(255, 40, 40, 41),
                          ),
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          fixedSize: const MaterialStatePropertyAll(
                            Size.fromWidth(390),
                          ),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                  'assets/images/home_image2.jpg',
                                  fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'ORDER BY COOKS',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoryPage(
                                  categorytype: 'Categories'),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: const MaterialStatePropertyAll(
                            Color.fromARGB(255, 40, 40, 41),
                          ),
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          fixedSize: const MaterialStatePropertyAll(
                            Size.fromWidth(390),
                          ),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                  'assets/images/home_image1.jpg',
                                  fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'ORDER BY CATEGORIES',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
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
