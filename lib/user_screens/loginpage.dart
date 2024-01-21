// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_bite/user_screens/forgotpassword.dart';

import 'package:home_bite/user_screens/homepage.dart';
import 'package:home_bite/user_screens/signuppage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailcontrol = TextEditingController();
  TextEditingController passwordcontrol = TextEditingController();
  bool _isLoading = false;

  void _showForgotPasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const ForgotPasswordSheet();
      },
    );
  }

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

  void login() async {
    String email = emailcontrol.text.trim();
    String password = passwordcontrol.text.trim();

    if (email == "" || password == "") {
      _showErrorDialog('No fields can be Empty', context);
    } else {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredentials = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        log('Successfully Logged In');
        if (userCredentials.user != null) {
          Navigator.popUntil(context, (route) => route.isFirst);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }
      } on FirebaseAuthException catch (ex) {
        _showErrorDialog(ex.code.toString(), context);
        log(
          ex.code.toString(),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'LogIn',
                        style: GoogleFonts.salsa(
                            textStyle: const TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      TextField(
                        controller: emailcontrol,
                        decoration: const InputDecoration(
                            labelText: 'Email Id', icon: Icon(Icons.email)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        obscureText: true,
                        controller: passwordcontrol,
                        decoration: const InputDecoration(
                            labelText: 'Password', icon: Icon(Icons.password)),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : () => login(),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Color.fromARGB(255, 14, 95, 27),
                                strokeWidth: 3.5,
                                backgroundColor:
                                    Color.fromARGB(255, 141, 236, 157),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        const Color.fromARGB(255, 11, 101, 26)),
                                height: 60,
                                width: double.infinity,
                                child: const Center(
                                    child: Text(
                                  'Log In',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                )),
                              ),
                      ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          
                          TextButton(
                            onPressed: () {
                              _showForgotPasswordSheet(context);
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'New User?',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ));
                            },
                            child: const Text(
                              'Create Account',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
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
