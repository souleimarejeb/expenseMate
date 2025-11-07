import '../database/databaseHelper.dart';
import '../models/expense.dart';

class AdvancedAnalyticsService {
  static final AdvancedAnalyticsService _instance = AdvancedAnalyticsService._internal();
  factory AdvancedAnalyticsService() => _instance;
  AdvancedAnalyticsService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get total expenses and amount
  Future<Map<String, dynamic>> getTotalExpensesAnalytics() async {
    final expenses = await _dbHelper.getAllExpenses();
    
    double totalAmount = 0.0;
    for (var expenseMap in expenses) {
      totalAmount += expenseMap['amount'] ?? 0.0;
    }
    
    return {
      'totalCount': expenses.length,
      'totalAmount': totalAmount,
      'averageAmount': expenses.isNotEmpty ? totalAmount / expenses.length : 0.0,
    };
  }

  // Get monthly spending analytics
  Future<List<Map<String, dynamic>>> getMonthlySpendingAnalytics() async {
    final expenses = await _dbHelper.getAllExpenses();
    Map<String, double> monthlySpending = {};
    
    for (var expenseMap in expenses) {
      final expense = Expense.fromMap(expenseMap);
      String monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlySpending[monthKey] = (monthlySpending[monthKey] ?? 0.0) + expense.amount;
    }
    
    return monthlySpending.entries.map((e) => {
      'month': e.key,
      'amount': e.value,
    }).toList();
  }

  // Get category analytics
  Future<List<Map<String, dynamic>>> getCategoryAnalytics() async {
    final expenses = await _dbHelper.getAllExpenses();
    final categories = await _dbHelper.getAllCategories();
    
    Map<String, double> categorySpending = {};
    Map<String, int> categoryCount = {};
    Map<String, String> categoryNames = {};
    
    // Build category name mapping
    for (var categoryMap in categories) {
      categoryNames[categoryMap['id']] = categoryMap['name'];
    }
    
    // Calculate spending per category
    for (var expenseMap in expenses) {
      final expense = Expense.fromMap(expenseMap);
      categorySpending[expense.categoryId] = (categorySpending[expense.categoryId] ?? 0.0) + expense.amount;
      categoryCount[expense.categoryId] = (categoryCount[expense.categoryId] ?? 0) + 1;
    }
    
    return categorySpending.entries.map((e) => {
      'categoryId': e.key,
      'categoryName': categoryNames[e.key] ?? 'Unknown',
      'totalAmount': e.value,
      'expenseCount': categoryCount[e.key] ?? 0,
      'averageAmount': (categoryCount[e.key] ?? 0) > 0 ? e.value / (categoryCount[e.key]!) : 0.0,
    }).toList();
  }

  // Get weekly analytics
  Future<List<Map<String, dynamic>>> getWeeklyAnalytics() async {
    final expenses = await _dbHelper.getAllExpenses();
    Map<String, double> weeklySpending = {};
    
    for (var expenseMap in expenses) {
      final expense = Expense.fromMap(expenseMap);
      // Calculate week start (Monday)
      final weekStart = expense.date.subtract(Duration(days: expense.date.weekday - 1));
      final weekKey = '${weekStart.year}-W${_getWeekNumber(weekStart)}';
      weeklySpending[weekKey] = (weeklySpending[weekKey] ?? 0.0) + expense.amount;
    }
    
    return weeklySpending.entries.map((e) => {
      'week': e.key,
      'amount': e.value,
    }).toList();
  }

  // Get spending trends
  Future<Map<String, dynamic>> getSpendingTrends() async {
    final monthlyData = await getMonthlySpendingAnalytics();
    
    if (monthlyData.length < 2) {
      return {
        'trend': 'insufficient_data',
        'percentage_change': 0.0,
        'direction': 'stable'
      };
    }
    
    // Sort by month
    monthlyData.sort((a, b) => a['month'].compareTo(b['month']));
    
    final lastMonth = monthlyData.last['amount'] as double;
    final previousMonth = monthlyData[monthlyData.length - 2]['amount'] as double;
    
    if (previousMonth == 0) {
      return {
        'trend': 'new_spending',
        'percentage_change': 0.0,
        'direction': 'up'
      };
    }
    
    final percentageChange = ((lastMonth - previousMonth) / previousMonth) * 100;
    String direction = 'stable';
    
    if (percentageChange > 5) {
      direction = 'up';
    } else if (percentageChange < -5) {
      direction = 'down';
    }
    
    return {
      'trend': 'calculated',
      'percentage_change': percentageChange,
      'direction': direction,
      'last_month_amount': lastMonth,
      'previous_month_amount': previousMonth,
    };
  }

  // Get expense patterns
  Future<Map<String, dynamic>> getExpensePatterns() async {
    final expenses = await _dbHelper.getAllExpenses();
    Map<int, int> dayOfWeekPattern = {};  // 1=Monday, 7=Sunday
    Map<int, int> dayOfMonthPattern = {}; // 1-31
    
    for (var expenseMap in expenses) {
      final expense = Expense.fromMap(expenseMap);
      
      // Day of week pattern
      dayOfWeekPattern[expense.date.weekday] = (dayOfWeekPattern[expense.date.weekday] ?? 0) + 1;
      
      // Day of month pattern
      dayOfMonthPattern[expense.date.day] = (dayOfMonthPattern[expense.date.day] ?? 0) + 1;
    }
    
    // Find most common day
    int mostCommonWeekday = 1;
    int maxWeekdayCount = 0;
    dayOfWeekPattern.forEach((day, count) {
      if (count > maxWeekdayCount) {
        maxWeekdayCount = count;
        mostCommonWeekday = day;
      }
    });
    
    return {
      'most_common_weekday': mostCommonWeekday,
      'most_common_weekday_name': _getWeekdayName(mostCommonWeekday),
      'weekday_distribution': dayOfWeekPattern,
      'day_of_month_distribution': dayOfMonthPattern,
    };
  }

  // Clear analytics cache (no-op in simplified version)
  Future<void> clearAnalyticsCache() async {
    // In the simplified version, we don't cache anything
    print('Analytics cache cleared (simplified mode)');
  }

  // Rebuild analytics cache (no-op in simplified version)  
  Future<void> rebuildAnalyticsCache() async {
    // In the simplified version, we don't cache anything
    print('Analytics cache rebuilt (simplified mode)');
  }

  // Helper methods
  int _getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(date.toString().split('-')[2].split(' ')[0]);
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
  
  String _getWeekdayName(int weekday) {
    const weekdays = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[weekday];
  }
}