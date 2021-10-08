import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/card_model.dart';
import 'package:card_app/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel orderModel;
  const OrderDetailsScreen(this.orderModel, {Key? key}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final cardsRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.cards)
      .withConverter<CardModel>(
        fromFirestore: (snapshots, _) => CardModel.fromJson(snapshots.data()!),
        toFirestore: (card, _) => card.toJson(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order Details",
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 28),
                ),
                const SizedBox(height: 20),
                Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.withOpacity(0.1)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Text('Order By',
                                      style: TextStyle(fontSize: 14)),
                                  const SizedBox(height: 5),
                                  Text(widget.orderModel.custName,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600))
                                ],
                              ),
                              Text(widget.orderModel.transactionDateTime,
                                  style: TextStyle(fontSize: 14))
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text('Amount', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 5),
                          Text(widget.orderModel.amount.toString() + " USD",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 15),
                          Text('Ordered Cards', style: TextStyle(fontSize: 14)),
                          getCardList()
                        ],
                      ),
                    )),
              ]),
        ),
      ),
    );
  }

  Widget getCardList() {
    return StreamBuilder<QuerySnapshot<CardModel>>(
      stream: cardsRef
          .where('card_id',
              whereIn: widget.orderModel.arrCards.length == 0
                  ? ['']
                  : widget.orderModel.arrCards)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (!snapshot.hasData) {
          return Container(
              padding: EdgeInsets.all(20),
              child: const Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.requireData;

        if (data.size == 0) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text('No Cards Found!'),
            ),
          );
        }

        return ListView.builder(
          itemCount: data.size,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 8, 0),
                child: getCard(data.docs[index].data()));
          },
        );
      },
    );
  }

  Widget getCard(CardModel card) {
    return Container(
      width: double.infinity,
      child: Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    card.vendorName,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(card.catName,
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  SizedBox(height: 5),
                  Text(card.subCatName,
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  SizedBox(height: 5),
                  Text(card.cardNumber.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  SizedBox(height: 5),
                  // Text(card.amount.toString()),
                ]),
          )),
    );
  }
}
