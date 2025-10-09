import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart';
import 'package:expensemate/features/budget/widgets/budget_card.dart';
import 'package:expensemate/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AllBudgetsPage extends StatelessWidget {
  AllBudgetsPage({Key? key}) : super(key: key);

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

      // ✅ floating add button
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

      body: BudgetCard(budgets: budgets),
    );
  }
}