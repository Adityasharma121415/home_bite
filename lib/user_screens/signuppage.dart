import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  
  bool _isLoading = false;

  User? currentUser=FirebaseAuth.instance.currentUser;

  void _showErrorDialog(String errorMessage, BuildContext context) {
    showDialog(
      
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentTextStyle: const TextStyle(fontSize: 16, color: Colors.red),
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
    String phone=phoneController.text.trim();

    

    if (name == "" || email == "" || password == "" || cpassword == "") {
      _showErrorDialog('No fields can be Empty', context);
    } else if (password != cpassword) {
      _showErrorDialog('Passwords Mismatch!', context);
    } else {
      setState(() {
      _isLoading = true;
    });
      try {
        UserCredential userCredentials = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);


        log('message');
        if (userCredentials.user != null) {

          await FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid).set({
          'name': name,
          'email': email,
          'mobileNo':phone,
          'user-id': userCredentials.user!.uid,
          'account-created-on': Timestamp.now(),
          // Add other user details as needed
        });
          FirebaseAuth.instance.signOut();
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (ex) {
        log(
          ex.code.toString(),
        );


        _showErrorDialog(ex.code.toString(), context);
      }finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(context) {
    return Scaffold(backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                      height: 50,
                    ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 245, 245, 245),
                ),
                height: 200,
                width: double.infinity,
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 200,
                    child: Image.asset(
                      'assets/images/finalapplogo.png',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                     Text(
                          'SignUp',
                          style: GoogleFonts.salsa(
                            textStyle: const TextStyle(fontSize: 32)
                          ),
                        ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: namecontroller,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: 'Name',
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.all(
                        //     Radius.circular(30),
                        //   ),
                        // ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(keyboardType: TextInputType.number,
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
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.all(
                        //     Radius.circular(30),
                        //   ),
                        // ),
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
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.all(
                        //     Radius.circular(30),
                        //   ),
                        // ),
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
                              backgroundColor: Color.fromARGB(255, 237, 149, 146),
                            ) : Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 116, 33, 33)),
                        height: 60,
                        width: double.infinity,
                        child: const Center(
                            child:  Text(
                          'Create Account',
                          style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.w600),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [const Text('Existing user ?',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('LogIn here',style: TextStyle(fontSize: 16),),
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
    );
  }
}
