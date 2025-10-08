import 'package:flutter/material.dart';

class CardMonthlySpending extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyCategorySpending;

  const CardMonthlySpending({
    Key? key,
    required this.monthlyCategorySpending,
  }) : super(key: key);

  Color _getCategoryColor(String category) {
    // Using a monochromatic scheme based on category
    switch (category.toLowerCase()) {
      case 'food':
        return Color(0xFF1A1A1A); // Darkest shade
      case 'transport':
        return Color(0xFF333333);
      case 'entertainment':
        return Color(0xFF4D4D4D);
      case 'bills':
        return Color(0xFF666666);
      case 'shopping':
        return Color(0xFF808080);
      default:
        return Color(0xFF999999);
    }
  }

  double _getProgressValue(double amount) {
    // Calculate progress based on a maximum budget of 1000
    const maxBudget = 1000.0;
    return (amount / maxBudget).clamp(0.0, 1.0);
  }

  Widget _buildProgressBar(String category, double amount) {
    final color = _getCategoryColor(category);
    final progress = _getProgressValue(amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}% of budget',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Column(
        children: monthlyCategorySpending.map((cat) {
          final color = _getCategoryColor(cat['category']);
          
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(cat['category']),
                          color: color,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat['category'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "\$${cat['amount']}",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildProgressBar(cat['category'], cat['amount'].toDouble()),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt_long;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }
}