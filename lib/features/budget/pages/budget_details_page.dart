import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetDetailsPage extends StatelessWidget {
  final Budget budget;

  const BudgetDetailsPage({Key? key, required this.budget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = budget.spentAmount / budget.limitAmount;
    final remaining = budget.remaining;
    final percentageUsed = budget.percentageUsed;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Budget Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 24),
            
            // Progress Section
            _buildProgressSection(progress, percentageUsed),
            const SizedBox(height: 24),
            
            // Financial Breakdown
            _buildFinancialBreakdown(),
            const SizedBox(height: 24),
            
            // Additional Information
            _buildAdditionalInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;
    String statusText = "On Track";

    if (budget.status == BudgetStatus.nearLimit) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusText = "Near Limit";
    } else if (budget.status == BudgetStatus.exceeded) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = "Exceeded";
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    budget.category ?? "Uncategorized",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 14,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Month: ${DateFormat('MMMM yyyy').format(DateTime(2025, budget.month))}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(double progress, double percentageUsed) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Budget Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 1.0 ? Colors.red : 
                progress > 0.8 ? Colors.orange : Colors.green,
              ),
              minHeight: 16,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Progress",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "${percentageUsed.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialBreakdown() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Financial Breakdown",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildFinancialItem(
              icon: Icons.account_balance_wallet,
              title: "Budget Limit",
              amount: budget.limitAmount,
              color: Colors.black,
            ),
            const SizedBox(height: 12),
            _buildFinancialItem(
              icon: Icons.money_off,
              title: "Amount Spent",
              amount: budget.spentAmount,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildFinancialItem(
              icon: budget.remaining >= 0 ? Icons.trending_up : Icons.trending_down,
              title: "Remaining",
              amount: budget.remaining.abs(),
              color: budget.remaining >= 0 ? Colors.green : Colors.red,
              isRemaining: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem({
    required IconData icon,
    required String title,
    required double amount,
    required Color color,
    bool isRemaining = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
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
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isRemaining && budget.remaining < 0 
                    ? "-\$${amount.toStringAsFixed(2)}"
                    : "\$${amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (isRemaining)
            Text(
              budget.remaining >= 0 ? "Under Budget" : "Over Budget",
              style: TextStyle(
                fontSize: 12,
                color: budget.remaining >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Additional Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.calendar_today,
              title: "Created",
              value: DateFormat('MMM dd, yyyy').format(budget.createdAt),
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.update,
              title: "Last Updated",
              value: DateFormat('MMM dd, yyyy').format(budget.updatedAt),
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.date_range,
              title: "Budget Month",
              value: DateFormat('MMMM yyyy').format(DateTime(2025, budget.month)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}