import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:flutter/material.dart';

class CategorySpendingChart extends StatelessWidget {
  final List<Budget> budgets;

  const CategorySpendingChart({Key? key, required this.budgets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Category breakdown
    final categorySpending = <String, double>{};
    for (var budget in budgets) {
      final category = budget.category ?? 'Uncategorized';
      categorySpending[category] = (categorySpending[category] ?? 0) + budget.spentAmount;
    }

    final totalSpent = budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Spending by Category",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ...categorySpending.entries.map((entry) {
              final percentage = totalSpent > 0 ? (entry.value / totalSpent * 100) : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          "${percentage.toStringAsFixed(1)}%",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${entry.value.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}