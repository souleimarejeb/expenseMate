import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyProgressChart extends StatelessWidget {
  final List<Budget> budgets;

  const MonthlyProgressChart({Key? key, required this.budgets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Group budgets by month and calculate monthly totals
    final monthlyData = <int, Map<String, double>>{};
    for (var budget in budgets) {
      if (!monthlyData.containsKey(budget.month)) {
        monthlyData[budget.month] = {'limit': 0.0, 'spent': 0.0};
      }
      monthlyData[budget.month]!['limit'] = monthlyData[budget.month]!['limit']! + budget.limitAmount;
      monthlyData[budget.month]!['spent'] = monthlyData[budget.month]!['spent']! + budget.spentAmount;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Monthly Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ...monthlyData.entries.map((entry) {
              final month = entry.key;
              final limit = entry.value['limit']!;
              final spent = entry.value['spent']!;
              final percentage = limit > 0 ? (spent / limit * 100) : 0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime(2025, month)),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              percentage > 100 ? Colors.red : 
                              percentage > 80 ? Colors.orange : Colors.green
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Spent: \$${spent.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          "Limit: \$${limit.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
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