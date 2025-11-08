import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/budget_tracking_provider.dart';

class CategoryBreakdownCard extends StatelessWidget {
  final MonthlyBudgetData? monthlyData;

  const CategoryBreakdownCard({
    Key? key,
    required this.monthlyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (monthlyData == null || monthlyData!.categorySpending.isEmpty) {
      return _buildEmptyState();
    }

    final sortedCategories = monthlyData!.categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Category Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  '${sortedCategories.length} categories',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          ...sortedCategories.map((entry) => _buildCategoryItem(entry)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'No categories to display',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(MapEntry<String, double> categoryEntry) {
    final categoryId = categoryEntry.key;
    final amount = categoryEntry.value;
    final budget = monthlyData!.categoryBudgets[categoryId] ?? 0.0;
    final percentage = budget > 0 ? (amount / budget) : 0.0;
    final totalSpent = monthlyData!.totalSpent;
    final spendingPercentage = totalSpent > 0 ? (amount / totalSpent) * 100 : 0.0;

    final category = _getCategoryInfo(categoryId);
    
    Color statusColor;
    String statusText;
    if (percentage > 1.0) {
      statusColor = Colors.red;
      statusText = 'Over Budget';
    } else if (percentage > 0.8) {
      statusColor = Colors.orange;
      statusText = 'Near Limit';
    } else {
      statusColor = Colors.green;
      statusText = 'On Track';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: category['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '\$${NumberFormat('#,##0.00').format(amount)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${spendingPercentage.toInt()}% of total spending',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (budget > 0) ...[
            const SizedBox(height: 12),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget: \$${NumberFormat('#,##0.00').format(budget)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Remaining: \$${NumberFormat('#,##0.00').format(budget - amount)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: budget - amount >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage > 1.0 ? 1.0 : percentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toInt()}% used',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '100%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(String categoryId) {
    switch (categoryId) {
      case 'food':
        return {
          'name': 'Food & Dining',
          'icon': Icons.restaurant,
          'color': const Color(0xFF1A1A1A),
        };
      case 'transport':
        return {
          'name': 'Transport',
          'icon': Icons.directions_car,
          'color': const Color(0xFF333333),
        };
      case 'entertainment':
        return {
          'name': 'Entertainment',
          'icon': Icons.movie,
          'color': const Color(0xFF4D4D4D),
        };
      case 'bills':
        return {
          'name': 'Bills & Utilities',
          'icon': Icons.receipt_long,
          'color': const Color(0xFF666666),
        };
      case 'shopping':
        return {
          'name': 'Shopping',
          'icon': Icons.shopping_bag,
          'color': const Color(0xFF808080),
        };
      default:
        return {
          'name': 'Other',
          'icon': Icons.category,
          'color': const Color(0xFF999999),
        };
    }
  }
}