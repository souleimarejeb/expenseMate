import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/expense_analytics_provider.dart';

class ExpenseTrendCard extends StatelessWidget {
  final ExpenseAnalyticsProvider provider;
  final DateTime selectedMonth;

  const ExpenseTrendCard({
    Key? key,
    required this.provider,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentMonthData = provider.getMonthlyData(selectedMonth);
    final previousMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
    final previousMonthData = provider.getMonthlyData(previousMonth);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (currentMonthData != null && previousMonthData != null) ...[
            _buildTrendComparison(currentMonthData, previousMonthData),
          ] else ...[
            const Text(
              'Not enough data to show trends',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildTrendComparison(MonthlyExpenseData current, MonthlyExpenseData previous) {
    final trend = current.getSpendingTrend(previous);
    final isIncrease = trend > 0;
    final trendColor = isIncrease ? Colors.red : Colors.green;
    final trendIcon = isIncrease ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: trendColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: trendColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              trendIcon,
              color: trendColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isIncrease ? '+' : ''}${trend.toStringAsFixed(1)}% from last month',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: trendColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isIncrease ? 'Increased' : 'Decreased'} by \$${(current.totalAmount - previous.totalAmount).abs().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickStatItem(
                'This Month',
                DateFormat('MMM yyyy').format(selectedMonth),
                provider.getMonthlyData(selectedMonth)?.totalAmount ?? 0,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatItem(
                'Last Month',
                DateFormat('MMM yyyy').format(DateTime(selectedMonth.year, selectedMonth.month - 1)),
                provider.getMonthlyData(DateTime(selectedMonth.year, selectedMonth.month - 1, 1))?.totalAmount ?? 0,
                Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickStatItem(
                'Average',
                'Per day',
                provider.getMonthlyData(selectedMonth)?.averagePerDay ?? 0,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatItem(
                'Highest',
                'Single expense',
                _getHighestExpense(),
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatItem(String title, String subtitle, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  double _getHighestExpense() {
    final monthlyData = provider.getMonthlyData(selectedMonth);
    if (monthlyData == null || monthlyData.expenses.isEmpty) return 0;
    
    return monthlyData.expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
  }
}