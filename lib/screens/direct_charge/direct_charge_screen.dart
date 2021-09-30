import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/order_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/utils/date_utils.dart';
import 'package:card_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';

import '../home_screen.dart';

class DirectChargeScreen extends StatefulWidget {
  const DirectChargeScreen({Key? key}) : super(key: key);

  @override
  _DirectChargeScreenState createState() => _DirectChargeScreenState();
}

class _DirectChargeScreenState extends State<DirectChargeScreen> {
  TextEditingController accountController = TextEditingController();
  TextEditingController secAccountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buy Direct Charge')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: Column(children: [
            Container(
              width: double.infinity,
              child: Card(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(children: [
                      Row(children: [
                        Text('Name:', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 5),
                        Text(
                            Provider.of<AuthProvider>(context, listen: true)
                                .currentLoggedInUser
                                .custName,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500))
                      ]),
                      SizedBox(height: 10),
                      Row(children: [
                        Text('Current Balance:',
                            style: TextStyle(fontSize: 16)),
                        SizedBox(width: 5),
                        Text(
                            Provider.of<AuthProvider>(context, listen: true)
                                    .currentLoggedInUser
                                    .custBalance
                                    .toStringAsFixed(2) +
                                ' USD',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown))
                      ])
                    ])),
              ),
            ),
            SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Container(
                width: double.infinity,
                child: Card(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(children: [
                        Row(children: [
                          Text('Selected Vendor:',
                              style: TextStyle(fontSize: 16)),
                          SizedBox(width: 5),
                          Text(
                              Provider.of<AuthProvider>(context, listen: true)
                                  .selectedVendor
                                  .vendorName,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown))
                        ]),
                        SizedBox(height: 10),
                        Row(children: [
                          Text('Selected Category:',
                              style: TextStyle(fontSize: 16)),
                          SizedBox(width: 5),
                          Text(
                              Provider.of<AuthProvider>(context, listen: true)
                                  .selectedCategory
                                  .catName,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown))
                        ]),
                        SizedBox(height: 10),
                        Row(children: [
                          Text('Price:', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 5),
                          Text(
                              Provider.of<AuthProvider>(context, listen: true)
                                      .selectedCategory
                                      .amount
                                      .toString() +
                                  ' USD',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown))
                        ]),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: accountController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Account Id',
                              labelStyle: TextStyle(fontSize: 15)),
                          validator: RequiredValidator(
                              errorText:
                                  StringConstant.enter_accountId_validation),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: secAccountController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Secondary Account Id',
                              labelStyle: TextStyle(fontSize: 15)),
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: 200,
                          height: 40,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.orange)),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (getRemainingAmount() < 0) {
                                  showAlert(context,
                                      'You have not sufficient balance');
                                } else {
                                  //buy
                                  _doBuyCards();
                                }
                              }
                            },
                            child: const Text('Buy',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        SizedBox(height: 20)
                      ])),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  _doBuyCards() {
    OrderModel orderModel = OrderModel(
        getRandomId(),
        DateTimeUtils.getDateTime(DateTime.now().millisecondsSinceEpoch),
        '',
        Provider.of<AuthProvider>(context, listen: false)
            .currentLoggedInUser
            .custId,
        Provider.of<AuthProvider>(context, listen: false)
            .currentLoggedInUser
            .custName,
        true,
        accountController.text,
        secAccountController.text,
        "Open");

    orderModel.arrCards = [];

    DatabaseHelper.shared.addOrderData(orderModel);

    DatabaseHelper.shared.updateCustBalance(getRemainingAmount(), context);

    showAlert(context, 'Order placed successfully.', onClick: () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false);
    });
  }

  double getRemainingAmount() {
    double currentBln = Provider.of<AuthProvider>(context, listen: false)
        .currentLoggedInUser
        .custBalance;

    double amount = Provider.of<AuthProvider>(context, listen: false)
        .selectedCategory
        .amount;

    double remain = currentBln - amount;

    return remain;
  }
}
