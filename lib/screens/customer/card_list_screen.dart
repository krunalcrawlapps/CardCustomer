import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/card_model.dart';
import 'package:card_app/models/order_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/utils/date_utils.dart';
import 'package:card_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardListScreen extends StatefulWidget {
  final Function refresh;
  const CardListScreen(this.refresh, {Key? key}) : super(key: key);

  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final cardsRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.cards)
      .withConverter<CardModel>(
        fromFirestore: (snapshots, _) => CardModel.fromJson(snapshots.data()!),
        toFirestore: (card, _) => card.toJson(),
      );

  List<CardModel> arrCards = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(StringConstant.cards)),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<CardModel>>(
          stream: cardsRef
              .where('card_status', isEqualTo: CardStatus.available)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.requireData;

            if (data.size == 0) {
              return Center(
                child: Text(StringConstant.no_data_found),
              );
            }

            data.docs.forEach((element) {
              arrCards.add(element.data());
            });

            // arrCards = data.docs;
            return Column(children: [
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('Current Balance:', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 5),
                  Text(
                      Provider.of<AuthProvider>(context, listen: true)
                          .currentLoggedInUser
                          .custBalance
                          .toString(),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown))
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    return data.docs[index].data().cardStatus == CardStatus.used
                        ? getCardItem(data.docs[index].data(), index)
                        : getCardItem(data.docs[index].data(), index);
                  },
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.orange)),
                  onPressed: () {
                    _buySelectedCards();
                  },
                  child:
                      const Text('Buy Cards', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 20),
            ]);
          },
        ),
      ),
    );
  }

  Widget getCardItem(CardModel cardModel, int index) {
    return Padding(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Container(
          width: double.infinity,
          child: Card(
              color: cardModel.cardStatus == CardStatus.used
                  ? Colors.black12
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Row(children: [
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text(cardModel.cardVendor),
                          SizedBox(height: 5),
                          Text('**********'),
                          SizedBox(height: 5),
                          Text(cardModel.cardStatus),
                          SizedBox(height: 5),
                          Text(cardModel.amount.toString()),
                        ]),
                  ),
                  cardModel.cardStatus == CardStatus.used
                      ? Container()
                      : IconButton(
                          onPressed: () {
                            if (arrCards[index].isSelected) {
                              setState(() {
                                arrCards[index].isSelected =
                                    !arrCards[index].isSelected;
                              });
                            } else {
                              if (getRemainingAmount() <
                                  arrCards[index].amount) {
                                showAlert(
                                    context, 'You have not sufficient balance');
                              } else {
                                setState(() {
                                  arrCards[index].isSelected =
                                      !arrCards[index].isSelected;
                                });
                              }
                            }
                          },
                          icon: Icon(
                            arrCards[index].isSelected
                                ? Icons.check_box_outlined
                                : Icons.check_box_outline_blank,
                            color: Colors.orange,
                          ))
                ]),
              )),
        ));
  }

  double getRemainingAmount() {
    double currentBln = Provider.of<AuthProvider>(context, listen: false)
        .currentLoggedInUser
        .custBalance;
    List<CardModel> arrSelected =
        arrCards.where((element) => element.isSelected).toList();
    double totalUsed = arrSelected.fold(0, (p, c) => p + c.amount);

    return currentBln - totalUsed;
  }

  _buySelectedCards() {
    List<CardModel> arrSelected =
        arrCards.where((element) => element.isSelected).toList();

    OrderModel orderModel = OrderModel(
        getRandomId(),
        DateTimeUtils.getDateTime(DateTime.now().millisecondsSinceEpoch),
        arrSelected.first.adminId,
        Provider.of<AuthProvider>(context, listen: false)
            .currentLoggedInUser
            .custId,
        Provider.of<AuthProvider>(context, listen: false)
            .currentLoggedInUser
            .custName);

    orderModel.arrCards = arrSelected.map((e) => e.cardId).toList();

    DatabaseHelper.shared.addOrderData(orderModel);
    arrSelected.forEach((element) {
      DatabaseHelper.shared.updateCardStatus(element.cardId);
    });

    DatabaseHelper.shared.updateCustBalance(getRemainingAmount(), context);

    showAlert(context, 'Order placed successfully.', onClick: () {
      Navigator.of(context).pop();
      widget.refresh();
    });
  }
}
