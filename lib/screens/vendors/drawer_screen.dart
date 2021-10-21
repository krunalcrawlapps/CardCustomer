import 'package:card_app/models/customer_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/provider/language_provider.dart';
import 'package:card_app/screens/direct_charge/direct_charge_orders.dart';
import 'package:card_app/screens/orders/order_screen.dart';
import 'package:card_app/utils/in_app_translation.dart';
import 'package:card_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../profile_screen.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  CustomerModel? customerModel;

  @override
  void initState() {
    super.initState();
    customerModel =
        Provider.of<AuthProvider>(context, listen: false).currentLoggedInUser;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // User info...
        UserAccountsDrawerHeader(
          accountName: Text(customerModel?.custName ?? "-",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          accountEmail: Text(
            customerModel?.custEmail ?? "-",
            style: TextStyle(color: Colors.white),
          ),
          currentAccountPicture: CircleAvatar(
            child: Text(
              (customerModel?.custName ?? "").characters.first,
              style: TextStyle(fontSize: 40.0),
            ),
          ),
        ),
        // Home...
        ListTile(
          onTap: () {
            Navigator.of(context).pop();
          },
          leading: Icon(
            Icons.home,
            color: Colors.orange,
          ),
          title: Text(AppTranslations.of(context)!.text("Home")),
          trailing: Icon(Icons.chevron_right),
        ),
        Divider(),
        // Orders
        ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => OrdersScreen(),
              ),
            );
          },
          leading: Icon(
            Icons.shopping_cart,
            color: Colors.orange,
          ),
          title: Text(AppTranslations.of(context)!.text("Orders")),
          trailing: Icon(Icons.chevron_right),
        ),
        Divider(),
        // Direct charge...
        ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => DirectChargeOrders(),
              ),
            );
          },
          leading: Icon(
            Icons.add_shopping_cart,
            color: Colors.orange,
          ),
          title: Text(AppTranslations.of(context)!.text("Direct Charge")),
          trailing: Icon(Icons.chevron_right),
        ),
        Divider(),
        // My profile...
        ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => ProfileScreen(),
              ),
            );
          },
          leading: Icon(
            Icons.face_sharp,
            color: Colors.orange,
          ),
          title: Text(AppTranslations.of(context)!.text("My Profile")),
          trailing: Icon(Icons.chevron_right),
        ),
        Divider(),
        // Change Language...
        ListTile(
          onTap: () {
            buildLanguageDialog(context);
          },
          leading: Icon(
            Icons.language,
            color: Colors.orange,
          ),
          title: Text(AppTranslations.of(context)!.text("Choose Your Language")),
          trailing: Icon(Icons.chevron_right),
        ),
        Divider(),
        // Logout...
        ListTile(
          onTap: () {
            showLogoutDialog(context);
          },
          leading: Icon(
            Icons.logout,
            color: Colors.orange,
          ),
          title: Text(AppTranslations.of(context)!.text("Logout")),
          trailing: Icon(Icons.chevron_right),
        ),
        Divider(),
      ],
    );
  }

  buildLanguageDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: Text( AppTranslations.of(context)!
                            .text('Choose Your Language')),
            content: Container(
              width: double.maxFinite,
              child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Text( AppTranslations.of(context)!
                            .text(locale[index]['name'])),
                        onTap: () {
                          print(locale[index]['name']);
                          updateLanguage(locale[index]['locale'], context);
                        },
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: locale.length),
            ),
          );
        });
  }

  final List locale = [
    {'name': 'English', 'locale': SuppotedLanguage.english},
    {'name': 'Arabic', 'locale': SuppotedLanguage.arabic},
  ];

  updateLanguage(String locale, BuildContext context) {
    Navigator.of(context).pop();
    Provider.of<LanguageProvider>(context, listen: false).locale =
        locale;
  }
}
