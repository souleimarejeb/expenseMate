import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/budget_tracking_provider.dart';

class MonthlySpendingChart extends StatelessWidget {
  final MonthlyBudgetData? monthlyData;

  const MonthlySpendingChart({
    Key? key,
    required this.monthlyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (monthlyData == null || monthlyData!.categorySpending.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Spending',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '\$${NumberFormat('#,##0.00').format(monthlyData!.totalSpent)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: _generatePieChartSections(),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                        mouseCursorResolver: (FlTouchEvent event, pieTouchResponse) {
                          return pieTouchResponse?.touchedSection != null
                              ? SystemMouseCursors.click
                              : SystemMouseCursors.basic;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildLegend(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
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
              Icons.pie_chart_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No expenses this month',
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

  List<PieChartSectionData> _generatePieChartSections() {
    final categorySpending = monthlyData!.categorySpending;
    final total = categorySpending.values.fold(0.0, (sum, amount) => sum + amount);
    
    if (total == 0) return [];

    final colors = [
      const Color(0xFF1A1A1A),
      const Color(0xFF333333),
      const Color(0xFF4D4D4D),
      const Color(0xFF666666),
      const Color(0xFF808080),
      const Color(0xFF999999),
    ];

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;

    categorySpending.entries.forEach((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colors[colorIndex % colors.length];
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: entry.value,
          title: '${percentage.toInt()}%',
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          radius: 80,
        ),
      );
      
      colorIndex++;
    });

    return sections;
  }

  Widget _buildLegend() {
    final categorySpending = monthlyData!.categorySpending;
    final colors = [
      const Color(0xFF1A1A1A),
      const Color(0xFF333333),
      const Color(0xFF4D4D4D),
      const Color(0xFF666666),
      const Color(0xFF808080),
      const Color(0xFF999999),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: categorySpending.entries.map((entry) {
        final colorIndex = categorySpending.keys.toList().indexOf(entry.key);
        final color = colors[colorIndex % colors.length];
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCategoryName(entry.key),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '\$${NumberFormat('#,##0.00').format(entry.value)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case 'food':
        return 'Food & Dining';
      case 'transport':
        return 'Transport';
      case 'entertainment':
        return 'Entertainment';
      case 'bills':
        return 'Bills & Utilities';
      case 'shopping':
        return 'Shopping';
      default:
        return 'Other';
    }
  }
}