import 'package:expensemate/features/home/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user/providers/user_provider.dart';
import '../user/models/user_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dummy data
  double totalAmount = 1520.75;

  List<Map<String, dynamic>> latestTransactions = [
    {'title': 'Groceries', 'amount': 45.0, 'category': 'Food'},
    {'title': 'Bus Ticket', 'amount': 2.5, 'category': 'Transport'},
    {'title': 'Movie', 'amount': 12.0, 'category': 'Entertainment'},
    {'title': 'Electricity Bill', 'amount': 60.0, 'category': 'Bills'},
  ];

  List<Map<String, dynamic>> monthlyCategorySpending = [
    {'category': 'Food', 'amount': 300},
    {'category': 'Transport', 'amount': 120},
    {'category': 'Entertainment', 'amount': 80},
    {'category': 'Bills', 'amount': 250},
    {'category': 'Shopping', 'amount': 150},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0), // Modern blue background
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Open menu',
          ),
        ),
        title: Text(
          'ExpenseMate',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () async {
              // Test user CRUD operations
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              
              final testUser = UserModel(
                firstName: 'Test',
                lastName: 'User',
                email: 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
                phone: '+1234567890',
                bio: 'Test user for CRUD verification',
                occupation: 'Tester',
                monthlyIncome: 1000.0,
              );
              
              print('Creating test user...');
              final success = await userProvider.createUser(testUser);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success 
                      ? 'Test user created successfully! Total users: ${userProvider.users.length}'
                      : 'Failed to create user: ${userProvider.error}',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
              
              if (success) {
                print('User created: ${userProvider.currentUser?.firstName}');
                print('Total users in database: ${userProvider.users.length}');
              }
            },
          ),
        ],
      ),
       drawer: AppDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section: Total Amount
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1565C0), // Match AppBar color
                    const Color(0xFF1976D2), // Slightly lighter blue
                  ],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 18)),
                  SizedBox(height: 5),
                  Text("\$${totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.white),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                        hintText: "Search transactions",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            // Latest Transactions (scrollable row)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Latest Transactions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  SizedBox(height: 10),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: latestTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = latestTransactions[index];
                        return Container(
                          width: 200,
                          margin: EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(tx['title'],
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                              SizedBox(height: 10),
                              Text("\$${tx['amount'].toStringAsFixed(2)}",
                                  style: TextStyle(fontSize: 20, color: Colors.black)),
                              SizedBox(height: 5),
                              Text(tx['category'], style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 30),

                  // Monthly Spending per Category
                 
                  Container(
                    child: SingleChildScrollView(
                      child:    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monthly Spending by Category',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          SizedBox(height: 10),
                          ...monthlyCategorySpending.map((cat) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(cat['category'], style: TextStyle(color: Colors.black)),
                                  Text("\$${cat['amount']}", style: TextStyle(color: Colors.black)),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                   
                  ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
