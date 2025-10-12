import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart';
import 'package:expensemate/features/budget/widgets/budget_card.dart';
import 'package:expensemate/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AllBudgetsPage extends StatefulWidget {
  @override
  _AllBudgetsPageState createState() => _AllBudgetsPageState();
}

class _AllBudgetsPageState extends State<AllBudgetsPage> {
  String selectedStatus = "All";
  bool isAscending = true;

  final List<Budget> budgets = [
    Budget(
      limitAmount: 500,
      spentAmount: 200,
      status: BudgetStatus.ok,
      createdAt: DateTime(2025, 9, 1),
      updatedAt: DateTime(2025, 9, 5),
      month: 9,
    ),
    Budget(
      limitAmount: 300,
      spentAmount: 290,
      status: BudgetStatus.nearLimit,
      createdAt: DateTime(2025, 9, 2),
      updatedAt: DateTime(2025, 9, 10),
      month: 9,
    ),
    Budget(
      limitAmount: 100,
      spentAmount: 120,
      status: BudgetStatus.exceeded,
      createdAt: DateTime(2025, 9, 3),
      updatedAt: DateTime(2025, 9, 8),
      month: 9,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('All Budgets', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filter Dropdown
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, 
                        size: 20, 
                        color: Colors.black.withOpacity(0.7)
                      ),
                      SizedBox(width: 8),
                      DropdownButton<String>(
                        value: selectedStatus,
                        underline: SizedBox(),
                        icon: Icon(Icons.keyboard_arrow_down, 
                          color: Colors.black.withOpacity(0.7)
                        ),
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedStatus = newValue!;
                          });
                        },
                        items: ["All", "Ok", "Near Limit", "Exceeded"]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                // Sort Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isAscending = !isAscending;
                      });
                    },
                    icon: AnimatedRotation(
                      turns: isAscending ? 0 : 0.5,
                      duration: Duration(milliseconds: 300),
                      child: Icon(
                        Icons.sort,
                        color: Colors.white,
                      ),
                    ),
                    tooltip: isAscending ? 'Sort Ascending' : 'Sort Descending',
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: BudgetCard(budgets: budgets),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createBudget);
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Budget",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}