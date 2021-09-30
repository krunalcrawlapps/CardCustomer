import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/category_model.dart';
import 'package:card_app/models/subcategory_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/screens/buy_screen/buy_screen.dart';
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
      appBar: AppBar(title: Text('Select Sub Category')),
      body: StreamBuilder<QuerySnapshot<SubCategoryModel>>(
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
                    onTap: () {
                      Provider.of<AuthProvider>(context, listen: false)
                          .setSelectedSubCategory(data.docs[index].data());
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => BuyScreen()));
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
