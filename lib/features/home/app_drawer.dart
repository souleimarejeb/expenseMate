// app_drawer.dart
import 'package:expensemate/routes/app_routes.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            child: DrawerHeader(
              decoration: BoxDecoration(color: const Color.fromARGB(255, 23, 21, 21)),
              child: Text('ExpenseMate', style: TextStyle(color: Colors.white, fontSize: 24)),
            
            ),
            height: MediaQuery.of(context).size.height*0.18,
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.black),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Home
            },
          ),
           ListTile(
            leading: Icon(Icons.wallet, color: Colors.black),
            title: Text('budgets'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Home
            },
           
            ),
             ListTile(
            leading: Icon(Icons.attach_money_sharp, color: Colors.black),
            title: Text('expenses'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.createBudget);
              // Navigate to Home
            },
            ),
             ListTile(
            leading: Icon(Icons.gif_box, color: Colors.black),
            title: Text('categorys'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Home
            },
            ),
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.black),
            title: Text('Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.black),
            title: Text('Settings'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
