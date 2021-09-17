import 'package:card_app/database/database_helper.dart';
import 'package:card_app/models/customer_model.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  late CustomerModel _currentLoggedInUser;
  CustomerModel get currentLoggedInUser {
    return _currentLoggedInUser;
  }

  updateLoggedInUserData() async {
    _currentLoggedInUser = await DatabaseHelper.shared.getLoggedInUserModel()!;
    notifyListeners();
  }
}
