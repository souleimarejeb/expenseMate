import 'package:flutter/material.dart';

class ExpenseStatsGrid extends StatelessWidget {
  final int totalExpenses;
  final double averageExpense;
  final double highestExpense;
  final double lowestExpense;
  final int thisWeekCount;
  final double thisWeekTotal;
  final int thisMonthCount;
  final double thisMonthTotal;

  const ExpenseStatsGrid({
    Key? key,
    required this.totalExpenses,
    required this.averageExpense,
    required this.highestExpense,
    required this.lowestExpense,
    required this.thisWeekCount,
    required this.thisWeekTotal,
    required this.thisMonthCount,
    required this.thisMonthTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '📊 Statistics Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                title: 'Total Expenses',
                value: totalExpenses.toString(),
                icon: Icons.receipt_long,
                color: Colors.purple,
                gradient: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              _buildStatCard(
                title: 'Average',
                value: '\$${averageExpense.toStringAsFixed(2)}',
                icon: Icons.analytics,
                color: Colors.blue,
                gradient: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              _buildStatCard(
                title: 'Highest',
                value: '\$${highestExpense.toStringAsFixed(2)}',
                icon: Icons.arrow_upward,
                color: Colors.red,
                gradient: [Colors.red.shade400, Colors.red.shade600],
              ),
              _buildStatCard(
                title: 'Lowest',
                value: '\$${lowestExpense.toStringAsFixed(2)}',
                icon: Icons.arrow_downward,
                color: Colors.green,
                gradient: [Colors.green.shade400, Colors.green.shade600],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Period-based stats
          Row(
            children: [
              Expanded(
                child: _buildPeriodCard(
                  title: 'This Week',
                  count: thisWeekCount,
                  total: thisWeekTotal,
                  icon: Icons.calendar_view_week,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPeriodCard(
                  title: 'This Month',
                  count: thisMonthCount,
                  total: thisMonthTotal,
                  icon: Icons.calendar_month,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodCard({
    required String title,
    required int count,
    required double total,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
