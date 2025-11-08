import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/budget_tracking_provider.dart';

class BudgetComparisonChart extends StatelessWidget {
  final DateTime currentMonth;
  final BudgetTrackingProvider provider;

  const BudgetComparisonChart({
    Key? key,
    required this.currentMonth,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Comparison',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              _buildComparisonSummary(),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '\$${NumberFormat('#,##0.00').format(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return _buildBottomTitle(value);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${(value / 1000).toInt()}K',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _generateBarGroups(),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                  drawVerticalLine: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildComparisonSummary() {
    final currentData = provider.getMonthlyData(currentMonth);
    final previousMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    final previousData = provider.getMonthlyData(previousMonth);

    if (currentData == null || previousData == null) {
      return const SizedBox.shrink();
    }

    final difference = currentData.totalSpent - previousData.totalSpent;
    final isPositive = difference >= 0;
    final percentage = previousData.totalSpent > 0 
        ? (difference / previousData.totalSpent) * 100 
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPositive ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: isPositive ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}${percentage.toInt()}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPositive ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    double maxValue = 0;
    
    for (int i = 0; i < 6; i++) {
      final month = DateTime(currentMonth.year, currentMonth.month - i, 1);
      final data = provider.getMonthlyData(month);
      if (data != null) {
        maxValue = math.max(maxValue, data.totalSpent);
        maxValue = math.max(maxValue, data.totalBudget);
      }
    }
    
    return maxValue * 1.2; // Add 20% padding
  }

  List<BarChartGroupData> _generateBarGroups() {
    final groups = <BarChartGroupData>[];
    
    for (int i = 0; i < 6; i++) {
      final month = DateTime(currentMonth.year, currentMonth.month - (5 - i), 1);
      final data = provider.getMonthlyData(month);
      
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data?.totalBudget ?? 0,
              color: Colors.grey[300]!,
              width: 12,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            ),
            BarChartRodData(
              toY: data?.totalSpent ?? 0,
              color: Colors.black87,
              width: 12,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            ),
          ],
          barsSpace: 4,
        ),
      );
    }
    
    return groups;
  }

  Widget _buildBottomTitle(double value) {
    final monthIndex = value.toInt();
    if (monthIndex < 0 || monthIndex >= 6) return const SizedBox.shrink();
    
    final month = DateTime(currentMonth.year, currentMonth.month - (5 - monthIndex), 1);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        DateFormat('MMM').format(month),
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Budget', Colors.grey[300]!),
        const SizedBox(width: 24),
        _buildLegendItem('Spent', Colors.black87),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

