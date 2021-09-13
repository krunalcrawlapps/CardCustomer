import 'dart:convert';

import 'package:card_app/constant/app_constant.dart';
import 'package:card_app/models/card_model.dart';
import 'package:card_app/models/customer_model.dart';
import 'package:card_app/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseCollectionConstant {
  static const admins = 'Admins';
  static const customer = 'Customers';
  static const cards = 'Cards';
  static const orders = 'Orders';
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

  ///Login User Data
  saveUserModel(CustomerModel user) async {
    String userStr = jsonEncode(user);
    pref.setString(SharedPrefConstant.user_data, userStr);
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
        'card_id': order.cardId,
        'transaction_date': order.transactionDateTime,
        'admin_id': order.adminId,
        'cust_id': order.custId,
        'card_vendor': order.cardVendor,
        'card_number': order.cardNumber,
        'cust_name': order.custName,
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

  updateCustBalance(double remainBalance) async {
    CustomerModel? cust = getLoggedInUserModel();
    cust?.custBalance = remainBalance;
    saveUserModel(cust!);

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
}
