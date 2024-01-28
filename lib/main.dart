// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:home_bite/seller_screens/seller_homepage.dart';
import 'package:home_bite/user_screens/homepage.dart';
import 'package:home_bite/user_screens/loginpage.dart';
// import 'package:home_bite/user_screens/my_orders_page.dart';
import 'firebase_options.dart';
// import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  Future<void> checkUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    if (userId != null) {
      userRole = prefs.getString('user_role');
      setState(() {}); // Trigger a rebuild after fetching user role
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: userRole != null
          ? userRole == 'Cook'
              ? SellerHomepage()
              : HomePage()
          : LoginPage(),
    );
  }
}
