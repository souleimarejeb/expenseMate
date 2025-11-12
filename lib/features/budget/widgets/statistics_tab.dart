import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/features/budget/widgets/charts/category_spending_chart.dart';
import 'package:expensemate/features/budget/widgets/charts/status_distribution_chart.dart';
import 'package:expensemate/features/budget/widgets/charts/monthly_progress_chart.dart';
import 'package:flutter/material.dart';

class StatisticsTab extends StatelessWidget {
  final List<Budget> budgets;

  const StatisticsTab({Key? key, required this.budgets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    final totalLimit = budgets.fold(0.0, (sum, budget) => sum + budget.limitAmount);
    final totalSpent = budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
    final totalRemaining = totalLimit - totalSpent;
    final averageUsage = budgets.isNotEmpty 
        ? budgets.fold(0.0, (sum, budget) => sum + budget.percentageUsed) / budgets.length 
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCard(totalLimit, totalSpent, totalRemaining, averageUsage),
          
          const SizedBox(height: 24),
          
          // Budget Status Distribution
          StatusDistributionChart(budgets: budgets),
          
          const SizedBox(height: 24),
          
          // Spending by Category
          CategorySpendingChart(budgets: budgets),
          
          const SizedBox(height: 24),
          
          // Monthly Progress
          MonthlyProgressChart(budgets: budgets),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalLimit, double totalSpent, double totalRemaining, double averageUsage) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Financial Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Total Limit", "\$${totalLimit.toStringAsFixed(2)}", Icons.account_balance_wallet),
                _buildStatItem("Total Spent", "\$${totalSpent.toStringAsFixed(2)}", Icons.money_off),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Remaining", "\$${totalRemaining.toStringAsFixed(2)}", 
                    totalRemaining >= 0 ? Icons.trending_up : Icons.trending_down),
                _buildStatItem("Avg Usage", "${averageUsage.toStringAsFixed(1)}%", Icons.percent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.black),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}