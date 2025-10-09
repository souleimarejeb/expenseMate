import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart';

class BudgetCard extends StatelessWidget {
  final List<Budget> budgets;

  const BudgetCard({
    Key? key,
    required this.budgets,
  }) : super(key: key);

  Color _getStatusColor(Budget budget) {
    switch (budget.status) {
      case BudgetStatus.exceeded:
        return Colors.red;
      case BudgetStatus.nearLimit:
        return Colors.orange;
      case BudgetStatus.ok:
      default:
        return const Color.fromARGB(255, 67, 130, 67);
    }
  }

  double _getProgressValue(Budget budget) {
    return budget.spentAmount / budget.limitAmount; // Calculate the usage percentage
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        final double percentUsed = _getProgressValue(budget);

        Color statusColor = _getStatusColor(budget);

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
              ),
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
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    "Updated: ${DateFormat.yMd().format(budget.updatedAt)}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
