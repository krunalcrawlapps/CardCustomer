import 'dart:convert';

import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/models/card_model.dart';
import 'package:card_app/models/customer_model.dart';
import 'package:card_app/models/order_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseCollectionConstant {
  static const admins = 'Admins';
  static const customer = 'Customers';
  static const cards = 'Cards';
  static const orders = 'Orders';
  static const vendors = 'Vendors';
  static const transactions = 'Transactions';
  static const category = 'Category';
  static const subcategory = 'SubCategory';
}

class DatabaseHelper {
  static DatabaseHelper _instance = DatabaseHelper._();
  DatabaseHelper._();
  static DatabaseHelper get shared => _instance;

  late FirebaseFirestore _fireStore;
  late FirebaseAuth _auth;
  late SharedPreferences pref;

  initDatabase() async {
    _fireStore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    pref = await SharedPreferences.getInstance();
  }

  ///Login
  Future<User?> doLogin(String email, String password) async {
    try {
      UserCredential? userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  Future<bool> _changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
          email: user?.email ?? '', password: currentPassword);
      UserCredential? userCred = await user?.reauthenticateWithCredential(cred);
      userCred?.user?.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  ///Login User Data
  saveUserModel(CustomerModel user, BuildContext context) async {
    String userStr = jsonEncode(user);
    pref.setString(SharedPrefConstant.user_data, userStr);
    Provider.of<AuthProvider>(context, listen: false).updateLoggedInUserData();
  }

  Future<CustomerModel?> getUserDataFromFirebase(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> result = await _fireStore
        .collection(FirebaseCollectionConstant.customer)
        .doc(userId)
        .get();
    Map<String, dynamic>? data = result.data();
    if (data != null) {
      return CustomerModel.fromJson(data);
    } else {
      return null;
    }
  }

  CustomerModel? getLoggedInUserModel() {
    String? userStr = pref.getString(SharedPrefConstant.user_data);

    if (userStr != null) {
      Map<String, dynamic> json = jsonDecode(userStr);
      return CustomerModel.fromJson(json);
    }
    return null;
  }

  clearUserData() {
    _auth.signOut();
    pref.clear();
  }

  ///Order
  addOrderData(OrderModel order) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.orders)
          .doc(order.orderId)
          .set({
        'order_id': order.orderId,
        'transaction_date': order.transactionDateTime,
        'admin_id': order.adminId,
        'cust_id': order.custId,
        'cust_name': order.custName,
        'card_ids': order.arrCards
      });
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  updateCardStatus(String cardId) async {
    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.cards)
          .doc(cardId)
          .update({'card_status': CardStatus.used});
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  updateCustBalance(double remainBalance, BuildContext context) async {
    CustomerModel? cust = getLoggedInUserModel();
    cust?.custBalance = remainBalance;
    saveUserModel(cust!, context);

    try {
      await _fireStore
          .collection(FirebaseCollectionConstant.customer)
          .doc(cust.custId)
          .update({'cust_balance': remainBalance});
    } on FirebaseAuthException catch (error) {
      throw error.message ?? ErrorMessage.something_wrong;
    }
  }

  Future<CardModel?> getCardFromId(String cardId) async {
    DocumentSnapshot<Map<String, dynamic>> result = await _fireStore
        .collection(FirebaseCollectionConstant.cards)
        .doc(cardId)
        .get();
    Map<String, dynamic>? data = result.data();
    if (data != null) {
      return CardModel.fromJson(data);
    } else {
      return null;
    }
  }

  updateCustomer(
      String oldPwd, CustomerModel customer, BuildContext context) async {
    if (customer.custPassword != oldPwd) {
      //update password
      bool isSuccess = await _changePassword(oldPwd, customer.custPassword);
      if (isSuccess) {
        try {
          await _fireStore
              .collection(FirebaseCollectionConstant.customer)
              .doc(customer.custId)
              .update({
            'cust_name': customer.custName,
            'cust_address': customer.custAddress,
            'cust_password': customer.custPassword,
          });
        } on FirebaseAuthException catch (error) {
          throw error.message ?? ErrorMessage.something_wrong;
        }
      }
    } else {
      //password not change update other details
      try {
        await _fireStore
            .collection(FirebaseCollectionConstant.customer)
            .doc(customer.custId)
            .update({
          'cust_name': customer.custName,
          'cust_address': customer.custAddress,
        });
      } on FirebaseAuthException catch (error) {
        throw error.message ?? ErrorMessage.something_wrong;
      }
    }

    saveUserModel(customer, context);
  }

  Future<List<CardModel>> getVendorWiseCards(
      String vendorId, String catId, String subCatId) async {
    var collection = _fireStore
        .collection(FirebaseCollectionConstant.cards)
        .where('vendor_id', isEqualTo: vendorId)
        .where('category_id', isEqualTo: catId)
        .where('subCatId', isEqualTo: subCatId)
        .where('card_status', isEqualTo: CardStatus.available);
    var querySnapshot = await collection.get();

    List<CardModel> arrCards = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      CardModel model = CardModel.fromJson(data);
      arrCards.add(model);
    }

    arrCards.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return arrCards;
  }
}
