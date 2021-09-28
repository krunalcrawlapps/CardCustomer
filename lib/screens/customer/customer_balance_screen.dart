import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/vendor_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/screens/category/select_category_screen.dart';
import 'package:card_app/screens/vendors/vendor_list_screen.dart';
import 'package:card_app/utils/utils.dart';
import 'package:card_app/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerBalanceScreen extends StatefulWidget {
  const CustomerBalanceScreen({Key? key}) : super(key: key);

  @override
  _CustomerBalanceScreenState createState() => _CustomerBalanceScreenState();
}

class _CustomerBalanceScreenState extends State<CustomerBalanceScreen> {
  final vendorRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.vendors)
      .withConverter<VendorModel>(
        fromFirestore: (snapshots, _) =>
            VendorModel.fromJson(snapshots.data()!),
        toFirestore: (vendor, _) => vendor.toJson(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
              onPressed: () {
                showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, size: 20))
        ],
      ),
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
            SizedBox(height: 20),
            getFixCard(),
            SizedBox(height: 20),
            getVendors()
          ]),
        ),
      ),
    );
  }

  Widget getFixCard() {
    return Container(
      height: MediaQuery.of(context).size.width / 2 - 30,
      child: Row(children: [
        Expanded(
          child: getCardForImageName(
              ImageConstant.prepaidCard_img, 'Prepaid Cards', () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => VendorListScreen()));
          }),
        ),
        SizedBox(width: 10),
        Expanded(
            child: getCardForImageName(
                ImageConstant.direcCharge_img, 'Direct Charge', () {})),
      ]),
    );
  }

  Widget getVendors() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return StreamBuilder<QuerySnapshot<VendorModel>>(
      stream: vendorRef.snapshots(),
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

        return Expanded(
            child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: width / (height / 1.7),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemBuilder: (_, index) => InkWell(
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false)
                    .setSelectedVendor(data.docs[index].data());
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            SelectCategoryScreen(data.docs[index].data())));
              },
              child: getImageCard(data.docs[index].data().imageUrl)),
          itemCount: data.size,
        ));
      },
    );
  }
}
