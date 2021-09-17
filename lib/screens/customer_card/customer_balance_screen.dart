import 'package:card_app/provider/auth_provider.dart';
import 'package:card_app/screens/customer_card/card_list_screen.dart';
import 'package:card_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerBalanceScreen extends StatefulWidget {
  const CustomerBalanceScreen({Key? key}) : super(key: key);

  @override
  _CustomerBalanceScreenState createState() => _CustomerBalanceScreenState();
}

class _CustomerBalanceScreenState extends State<CustomerBalanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
              onPressed: () {
                showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, size: 20))
        ],
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(children: [
            Container(
              width: double.infinity,
              child: Card(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(children: [
                      Row(children: [
                        Text('Name:', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 5),
                        Text(
                            Provider.of<AuthProvider>(context, listen: true)
                                .currentLoggedInUser
                                .custName,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500))
                      ]),
                      SizedBox(height: 10),
                      Row(children: [
                        Text('Current Balance:',
                            style: TextStyle(fontSize: 16)),
                        SizedBox(width: 5),
                        Text(
                            Provider.of<AuthProvider>(context, listen: true)
                                .currentLoggedInUser
                                .custBalance
                                .toString(),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown))
                      ])
                    ])),
              ),
            ),
            SizedBox(height: 50),
            Container(
              width: 200,
              height: 40,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.orange)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => CardListScreen(() {
                                setState(() {});
                              })));
                },
                child: const Text('Buy Cards', style: TextStyle(fontSize: 18)),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
