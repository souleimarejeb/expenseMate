import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseInsightsCard extends StatelessWidget {
  final double totalExpenses;
  final double monthlyAverage;
  final double dailyAverage;
  final int totalTransactions;
  final String topCategory;
  final double topCategoryAmount;
  final double percentChange;
  final Map<String, double> categoryBreakdown;

  const ExpenseInsightsCard({
    Key? key,
    required this.totalExpenses,
    required this.monthlyAverage,
    required this.dailyAverage,
    required this.totalTransactions,
    required this.topCategory,
    required this.topCategoryAmount,
    required this.percentChange,
    required this.categoryBreakdown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '💡 Smart Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('MMM yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Top spending insight
            _buildInsightRow(
              icon: Icons.trending_up,
              title: 'Top Spending',
              value: topCategory,
              subtitle: '\$${topCategoryAmount.toStringAsFixed(2)}',
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            
            // Daily average
            _buildInsightRow(
              icon: Icons.calendar_today,
              title: 'Daily Average',
              value: '\$${dailyAverage.toStringAsFixed(2)}',
              subtitle: 'Per day',
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            
            // Monthly trend
            _buildInsightRow(
              icon: percentChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
              title: 'Monthly Trend',
              value: '${percentChange.abs().toStringAsFixed(1)}%',
              subtitle: percentChange >= 0 ? 'Increase' : 'Decrease',
              color: percentChange >= 0 ? Colors.red.shade200 : Colors.green.shade200,
            ),
            const SizedBox(height: 16),
            
            // Quick tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.yellow.shade300,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getSmartTip(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _getSmartTip() {
    if (percentChange > 20) {
      return 'Your spending increased significantly this month. Consider reviewing your expenses.';
    } else if (percentChange < -20) {
      return 'Great job! You\'ve reduced your spending this month. Keep it up!';
    } else if (dailyAverage > 50) {
      return 'Try setting a daily budget to better manage your expenses.';
    } else {
      return 'You\'re maintaining consistent spending habits. Track regularly to stay on course.';
    }
  }
}
