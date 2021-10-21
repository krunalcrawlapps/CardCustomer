import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/customer_model.dart';
import 'package:card_app/utils/in_app_translation.dart';
import 'package:card_app/utils/utils.dart';
import 'package:flutter/material.dart';

import '../home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoading = true;
  bool isBlock = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(milliseconds: 10), () {
      _checkLoggedInUserAndNavigate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Image.asset(ImageConstant.logo_img,
                fit: BoxFit.scaleDown, width: 80, height: 80),
            SizedBox(height: 30),
            Text(
              AppTranslations.of(context)!
                          .text('Welcome To Card app!'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            SizedBox(height: 30),
            isLoading
                ? CircularProgressIndicator()
                : isBlock
                    ? Text(
                       AppTranslations.of(context)!
                          .text( 'Your account has been blocked!. Please contact admin.'),
                        style: TextStyle(color: Colors.red))
                    : Container()
          ])),
    );
  }

  Future<Widget?> _checkLoggedInUserAndNavigate(BuildContext context) async {
    // User? user = FirebaseAuth.instance.currentUser;

    CustomerModel? customer = DatabaseHelper.shared.getLoggedInUserModel();
    if (customer != null) {
      CustomerModel? currentUser =
          await DatabaseHelper.shared.getUserDataFromFirebase(customer.custId);

      if (currentUser != null) {
        if (currentUser.isBlock) {
          isBlock = true;
          showAlert(context, 'Your account has been blocked!');
        } else {
          DatabaseHelper.shared.saveUserModel(currentUser, context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => HomeScreen()));
        }
      } else {
        showAlert(context, ErrorMessage.something_wrong);
      }
    } else {
      //do login
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
    }

    setState(() {
      isLoading = false;
    });
  }
}
