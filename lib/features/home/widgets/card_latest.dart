import 'package:flutter/material.dart';

class CardLatest extends StatefulWidget {
  @override
  _CardLatestState createState() => _CardLatestState();
}

class _CardLatestState extends State<CardLatest> {
  // Dummy data
  double totalAmount = 1520.75;

  List<Map<String, dynamic>> latestTransactions = [
    {'title': 'Groceries', 'amount': 45.0, 'category': 'Food'},
    {'title': 'Bus Ticket', 'amount': 2.5, 'category': 'Transport'},
    {'title': 'Movie', 'amount': 12.0, 'category': 'Entertainment'},
    {'title': 'Electricity Bill', 'amount': 60.0, 'category': 'Bills'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: EdgeInsets.only(top: 15),
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: latestTransactions.length,
        itemBuilder: (context, index) {
          final tx = latestTransactions[index];
          return Container(
            width: 170,
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tx['title'],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "\$${tx['amount'].toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tx['category'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
