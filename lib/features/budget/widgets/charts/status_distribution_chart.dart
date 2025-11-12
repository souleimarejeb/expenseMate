import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart'; // Add this import
import 'package:flutter/material.dart';

class StatusDistributionChart extends StatelessWidget {
  final List<Budget> budgets;

  const StatusDistributionChart({Key? key, required this.budgets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusCounts = {
      'On Track': budgets.where((b) => b.status == BudgetStatus.ok).length,
      'Near Limit': budgets.where((b) => b.status == BudgetStatus.nearLimit).length,
      'Exceeded': budgets.where((b) => b.status == BudgetStatus.exceeded).length,
    };

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Budget Status",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ...statusCounts.entries.map((entry) {
              final color = entry.key == 'On Track' ? Colors.green 
                : entry.key == 'Near Limit' ? Colors.orange 
                : Colors.red;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    Text(
                      "${entry.value} budgets",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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