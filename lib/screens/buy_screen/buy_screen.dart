import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/card_model.dart';
import 'package:card_app/models/order_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/screens/home_screen.dart';
import 'package:card_app/utils/date_utils.dart';
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
      appBar: AppBar(title: Text('Buy Cards')),
      body: SafeArea(
        child: isCardsLoading
            ? Center(child: CircularProgressIndicator())
            : arrCards.length == 0
                ? Center(child: Text('No Cards in this Category!'))
                : Padding(
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
                                      Provider.of<AuthProvider>(context,
                                              listen: true)
                                          .currentLoggedInUser
                                          .custName,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500))
                                ]),
                                SizedBox(height: 10),
                                Row(children: [
                                  Text('Current Balance:',
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(width: 5),
                                  Text(
                                      Provider.of<AuthProvider>(context,
                                                  listen: true)
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
                      Container(
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
                                      Provider.of<AuthProvider>(context,
                                              listen: true)
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
                                      Provider.of<AuthProvider>(context,
                                              listen: true)
                                          .selectedCategory
                                          .catName,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown))
                                ]),
                                SizedBox(height: 10),
                                Row(children: [
                                  Text('Selected Sub Category:',
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(width: 5),
                                  Text(
                                      Provider.of<AuthProvider>(context,
                                              listen: true)
                                          .selectedSubCategory
                                          .subCatName,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown))
                                ]),
                                SizedBox(height: 10),
                                Row(children: [
                                  Text('Price:',
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(width: 5),
                                  Text(
                                      Provider.of<AuthProvider>(context,
                                                  listen: true)
                                              .selectedSubCategory
                                              .amount
                                              .toString() +
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
                      Text('Add Qty',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown)),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                // color: Colors.cyan,
                                border: Border.all(color: Colors.orange)),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        if (itemQty != 1) {
                                          setState(() {
                                            itemQty -= 1;
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.remove,
                                          size: 15, color: Colors.orange)),
                                  SizedBox(width: 5),
                                  Text('$itemQty',
                                      style: TextStyle(color: Colors.orange)),
                                  SizedBox(width: 5),
                                  IconButton(
                                      onPressed: () {
                                        itemQty += 1;

                                        if (itemQty > arrCards.length) {
                                          itemQty -= 1;
                                          showAlert(context,
                                              'Only ${arrCards.length} Cards Available!');
                                        } else {
                                          double amount =
                                              Provider.of<AuthProvider>(context,
                                                      listen: false)
                                                  .selectedSubCategory
                                                  .amount;
                                          double totalUsedAmount =
                                              amount * itemQty;
                                          // if (getRemainingAmount() <
                                          //     tmpAmount) {
                                          if (totalUsedAmount >
                                              Provider.of<AuthProvider>(context,
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
                                      icon: Icon(Icons.add,
                                          size: 15, color: Colors.orange))
                                ])),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Total Amount:',
                                  style: TextStyle(fontSize: 18)),
                              SizedBox(width: 5),
                              Text(getTotalAmount().toString() + ' USD',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown))
                            ]),
                      ),
                      SizedBox(height: 30),
                      Container(
                        width: 200,
                        height: 40,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.orange)),
                          onPressed: () {
                            if (itemQty > arrCards.length) {
                              showAlert(context,
                                  'Only ${arrCards.length} Cards Available!');
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
                          child: const Text('Buy Cards',
                              style: TextStyle(fontSize: 18)),
                        ),
                      )
                    ]),
                  ),
      ),
    );
  }

  _doBuyCards() {
    List<CardModel> arrBuyCards = arrCards.sublist(0, itemQty);

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
