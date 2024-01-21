import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  _ForgotPasswordSheetState createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  TextEditingController emailController = TextEditingController();


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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20,),
           Text(
            'Reset Password',
            style: GoogleFonts.salsa(
                            textStyle: const TextStyle(fontSize: 22))
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter your E-mail address and check your mailbox to reset Password.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _sendResetPasswordEmail();
            },
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }

  void _sendResetPasswordEmail() async{
    String email = emailController.text.trim();

    try{
     await FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((value) => null);
    }on FirebaseAuthException catch(ex)
    {
      _showErrorDialog(ex.code.toString(), context);
    }

    Navigator.pop(context); 
  }
}


