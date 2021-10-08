import 'package:card_app/screens/customer/customer_balance_screen.dart';
import 'package:card_app/screens/direct_charge/direct_charge_orders.dart';
import 'package:card_app/screens/orders/order_screen.dart';
import 'package:card_app/screens/profile_screen.dart';
import 'package:card_app/screens/vendors/drawer_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // int _selectedIndex = 0;
  // static const List<Widget> _widgetOptions = <Widget>[
  //   CustomerBalanceScreen(),
  //   OrdersScreen(),
  //   DirectChargeOrders(),
  //   ProfileScreen()
  // ];

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.orange),
      ),
      drawer: ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
        child: Drawer(
          child: DrawerScreen(),
        ),
      ),
      body: Center(
        child: CustomerBalanceScreen(),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart_sharp),
      //       label: 'Orders',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.add_shopping_cart),
      //       label: 'Direct Charge',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.account_circle),
      //       label: 'My Profile',
      //     )
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.amber[800],
      //   onTap: _onItemTapped,
      // ),
    );
  }
}
