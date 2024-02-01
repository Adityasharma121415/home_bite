import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_bite/seller_screens/seller_currentorder_page.dart';
import 'package:home_bite/seller_screens/seller_searchpage.dart';
import 'package:home_bite/seller_screens/sellerupdatecatpage.dart';
import 'package:home_bite/user_screens/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerHomepage extends StatefulWidget {
  const SellerHomepage({super.key});


  @override
  State<SellerHomepage> createState() {
    return _SellerHomepageState();
  }
}

class _SellerHomepageState extends State<SellerHomepage> {
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

  

  void logout()async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    FirebaseAuth.instance.signOut();
    log('logged out');
    // ignore: use_build_context_synchronously
    Navigator.popUntil(context, (route) => route.isFirst);
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
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
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              
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
                  IconButton(
                    onPressed: () {
                      logout();
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.green,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Image.asset('assets/images/profile.png', width: 100, height: 100),
              const SizedBox(height: 10),
              Text(
                'Welcome $_userName',
                style:
                    GoogleFonts.salsa(textStyle: const TextStyle(fontSize: 20)),
              ),
              
              
              SizedBox(
                        height: 68,
                        width: 400,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            textAlignVertical: TextAlignVertical.bottom,
                            controller: _searchController,
                            onSubmitted: (_) => _searchItems(),
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
              Expanded(
                child: SizedBox(
                  
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                             return const CurrentOrders();
                            },));
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
                              SizedBox(width: double.infinity,
                              height: 210,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset('assets/images/ordernew.jpg',
                                      fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'CURRENT ORDERS',
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
                                builder: (context) => const SellerCategoryPage(
                                  categorytype: 'categories',
                                ),
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
                              SizedBox(width: double.infinity,
                              height: 220,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                      'assets/images/updatemenu.jpeg',
                                      fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'UPDATE MENU',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
