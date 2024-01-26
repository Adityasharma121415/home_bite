import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:home_bite/user_screens/homepage.dart';
import 'package:home_bite/user_screens/loginpage.dart';
import 'package:home_bite/user_screens/my_orders_page.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //     overlays: [SystemUiOverlay.bottom]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget{
  const MyApp({super.key});
  @override
  Widget build(context){

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
       home:  MyOrdersPage()//(FirebaseAuth.instance.currentUser!=null)? const HomePage():const LoginPage(),  //MyCartPage(),// SellerHomepage() MyOrdersPage()
    );
  }
}