import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/customer_model.dart';
import 'package:card_app/screens/home_screen.dart';
import 'package:card_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //variables
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool pwdVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(StringConstant.login)),
        body: Center(
          child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                  child: Column(children: <Widget>[
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset(ImageConstant.logo_img,
                      fit: BoxFit.scaleDown),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: StringConstant.email_address,
                        labelStyle: TextStyle(fontSize: 15)),
                    validator: MultiValidator([
                      RequiredValidator(
                          errorText: StringConstant.enter_email_validation),
                      EmailValidator(
                          errorText:
                              StringConstant.enter_valid_email_validation)
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    obscureText: !pwdVisible,
                    controller: passwordController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: StringConstant.password,
                        labelStyle: TextStyle(fontSize: 15),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            pwdVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              pwdVisible = !pwdVisible;
                            });
                          },
                        )),
                    // The validator receives the text that the user has entered.
                    validator: RequiredValidator(
                        errorText: StringConstant.enter_pwd_validation),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Container(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.orange)),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _doLogin(context);
                              }
                            },
                            child: const Text('Submit',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                )
              ]))),
        ));
  }

  _doLogin(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = await DatabaseHelper.shared
          .doLogin(emailController.text, passwordController.text);

      if (user != null) {
        _saveUserDataNavigate(user);
      } else {
        setState(() {
          isLoading = false;
        });
        showAlert(context, ErrorMessage.something_wrong);
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      showAlert(context, error.toString());
    }
  }

  _saveUserDataNavigate(User user) async {
    CustomerModel? currentUser =
        await DatabaseHelper.shared.getUserDataFromFirebase(user.uid);

    setState(() {
      isLoading = false;
    });

    if (currentUser != null) {
      DatabaseHelper.shared.saveUserModel(currentUser);
      //user is normal admin
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
    } else {
      showAlert(context, ErrorMessage.something_wrong);
    }
  }
}
