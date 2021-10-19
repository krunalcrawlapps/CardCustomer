import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/category_model.dart';
import 'package:card_app/models/price_model.dart';
import 'package:card_app/models/subcategory_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/screens/buy_screen/buy_screen.dart';
import 'package:card_app/utils/utils.dart';
import 'package:card_app/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectSubCategoryScreen extends StatefulWidget {
  final CategoryModel categoryModel;
  const SelectSubCategoryScreen(this.categoryModel, {Key? key})
      : super(key: key);

  @override
  _SelectSubCategoryScreenState createState() =>
      _SelectSubCategoryScreenState();
}

class _SelectSubCategoryScreenState extends State<SelectSubCategoryScreen> {
  final subCategoryRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.subcategory)
      .withConverter<SubCategoryModel>(
        fromFirestore: (snapshots, _) =>
            SubCategoryModel.fromJson(snapshots.data()!),
        toFirestore: (vendor, _) => vendor.toJson(),
      );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              "Select Sub Category",
              style: Theme.of(context).textTheme.headline4!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 5, bottom: 10),
            child: Text(
              "Select sub category of you want to buy",
              style: Theme.of(context).textTheme.headline3!.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<SubCategoryModel>>(
              stream: subCategoryRef
                  .where('category_id', isEqualTo: widget.categoryModel.catId)
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
                          onTap: () async {
                            try {
                              QuerySnapshot<PricesModel> prices =
                                  await DatabaseHelper.shared.fetchPrices(
                                      widget.categoryModel.vendorId,
                                      data.docs[index].data().catId,
                                      data.docs[index].data().subCatId,
                                      Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .currentLoggedInUser
                                          .custId);
                              SubCategoryModel _subCategoryModel =
                                  data.docs[index].data();
                              if (prices.docs.isNotEmpty) {
                                _subCategoryModel.amount =
                                    prices.docs.first.data().price;
                                _subCategoryModel.currency =
                                    prices.docs.first.data().currencyName;
                              }
                              Provider.of<AuthProvider>(context, listen: false)
                                  .setSelectedSubCategory(_subCategoryModel);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          BuyScreen()));
                            } catch (e) {
                              showAlert(context, e.toString());
                            }
                          },
                          child: getBuyImageCard(
                              data.docs[index].data().imageUrl)),
                      itemCount: data.size,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
