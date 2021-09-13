import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final orderRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.orders)
      .withConverter<OrderModel>(
        fromFirestore: (snapshots, _) => OrderModel.fromJson(snapshots.data()!),
        toFirestore: (card, _) => card.toJson(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(StringConstant.orders)),
      body: StreamBuilder<QuerySnapshot<OrderModel>>(
        stream: orderRef
            .where('cust_id',
                isEqualTo: DatabaseHelper.shared.getLoggedInUserModel()?.custId)
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

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Container(
                      width: double.infinity,
                      child: Card(
                          child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text('Card Number: ' +
                                  data.docs[index]
                                      .data()
                                      .cardNumber
                                      .toString()),
                              SizedBox(height: 5),
                              Text('Card Vendor: ' +
                                  data.docs[index].data().cardVendor),
                              SizedBox(height: 5),
                              Text('Order Date: ' +
                                  getDateTime(data.docs[index]
                                      .data()
                                      .transactionDateTime)),
                            ]),
                      ))));
            },
          );
        },
      ),
    );
  }

  String getDateTime(int timestamp) {
    var dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy, hh:mm a').format(dt);
  }
}
