import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/order_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/provider/language_provider.dart';
import 'package:card_app/utils/date_utils.dart';
import 'package:card_app/utils/in_app_translation.dart';
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
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // User name...
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                '${Provider.of<AuthProvider>(context, listen: true).currentLoggedInUser.custName}',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 20),
            // Current balance...
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Row(
                children: [
                  Text(AppTranslations.of(context)!.text('Current Balance:'),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey)),
                  SizedBox(width: 5),
                  Text(
                      Provider.of<AuthProvider>(context, listen: true)
                              .currentLoggedInUser
                              .custBalance
                              .toStringAsFixed(2) +
                          ' ${AppTranslations.of(context)!.text('USD')}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey))
                ],
              ),
            ),
            SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Container(
                width: double.infinity,
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Consumer<LanguageProvider>(
                    builder: (context, language, child) => Stack(
                      alignment: language.isArabic
                          ? Alignment.topLeft
                          : Alignment.topRight,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(right: 3, top: 3),
                          decoration: BoxDecoration(
                            color: Color(0xFF935216),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                                topLeft: language.isArabic
                                    ? Radius.circular(5)
                                    : Radius.circular(40),
                                topRight: language.isArabic
                                    ? Radius.circular(40)
                                    : Radius.circular(5)),
                          ),
                          child: Text(
                            "${Provider.of<AuthProvider>(context, listen: true).selectedCategory.amount}\n ${AppTranslations.of(context)!.text('USD')}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.all(15),
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.withOpacity(0.1)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      AppTranslations.of(context)!
                                          .text('Vendor'),
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 5),
                                  Text(
                                      Provider.of<AuthProvider>(context,
                                              listen: true)
                                          .selectedVendor
                                          .vendorName,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown)),
                                  SizedBox(height: 20),
                                  Text(
                                      AppTranslations.of(context)!
                                          .text('Category'),
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 5),
                                  Text(
                                      Provider.of<AuthProvider>(context,
                                              listen: true)
                                          .selectedCategory
                                          .catName,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown)),
                                  SizedBox(height: 30),
                                  TextFormField(
                                    controller: accountController,
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: AppTranslations.of(context)!
                                            .text('Account Id'),
                                        labelStyle: TextStyle(fontSize: 15)),
                                    validator: RequiredValidator(
                                        errorText: AppTranslations.of(context)!
                                            .text(StringConstant
                                            .enter_accountId_validation)),
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    controller: secAccountController,
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: AppTranslations.of(context)!
                                            .text('Secondary Account Id'),
                                        labelStyle: TextStyle(fontSize: 15)),
                                  ),
                                  SizedBox(height: 10),
                                ])),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.orange),
                  elevation: MaterialStateProperty.all(0),
                  fixedSize: MaterialStateProperty.all(
                    Size(MediaQuery.of(context).size.width - 20, 50),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (getRemainingAmount() < 0) {
                      showAlert(context, 'You have not sufficient balance');
                    } else {
                      //buy
                      _doBuyCards();
                    }
                  }
                },
                child: Text(AppTranslations.of(context)!.text('Buy'),
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
          ]),
        ),
      ),
    );
  }

  _doBuyCards() {
    OrderModel orderModel = OrderModel(
        getRandomId(),
        DateTimeUtils.getDateTime(DateTime.now().millisecondsSinceEpoch),
        Provider.of<AuthProvider>(context, listen: false)
            .currentLoggedInUser
            .adminId,
        Provider.of<AuthProvider>(context, listen: false)
            .currentLoggedInUser
            .custId,
        Provider.of<AuthProvider>(context, listen: false)
            .currentLoggedInUser
            .custName,
        true,
        accountController.text,
        secAccountController.text,
        "Open",
        Provider.of<AuthProvider>(context, listen: false)
            .selectedCategory
            .amount,
        Provider.of<AuthProvider>(context, listen: false)
            .selectedVendor
            .vendorName,
        Provider.of<AuthProvider>(context, listen: false)
            .selectedCategory
            .catName);

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
