import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_bite/seller_screens/sellerupdatecatpage.dart';
import 'package:home_bite/user_screens/loginpage.dart';

class SellerHomepage extends StatefulWidget {
  const SellerHomepage({super.key});

  @override
  State<SellerHomepage> createState() {
    return _SellerHomepageState();
  }
}

class _SellerHomepageState extends State<SellerHomepage> {

  void logout() {
    FirebaseAuth.instance.signOut();
    log('logged out');
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
  @override
  @override
  Widget build(context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(padding: EdgeInsets.zero,
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
                  'Welcome Seller',
                  style:
                      GoogleFonts.salsa(textStyle: const TextStyle(fontSize: 20)),
                ),
                
                const SizedBox(height: 30),
                SizedBox(
                  height: 600,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {},
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
