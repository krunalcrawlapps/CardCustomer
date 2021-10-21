import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/card_model.dart';
import 'package:card_app/models/order_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/provider/language_provider.dart';
import 'package:card_app/screens/home_screen.dart';
import 'package:card_app/utils/date_utils.dart';
import 'package:card_app/utils/in_app_translation.dart';
import 'package:card_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({Key? key}) : super(key: key);

  @override
  _BuyScreenState createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  int itemQty = 1;

  bool isCardsLoading = true;
  List<CardModel> arrCards = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getAllCards();
  }

  getAllCards() async {
    arrCards = await DatabaseHelper.shared.getVendorWiseCards(
        Provider.of<AuthProvider>(context, listen: false)
            .selectedVendor
            .vendorId,
        Provider.of<AuthProvider>(context, listen: false)
            .selectedCategory
            .catId,
        Provider.of<AuthProvider>(context, listen: false)
            .selectedSubCategory
            .subCatId);

    setState(() {
      isCardsLoading = false;
      arrCards = arrCards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('Buy Cards'),
        iconTheme: IconThemeData(color: Colors.orange),
      ),
      body: SafeArea(
        child: isCardsLoading
            ? Center(child: CircularProgressIndicator())
            : arrCards.length == 0
                ? Center(
                    child: Text(AppTranslations.of(context)!
                        .text('No Cards in this Category!')))
                : Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Column(children: [
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User name...
                                Text(
                                  '${Provider.of<AuthProvider>(context, listen: true).currentLoggedInUser.custName}',
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 20),
                                // Current balance...
                                Row(
                                  children: [
                                    Text(
                                        AppTranslations.of(context)!
                                            .text('Current Balance:'),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey)),
                                    SizedBox(width: 5),
                                    Text(
                                        Provider.of<AuthProvider>(context,
                                                    listen: true)
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
                              ])),
                      Card(
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
                                  "${Provider.of<AuthProvider>(context, listen: false).selectedSubCategory.amount}\n ${AppTranslations.of(context)!.text(Provider.of<AuthProvider>(context, listen: false).selectedSubCategory.currency.toUpperCase())}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(4),
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey.withOpacity(0.1)),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          )),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    AppTranslations.of(context)!
                                                        .text('Category'),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    )),
                                                SizedBox(height: 5),
                                                Text(
                                                    Provider.of<AuthProvider>(
                                                            context,
                                                            listen: true)
                                                        .selectedCategory
                                                        .catName,
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      AppTranslations.of(
                                                              context)!
                                                          .text('Sub Category'),
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    Provider.of<AuthProvider>(
                                                            context,
                                                            listen: true)
                                                        .selectedSubCategory
                                                        .subCatName,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 3,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(top: 25),
                                        padding: EdgeInsets.only(
                                            left: 10, top: 5, bottom: 5,right: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Row(
                                          children: [
                                            Text(
                                              AppTranslations.of(context)!
                                                  .text('Select Quantity'),
                                            ),
                                            Spacer(),
                                            IconButton(
                                                onPressed: () {
                                                  if (itemQty != 1) {
                                                    setState(() {
                                                      itemQty -= 1;
                                                    });
                                                  }
                                                },
                                                icon: Container(
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.grey
                                                          .withOpacity(0.15)),
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 20,
                                                  ),
                                                )),
                                            SizedBox(width: 10),
                                            Text('$itemQty',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            SizedBox(width: 10),
                                            IconButton(
                                                onPressed: () {
                                                  itemQty += 1;

                                                  if (itemQty >
                                                      arrCards.length) {
                                                    itemQty -= 1;
                                                    showAlert(context,
                                                        '${AppTranslations.of(context)!.text('Only')} ${arrCards.length} ${AppTranslations.of(context)!.text('Cards Available')}!');
                                                  } else {
                                                    double amount = Provider.of<
                                                                AuthProvider>(
                                                            context,
                                                            listen: false)
                                                        .selectedSubCategory
                                                        .amount;
                                                    double totalUsedAmount =
                                                        amount * itemQty;
                                                    // if (getRemainingAmount() <
                                                    //     tmpAmount) {
                                                    if (totalUsedAmount >
                                                        Provider.of<AuthProvider>(
                                                                context,
                                                                listen: false)
                                                            .currentLoggedInUser
                                                            .custBalance) {
                                                      //no enough balance
                                                      itemQty -= 1;
                                                      showAlert(context,
                                                          'You have not sufficient balance');
                                                    } else {
                                                      setState(() {});
                                                    }
                                                  }
                                                },
                                                icon: Container(
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.grey
                                                          .withOpacity(0.15)),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 20,
                                                  ),
                                                ))
                                          ],
                                        ),
                                      )
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text(
                            '${AppTranslations.of(context)!.text('Total Amount')}\n${getTotalAmount().toString() + ' ${AppTranslations.of(context)!.text(Provider.of<AuthProvider>(context, listen: false).selectedSubCategory.currency.toUpperCase())}'}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.orange),
                            fixedSize: MaterialStateProperty.all(Size(
                                MediaQuery.of(context).size.width - 30, 50)),
                            elevation: MaterialStateProperty.all(0),
                          ),
                          onPressed: () {
                            if (itemQty > arrCards.length) {
                              showAlert(context,
                                  '${AppTranslations.of(context)!.text('Only')} ${arrCards.length} ${AppTranslations.of(context)!.text('Cards Available!')}');
                            } else {
                              double amount = Provider.of<AuthProvider>(context,
                                      listen: false)
                                  .selectedSubCategory
                                  .amount;
                              double totalUsedAmount = amount * itemQty;
                              if (totalUsedAmount >
                                  Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .currentLoggedInUser
                                      .custBalance) {
                                //no enough balance
                                showAlert(
                                    context, 'You have not sufficient balance');
                              } else {
                                _doBuyCards();
                              }
                            }
                          },
                          child: Text(AppTranslations.of(context)!.text('Buy'),
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ]),
                  ),
      ),
    );
  }

  _doBuyCards() {
    List<CardModel> arrBuyCards = arrCards.sublist(0, itemQty);

    double orderAmount = Provider.of<AuthProvider>(context, listen: false)
            .selectedSubCategory
            .amount *
        itemQty;
    OrderModel orderModel = OrderModel(
        getRandomId(),
        DateTimeUtils.getDateTime(DateTime.now().millisecondsSinceEpoch),
        arrBuyCards.first.adminId,
        Provider.of<AuthProvider>(context, listen: false)
            .currentLoggedInUser
            .custId,
        Provider.of<AuthProvider>(context, listen: false)
            .currentLoggedInUser
            .custName,
        false,
        "",
        "",
        "",
        orderAmount,
        "",
        "");

    orderModel.arrCards = arrBuyCards.map((e) => e.cardId).toList();

    DatabaseHelper.shared.addOrderData(orderModel);
    arrBuyCards.forEach((element) {
      DatabaseHelper.shared.updateCardStatus(element.cardId);
    });

    DatabaseHelper.shared.updateCustBalance(getRemainingAmount(), context);

    showAlert(context, 'Order placed successfully.', onClick: () {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false);
    });
  }

  double getTotalAmount() {
    double amount = Provider.of<AuthProvider>(context, listen: true)
        .selectedSubCategory
        .amount;
    return amount * itemQty;
  }

  double getRemainingAmount() {
    double currentBln = Provider.of<AuthProvider>(context, listen: false)
        .currentLoggedInUser
        .custBalance;

    double cardAmount = Provider.of<AuthProvider>(context, listen: false)
        .selectedSubCategory
        .amount;
    double totalAmount = cardAmount * itemQty;

    return currentBln - totalAmount;
  }
}
