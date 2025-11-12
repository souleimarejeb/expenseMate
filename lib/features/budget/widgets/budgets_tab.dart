import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/features/budget/widgets/budget_list_item.dart';
import 'package:flutter/material.dart';

class BudgetsTab extends StatelessWidget {
  final List<Budget> budgets;
  final Function(Budget) onBudgetAdded;

  const BudgetsTab({
    Key? key,
    required this.budgets,
    required this.onBudgetAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return budgets.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No budgets yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap the + button to create your first budget",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return BudgetListItem(budget: budget); // This is the tappable widget
            },
          );
  }
}