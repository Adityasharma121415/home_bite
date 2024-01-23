// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController cpasswordcontroller = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  File? profilepic;

  bool _isLoading = false;

  User? currentUser = FirebaseAuth.instance.currentUser;

  void _showErrorDialog(String errorMessage, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentTextStyle: const TextStyle(
              fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void createAccount(BuildContext context) async {
    String name = namecontroller.text.trim();
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();
    String cpassword = cpasswordcontroller.text.trim();
    String phone = phoneController.text.trim();

    if (name == "" || email == "" || password == "" || cpassword == ""|| profilepic==null) {
      _showErrorDialog('Fill all the fields and select profile Picture', context);
    } else if (password != cpassword) {
      _showErrorDialog('Passwords Mismatch!', context);
    } else if (_selectedProfile == 'Select Profile') {
      _showErrorDialog('Please select any Profile', context);
    } else {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredentials = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        log('message');
        if (userCredentials.user != null) {
          UploadTask uploadTask= FirebaseStorage.instance.ref().child('profilepictures').child(Uuid().v1()).putFile(profilepic!);

          TaskSnapshot taskSnapshot=await uploadTask;
          String downloadURL=await taskSnapshot.ref.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredentials.user!.uid)
              .set({
            'name': name,
            'email': email,
            'mobileNo': phone,
            'user-id': userCredentials.user!.uid,
            'account-created-on': Timestamp.now(),
            'role': _selectedProfile,
            'profile-pic':downloadURL,

            // Add other user details as needed
          });

          if (userCredentials.user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .get();

        if (userSnapshot.exists) {
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
          String userRole = userData['role'];

          if(userRole=='Cook'){
            await FirebaseFirestore.instance
              .collection('cooks')
              .doc(userCredentials.user!.uid)
              .set({
            'name': name,
            'displayimg':downloadURL,
            'Location':"To be updated!",
            'cook-id':userCredentials.user!.uid,


            // Add other user details as needed
          });

          }
        }}

          
          FirebaseAuth.instance.signOut();
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (ex) {
        log(
          ex.code.toString(),
        );

        _showErrorDialog(ex.code.toString(), context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _selectedProfile = 'Select Profile';
  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                // Container(
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(20),
                //     color: Color.fromARGB(255, 249, 249, 249),
                //   ),
                //   height: 150,
                //   width: double.infinity,
                //   child: Center(
                //     child: Image.asset(
                //       'assets/images/finalapplogo.png',
                //       fit: BoxFit.fill,
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'SignUp',
                        style: GoogleFonts.salsa(
                            textStyle: const TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CupertinoButton(
                        onPressed: () async {
                          XFile? selectedfile = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (selectedfile != null) {
                            File convertedFile = File(selectedfile.path);
                            setState(() {
                              profilepic = convertedFile;
                            });
                          }
                        },
                        child:  CircleAvatar(
                          radius: 60,
                          backgroundImage: (profilepic!=null)?FileImage(profilepic!):null,
                          backgroundColor: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 44, 124, 47),
                          ),
                          const SizedBox(width: 6.0),
                          DropdownButton<String>(
                            value: _selectedProfile,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedProfile = newValue ?? 'Select Profile';
                              });
                              // You can use _selectedProfile elsewhere in your application.
                            },
                            underline: Container(),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.blueAccent),
                            items: <String>[
                              'Select Profile',
                              'Customer',
                              'Cook'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      TextField(
                        controller: namecontroller,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          labelText: 'Name',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: phoneController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.call),
                          labelText: 'Mobile No.',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: emailcontroller,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          labelText: 'Email Id',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        obscureText: true,
                        controller: passwordcontroller,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.password),
                          labelText: 'Password',
                          suffixIcon: Icon(Icons.visibility),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        obscureText: true,
                        controller: cpasswordcontroller,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.security),
                          labelText: 'Confirm Password',
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : () => createAccount(context),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Color.fromARGB(255, 95, 21, 14),
                                strokeWidth: 3.5,
                                backgroundColor:
                                    Color.fromARGB(255, 237, 149, 146),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        const Color.fromARGB(255, 116, 33, 33)),
                                height: 60,
                                width: double.infinity,
                                child: const Center(
                                    child: Text(
                                  'Create Account',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                )),
                              ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Existing user ?',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'LogIn here',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
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
