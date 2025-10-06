import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart';
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

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          final double percentUsed = budget.percentageUsed / 100;

          Color statusColor;
          switch (budget.status) {
            case BudgetStatus.exceeded:
              statusColor = Colors.red;
              break;
            case BudgetStatus.nearLimit:
              statusColor = Colors.orange;
              break;
            case BudgetStatus.ok:
            default:
              statusColor = Colors.black;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month + Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat.MMMM().format(DateTime(0, budget.month)),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      budget.status.name.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Limit / Spent
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Limit: \$${budget.limitAmount.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.black87)),
                    Text("Spent: \$${budget.spentAmount.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 10),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentUsed > 1 ? 1 : percentUsed,
                    minHeight: 10,
                    color: statusColor,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 10),

                // Dates
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Created: ${DateFormat.yMd().format(budget.createdAt)}",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      "Updated: ${DateFormat.yMd().format(budget.updatedAt)}",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}