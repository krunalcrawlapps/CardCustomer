import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/customer_model.dart';
import 'package:card_app/screens/auth_screens/login_screen.dart';
import 'package:card_app/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DatabaseHelper.shared.initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: StringConstant.app_name,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const IntroScreen(),
    );
  }
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        useLoader: true,
        loadingTextPadding: const EdgeInsets.all(0),
        loadingText: const Text(""),
        navigateAfterSeconds: navigateToNextScreen(),
        seconds: 2,
        title: const Text(
          'Welcome To Card app!',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: Image.asset(ImageConstant.logo_img, fit: BoxFit.scaleDown),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: const TextStyle(),
        photoSize: 100.0,
        // ignore: avoid_print
        onClick: () => print("flutter"),
        loaderColor: Colors.orange);
  }

  Widget navigateToNextScreen() {
    CustomerModel? userModel = DatabaseHelper.shared.getLoggedInUserModel();

    if (userModel != null) {
      return HomeScreen();
    }

    //do login
    return LoginScreen();
  }
}
