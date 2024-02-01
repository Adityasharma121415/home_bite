import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_bite/user_screens/loginpage.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    // Start the timer and toggle the visibility of the logo
    Timer(const Duration(seconds: 1), () {
      setState(() {
        _visible = true;
      });
      // Navigate to LoginPage after another second
      Timer(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
          child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(seconds: 1),
            child: AnimatedContainer(
              duration: const Duration(seconds: 0),
              curve: Curves.easeInOut,
              width: _visible ? 500 : 0, // Adjust the width as needed
              height: _visible ? 250 : 0, // Adjust the height as needed
              child: SizedBox(width: 400,
              height: 200,
                child: Image.asset(
                  "assets/images/logoappnew.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
