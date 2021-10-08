import 'package:card_app/models/customer_model.dart';
import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/screens/direct_charge/direct_charge_orders.dart';
import 'package:card_app/screens/orders/order_screen.dart';
import 'package:card_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          title: Text("Home"),
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
          title: Text("Orders"),
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
          title: Text("Direct Charge"),
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
          title: Text("My Profile"),
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
          title: Text("Logout"),
          trailing: Icon(Icons.chevron_right),
        ),
        Divider(),
      ],
    );
  }
}
