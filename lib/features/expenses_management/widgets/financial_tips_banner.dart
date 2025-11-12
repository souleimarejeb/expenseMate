import 'package:flutter/material.dart';
import 'dart:math';

class FinancialTipsBanner extends StatelessWidget {
  final double totalExpenses;
  final double monthlyChange;
  final int expenseCount;
  final String topCategory;

  const FinancialTipsBanner({
    Key? key,
    required this.totalExpenses,
    required this.monthlyChange,
    required this.expenseCount,
    required this.topCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tip = _getFinancialTip();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.orange.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tip['icon'] as IconData,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['message'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getFinancialTip() {
    // Generate contextual tips based on spending patterns
    final tips = <Map<String, dynamic>>[];

    if (monthlyChange > 30) {
      tips.add({
        'icon': Icons.warning_amber_rounded,
        'title': 'High Spending Alert',
        'message': 'Your expenses increased by ${monthlyChange.toStringAsFixed(0)}%. Consider reviewing your budget.',
      });
    }

    if (monthlyChange < -20) {
      tips.add({
        'icon': Icons.celebration,
        'title': 'Excellent Progress!',
        'message': 'You\'ve reduced spending by ${monthlyChange.abs().toStringAsFixed(0)}%. Keep up the great work!',
      });
    }

    if (totalExpenses > 1000) {
      tips.add({
        'icon': Icons.savings,
        'title': 'Savings Opportunity',
        'message': 'Try the 50/30/20 rule: 50% needs, 30% wants, 20% savings.',
      });
    }

    if (expenseCount > 50) {
      tips.add({
        'icon': Icons.analytics,
        'title': 'Track Regularly',
        'message': 'You have many transactions. Set up categories to better track where your money goes.',
      });
    }

    if (topCategory.toLowerCase() != 'none') {
      tips.add({
        'icon': Icons.pie_chart,
        'title': 'Category Insight',
        'message': 'Most spending in $topCategory. Look for ways to optimize this category.',
      });
    }

    // Default tips if no specific conditions are met
    if (tips.isEmpty) {
      final defaultTips = [
        {
          'icon': Icons.lightbulb_outline,
          'title': 'Smart Saving Tip',
          'message': 'Set aside 10% of each expense for emergency savings.',
        },
        {
          'icon': Icons.trending_down,
          'title': 'Reduce Expenses',
          'message': 'Review subscriptions monthly to cut unnecessary costs.',
        },
        {
          'icon': Icons.calendar_today,
          'title': 'Budget Planning',
          'message': 'Plan your monthly budget at the start of each month.',
        },
        {
          'icon': Icons.credit_card,
          'title': 'Payment Strategy',
          'message': 'Use cash for daily expenses to increase awareness of spending.',
        },
      ];
      tips.add(defaultTips[Random().nextInt(defaultTips.length)]);
    }

    return tips[Random().nextInt(tips.length)];
  }
}
