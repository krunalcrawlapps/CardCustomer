import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/customer_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //variables
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController balanceController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool pwdVisible = false;
  bool confirmPwdVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    CustomerModel customerModel =
        Provider.of<AuthProvider>(context, listen: false).currentLoggedInUser;

    nameController.text = customerModel.custName;
    addressController.text = customerModel.custAddress;
    emailController.text = customerModel.custEmail;
    balanceController.text = customerModel.custBalance.toString();
    passwordController.text = customerModel.custPassword;
    confirmPasswordController.text = customerModel.custPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('My Profile'), actions: [
          IconButton(
              onPressed: () {
                showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, size: 20))
        ]),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(children: <Widget>[
                SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: RequiredValidator(
                      errorText: StringConstant.enter_name_validation),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Address',
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: RequiredValidator(
                      errorText: StringConstant.enter_address_validation),
                ),
                SizedBox(height: 20),
                TextFormField(
                  enabled: false,
                  controller: emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: StringConstant.email_address,
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: StringConstant.enter_email_validation),
                    EmailValidator(
                        errorText: StringConstant.enter_valid_email_validation)
                  ]),
                ),
                SizedBox(height: 20),
                TextFormField(
                  enabled: false,
                  controller: balanceController,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Balance',
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: RequiredValidator(
                      errorText: 'StringConstant.enter_balance_validation'),
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: !pwdVisible,
                  controller: passwordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: StringConstant.password,
                      labelStyle: TextStyle(fontSize: 15),
                      suffixIcon: IconButton(
                        icon: Icon(
                          pwdVisible ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          setState(() {
                            pwdVisible = !pwdVisible;
                          });
                        },
                      )),
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: StringConstant.enter_pwd_validation),
                    MinLengthValidator(6,
                        errorText: StringConstant.enter_valid_pwd_validation)
                  ]),
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: !confirmPwdVisible,
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(fontSize: 15),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          confirmPwdVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          setState(() {
                            confirmPwdVisible = !confirmPwdVisible;
                          });
                        },
                      )),
                  validator: (val) => MatchValidator(
                          errorText:
                              StringConstant.invalid_confirm_pwd_validation)
                      .validateMatch(passwordController.text, val ?? ''),
                ),
                SizedBox(height: 50),
                isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.orange)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _editCustomer();
                            }
                          },
                          child: Text('Save', style: TextStyle(fontSize: 18)),
                        ),
                      )
              ]),
            ))));
  }

  _editCustomer() async {
    setState(() {
      isLoading = true;
    });

    try {
      CustomerModel customerModel =
          Provider.of<AuthProvider>(context, listen: false).currentLoggedInUser;
      String oldPwd = customerModel.custPassword;

      customerModel.custName = nameController.text;
      customerModel.custAddress = addressController.text;
      customerModel.custPassword = passwordController.text;

      await DatabaseHelper.shared
          .updateCustomer(oldPwd, customerModel, context);

      setState(() {
        isLoading = false;
      });

      showAlert(context, 'Profile updated.');
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      showAlert(context, error.toString());
    }
  }
}
