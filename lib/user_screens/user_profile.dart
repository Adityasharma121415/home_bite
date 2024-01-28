import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_bite/user_screens/loginpage.dart';
import 'package:home_bite/user_screens/my_cart_screen.dart';
import 'package:home_bite/user_screens/my_orders_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_role');
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (!snapshot.hasData) {
                return Text('No Data');
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;

              return Center(
                child: Column(
                  children: [
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/images/profile.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userData['name'],
                      style: GoogleFonts.salsa(
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      
                    ),
                    SizedBox(height: 10,),
                    Text(
                      ' ${userData['email']}',
                      style: GoogleFonts.salsa(
                        textStyle: const TextStyle(fontSize: 14,fontWeight: FontWeight.w100),
                      ),)
,                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return MyCartPage();
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('My Cart'),
                          ),
                          const SizedBox(width: 20),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return MyOrdersPage();
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_bag),
                            label: const Text('My Orders'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      child: Column(
                        children: [
                          
                          buildEditableCard(
                            'Phone: ${userData['mobileNo']}',
                            'mobileNo',
                            'Enter new phone number',
                            _phoneController,
                          ),
                          buildEditableCard(
                            'Address: ${userData['Location'] ?? 'tobeupdated'}',
                            'Location',
                            'Enter new Address',
                            _addressController,
                          ),
                          // Repeat the above Card for other fields like Mobile Number, Location, etc.
                          // Update the field name and value in _updateUserData accordingly
                          TextButton.icon(
                            onPressed: logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildEditableCard(String label, String fieldName, String hintText,
      TextEditingController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Update $fieldName'),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: hintText),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _updateUserData(fieldName, controller.text);
                      Navigator.of(context).pop();
                    },
                    child: Text('Save'),
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          width: double.infinity,
          height: 70,
          child: Row(
            children: [
              Text(label),
              const Spacer(),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Update $fieldName'),
                        content: TextField(
                          controller: controller,
                          decoration: InputDecoration(hintText: hintText),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _updateUserData(fieldName, controller.text);
                              Navigator.of(context).pop();
                            },
                            child: Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateUserData(String fieldName, dynamic value) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({fieldName: value});
  }
}
