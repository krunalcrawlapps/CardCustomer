import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/order_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/utils/in_app_translation.dart';
import 'package:card_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DirectChargeOrders extends StatefulWidget {
  const DirectChargeOrders({Key? key}) : super(key: key);

  @override
  _DirectChargeOrdersState createState() => _DirectChargeOrdersState();
}

class _DirectChargeOrdersState extends State<DirectChargeOrders> {
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
        // title: Text('Direct Charge Orders'),
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
            padding: const EdgeInsets.only(left: 15,right: 15),
            child: Text(
              AppTranslations.of(context)!.text("Direct Charge Orders"),
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
                  .where('isDirectCharge', isEqualTo: true)
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
                    child: Text(AppTranslations.of(context)!
                        .text(StringConstant.no_data_found)),
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
                            onTap: () {},
                            child: Card(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                Text(
                                                    AppTranslations.of(context)!
                                                        .text('Order By'),
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
                                                DateFormat(
                                                        'dd/MM/yyyy, hh:mm a',
                                                        Localizations.localeOf(
                                                                context)
                                                            .languageCode)
                                                    .format(DateFormat(
                                                            'dd/MM/yyyy, hh:mm a')
                                                        .parse(data.docs[index]
                                                            .data()
                                                            .transactionDateTime)),
                                                style: TextStyle(fontSize: 14))
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    AppTranslations.of(context)!
                                                        .text('Amount'),
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                                SizedBox(height: 5),
                                                Text(
                                                    data.docs[index]
                                                            .data()
                                                            .amount
                                                            .toString() +
                                                        " ${AppTranslations.of(context)!.text('USD')}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    AppTranslations.of(context)!
                                                        .text(
                                                            'Fulfillment Status'),
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                                SizedBox(height: 5),
                                                Text(
                                                    data.docs[index]
                                                        .data()
                                                        .fulfilmentStatus,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ]),
                                )),
                          ),
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
