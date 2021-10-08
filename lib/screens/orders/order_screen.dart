import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/order_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/screens/orders/order_details_screen.dart';
import 'package:card_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final custRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.orders)
      .withConverter<OrderModel>(
        fromFirestore: (snapshots, _) => OrderModel.fromJson(snapshots.data()!),
        toFirestore: (customer, _) => customer.toJson(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
        // title: Text('Orders'),
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         showLogoutDialog(context);
        //       },
        //       icon: Icon(Icons.logout, size: 20))
        // ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              "Orders",
              style: Theme.of(context).textTheme.headline4!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 28),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<OrderModel>>(
              stream: custRef
                  .where('cust_id',
                      isEqualTo:
                          Provider.of<AuthProvider>(context, listen: false)
                              .currentLoggedInUser
                              .custId)
                  .where('isDirectCharge', isEqualTo: false)
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
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            OrderDetailsScreen(
                                                data.docs[index].data())));
                              },
                              child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  margin: EdgeInsets.all(15),
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.grey.withOpacity(0.1)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                Text('Order By',
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                                const SizedBox(height: 5),
                                                Text(
                                                    data.docs[index]
                                                        .data()
                                                        .custName,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600))
                                              ],
                                            ),
                                            Text(
                                                data.docs[index]
                                                    .data()
                                                    .transactionDateTime,
                                                style: TextStyle(fontSize: 14))
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Text('Amount',
                                            style: TextStyle(fontSize: 14)),
                                        SizedBox(height: 5),
                                        Text(
                                            data.docs[index]
                                                    .data()
                                                    .amount
                                                    .toString() +
                                                " USD",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ))),
                        ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
