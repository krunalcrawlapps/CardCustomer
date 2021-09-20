import 'dart:convert';

import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/customer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  late CustomerModel _currentLoggedInUser;
  CustomerModel get currentLoggedInUser {
    return _currentLoggedInUser;
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
}
