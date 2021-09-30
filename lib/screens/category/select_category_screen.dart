import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/category_model.dart';
import 'package:card_app/models/vendor_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/screens/direct_charge/direct_charge_screen.dart';
import 'package:card_app/screens/subcategory/select_subcategory_screen.dart';
import 'package:card_app/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectCategoryScreen extends StatefulWidget {
  final VendorModel vendorModel;
  const SelectCategoryScreen(this.vendorModel, {Key? key}) : super(key: key);

  @override
  _SelectCategoryScreenState createState() => _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends State<SelectCategoryScreen> {
  final categoryRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.category)
      .withConverter<CategoryModel>(
        fromFirestore: (snapshots, _) =>
            CategoryModel.fromJson(snapshots.data()!),
        toFirestore: (vendor, _) => vendor.toJson(),
      );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Select Category')),
      body: StreamBuilder<QuerySnapshot<CategoryModel>>(
        stream: categoryRef
            .where('vendor_id', isEqualTo: widget.vendorModel.vendorId)
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

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: width / (height / 1.7),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemBuilder: (_, index) => InkWell(
                    onTap: () {
                      Provider.of<AuthProvider>(context, listen: false)
                          .setSelectedCategory(data.docs[index].data());

                      if (widget.vendorModel.isDirectCharge) {
                        //direct charge
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    DirectChargeScreen()));
                      } else {
                        //prepaid charge
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    SelectSubCategoryScreen(
                                        data.docs[index].data())));
                      }
                    },
                    child: getBuyImageCard(data.docs[index].data().imageUrl)),
                itemCount: data.size,
              ),
            ),
          );
        },
      ),
    );
  }
}
