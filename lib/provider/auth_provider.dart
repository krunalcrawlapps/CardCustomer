import 'dart:convert';

import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/category_model.dart';
import 'package:card_app/models/customer_model.dart';
import 'package:card_app/models/subcategory_model.dart';
import 'package:card_app/models/vendor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  late CustomerModel _currentLoggedInUser;
  CustomerModel get currentLoggedInUser {
    return _currentLoggedInUser;
  }

  late VendorModel _selectedVendor;
  VendorModel get selectedVendor {
    return _selectedVendor;
  }

  late CategoryModel _selectedCategory;
  CategoryModel get selectedCategory {
    return _selectedCategory;
  }

  late SubCategoryModel _selectedSubCategory;
  SubCategoryModel get selectedSubCategory {
    return _selectedSubCategory;
  }

  updateLoggedInUserData() async {
    _registerUserInfoListener();
    _currentLoggedInUser = await DatabaseHelper.shared.getLoggedInUserModel()!;
    notifyListeners();
  }

  _registerUserInfoListener() async {
    FirebaseFirestore.instance
        .collection(FirebaseCollectionConstant.customer)
        .doc(DatabaseHelper.shared.getLoggedInUserModel()!.custId)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) async {
      Map<String, dynamic> data =
          documentSnapshot.data()! as Map<String, dynamic>;
      CustomerModel model = CustomerModel.fromJson(data);
      String userStr = jsonEncode(model);
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString(SharedPrefConstant.user_data, userStr);

      _currentLoggedInUser =
          await DatabaseHelper.shared.getLoggedInUserModel()!;
      notifyListeners();
    }).onError((e) => print(e));
  }

  setSelectedVendor(VendorModel model) {
    _selectedVendor = model;
  }

  setSelectedCategory(CategoryModel model) {
    _selectedCategory = model;
  }

  setSelectedSubCategory(SubCategoryModel model) {
    _selectedSubCategory = model;
  }
}
