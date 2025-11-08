import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/expense_category.dart';
import '../../../core/services/expense_service.dart';

class MonthlyExpenseData {
  final DateTime month;
  final double totalAmount;
  final int totalCount;
  final Map<String, double> categorySpending;
  final Map<String, int> categoryCount;
  final List<Expense> expenses;
  final double averagePerDay;
  final double averagePerExpense;

  MonthlyExpenseData({
    required this.month,
    required this.totalAmount,
    required this.totalCount,
    required this.categorySpending,
    required this.categoryCount,
    required this.expenses,
    required this.averagePerDay,
    required this.averagePerExpense,
  });

  MonthlyExpenseData copyWith({
    DateTime? month,
    double? totalAmount,
    int? totalCount,
    Map<String, double>? categorySpending,
    Map<String, int>? categoryCount,
    List<Expense>? expenses,
    double? averagePerDay,
    double? averagePerExpense,
  }) {
    return MonthlyExpenseData(
      month: month ?? this.month,
      totalAmount: totalAmount ?? this.totalAmount,
      totalCount: totalCount ?? this.totalCount,
      categorySpending: categorySpending ?? this.categorySpending,
      categoryCount: categoryCount ?? this.categoryCount,
      expenses: expenses ?? this.expenses,
      averagePerDay: averagePerDay ?? this.averagePerDay,
      averagePerExpense: averagePerExpense ?? this.averagePerExpense,
    );
  }

  // Get top spending categories
  List<MapEntry<String, double>> get topSpendingCategories {
    var entries = categorySpending.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  // Get spending trend (positive = increase, negative = decrease)
  double getSpendingTrend(MonthlyExpenseData? previousMonth) {
    if (previousMonth == null || previousMonth.totalAmount == 0) return 0;
    return ((totalAmount - previousMonth.totalAmount) / previousMonth.totalAmount) * 100;
  }
}

class ExpenseAnalyticsProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  
  bool _isLoading = false;
  String? _error;
  
  List<Expense> _allExpenses = [];
  List<ExpenseCategory> _categories = [];
  Map<String, MonthlyExpenseData> _monthlyData = {};
  
  // Current filters
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String? _categoryFilter;
  String _searchQuery = '';
  
  // Analytics data
  Map<String, double> _yearlyTrends = {};
  Map<String, double> _categoryAverages = {};
  List<Expense> _recentExpenses = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Expense> get allExpenses => List.unmodifiable(_allExpenses);
  List<ExpenseCategory> get categories => List.unmodifiable(_categories);
  Map<String, double> get yearlyTrends => Map.unmodifiable(_yearlyTrends);
  Map<String, double> get categoryAverages => Map.unmodifiable(_categoryAverages);
  List<Expense> get recentExpenses => List.unmodifiable(_recentExpenses);
  
  // Filtered expenses
  List<Expense> get filteredExpenses {
    List<Expense> filtered = List.from(_allExpenses);

    // Date range filter
    if (_startDateFilter != null && _endDateFilter != null) {
      filtered = filtered.where((expense) =>
        expense.date.isAfter(_startDateFilter!) &&
        expense.date.isBefore(_endDateFilter!.add(const Duration(days: 1)))
      ).toList();
    }

    // Category filter
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      filtered = filtered.where((expense) => expense.categoryId == _categoryFilter).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((expense) =>
        expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        expense.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get monthly data for specific month
  MonthlyExpenseData? getMonthlyData(DateTime month) {
    final key = _monthKey(month);
    return _monthlyData[key];
  }

  // Get expenses for a specific month
  List<Expense> getMonthlyExpenses(DateTime month) {
    return _allExpenses.where((expense) =>
      expense.date.year == month.year &&
      expense.date.month == month.month
    ).toList();
  }

  // Initialize the provider
  Future<void> initialize() async {
    await loadData();
  }

  // Load all data
  Future<void> loadData() async {
    _setLoading(true);
    _clearError();
    
    try {
      await Future.wait([
        _loadExpenses(),
        _loadCategories(),
      ]);
      
      _calculateAllAnalytics();
    } catch (e) {
      _setError('Failed to load data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load specific month data
  Future<void> loadMonthlyData(DateTime month) async {
    try {
      final normalizedMonth = DateTime(month.year, month.month, 1);
      
      if (_monthlyData.containsKey(_monthKey(normalizedMonth))) {
        return; // Data already loaded
      }

      final monthExpenses = _allExpenses.where((expense) =>
        expense.date.year == normalizedMonth.year &&
        expense.date.month == normalizedMonth.month
      ).toList();

      final monthlyData = _calculateMonthlyData(normalizedMonth, monthExpenses);
      _monthlyData[_monthKey(normalizedMonth)] = monthlyData;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load monthly data: $e');
    }
  }

  // CRUD Operations
  
  Future<bool> addExpense(Expense expense) async {
    _setLoading(true);
    try {
      await _expenseService.createExpense(expense);
      await _loadExpenses();
      _calculateAllAnalytics();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to add expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    _setLoading(true);
    try {
      await _expenseService.updateExpense(expense);
      await _loadExpenses();
      _calculateAllAnalytics();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    _setLoading(true);
    try {
      await _expenseService.deleteExpense(expenseId);
      await _loadExpenses();
      _calculateAllAnalytics();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to delete expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Category suggestion method
  Future<String?> getCategorySuggestion(String title, String description) async {
    try {
      // Simple category suggestion based on expense title and description
      final searchText = '${title.toLowerCase()} ${description.toLowerCase()}';
      
      // Define keyword mappings for common categories
      final categoryMappings = {
        'food': ['food', 'restaurant', 'lunch', 'dinner', 'breakfast', 'eat', 'meal'],
        'transport': ['uber', 'taxi', 'bus', 'train', 'gas', 'fuel', 'parking'],
        'shopping': ['shop', 'store', 'buy', 'purchase', 'mall', 'amazon'],
        'entertainment': ['movie', 'cinema', 'game', 'fun', 'party', 'music'],
        'utilities': ['electric', 'water', 'internet', 'phone', 'bill'],
        'health': ['doctor', 'medicine', 'pharmacy', 'hospital', 'medical'],
      };

      // Find matching category
      for (final entry in categoryMappings.entries) {
        final categoryId = entry.key;
        final keywords = entry.value;
        
        for (final keyword in keywords) {
          if (searchText.contains(keyword)) {
            // Check if this category exists in our categories list
            final categoryExists = _categories.any((cat) => cat.id == categoryId);
            if (categoryExists) {
              return categoryId;
            }
          }
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Filter methods
  
  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    _startDateFilter = startDate;
    _endDateFilter = endDate;
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    _categoryFilter = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _startDateFilter = null;
    _endDateFilter = null;
    _categoryFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Analytics methods
  
  Map<String, double> getSpendingByCategory() {
    Map<String, double> categoryTotals = {};
    
    for (var expense in filteredExpenses) {
      final category = _categories.firstWhere(
        (cat) => cat.id == expense.categoryId,
        orElse: () => ExpenseCategory(
          name: 'Unknown',
          description: '',
          icon: const IconData(0),
          color: const Color(0),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      categoryTotals[category.name] = (categoryTotals[category.name] ?? 0) + expense.amount;
    }
    
    return categoryTotals;
  }

  Map<String, double> getMonthlyTrends(int year) {
    Map<String, double> monthlyTotals = {};
    
    for (int month = 1; month <= 12; month++) {
      final monthExpenses = _allExpenses.where((expense) =>
        expense.date.year == year &&
        expense.date.month == month
      );
      
      final total = monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
      monthlyTotals['$month'] = total;
    }
    
    return monthlyTotals;
  }

  double getTotalExpenses() {
    return filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double getAverageExpenseAmount() {
    if (filteredExpenses.isEmpty) return 0;
    return getTotalExpenses() / filteredExpenses.length;
  }

  int getExpenseCount() {
    return filteredExpenses.length;
  }

  List<Expense> getTopExpenses({int limit = 10}) {
    final sorted = List<Expense>.from(filteredExpenses);
    sorted.sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.take(limit).toList();
  }

  // Private helper methods
  
  Future<void> _loadExpenses() async {
    _allExpenses = await _expenseService.getAllExpenses();
  }

  Future<void> _loadCategories() async {
    _categories = await _expenseService.getAllCategories();
  }

  void _calculateAllAnalytics() {
    _calculateYearlyTrends();
    _calculateCategoryAverages();
    _calculateRecentExpenses();
    _calculateMonthlyDataForAll();
  }

  void _calculateYearlyTrends() {
    final currentYear = DateTime.now().year;
    _yearlyTrends = getMonthlyTrends(currentYear);
  }

  void _calculateCategoryAverages() {
    _categoryAverages = {};
    
    for (var category in _categories) {
      final categoryExpenses = _allExpenses.where((expense) => expense.categoryId == category.id);
      if (categoryExpenses.isNotEmpty) {
        final total = categoryExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
        _categoryAverages[category.name] = total / categoryExpenses.length;
      }
    }
  }

  void _calculateRecentExpenses() {
    final sorted = List<Expense>.from(_allExpenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    _recentExpenses = sorted.take(20).toList();
  }

  void _calculateMonthlyDataForAll() {
    _monthlyData.clear();
    
    // Group expenses by month
    Map<String, List<Expense>> expensesByMonth = {};
    
    for (var expense in _allExpenses) {
      final monthKey = _monthKey(expense.date);
      expensesByMonth[monthKey] = expensesByMonth[monthKey] ?? [];
      expensesByMonth[monthKey]!.add(expense);
    }

    // Calculate monthly data for each month
    for (var entry in expensesByMonth.entries) {
      final month = _parseMonthKey(entry.key);
      final expenses = entry.value;
      _monthlyData[entry.key] = _calculateMonthlyData(month, expenses);
    }
  }

  MonthlyExpenseData _calculateMonthlyData(DateTime month, List<Expense> expenses) {
    final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final totalCount = expenses.length;
    
    // Calculate spending by category
    Map<String, double> categorySpending = {};
    Map<String, int> categoryCount = {};
    
    for (var expense in expenses) {
      final category = _categories.firstWhere(
        (cat) => cat.id == expense.categoryId,
        orElse: () => ExpenseCategory(
          name: 'Unknown',
          description: '',
          icon: const IconData(0),
          color: const Color(0),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      categorySpending[category.name] = (categorySpending[category.name] ?? 0) + expense.amount;
      categoryCount[category.name] = (categoryCount[category.name] ?? 0) + 1;
    }
    
    // Calculate averages
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final averagePerDay = totalAmount / daysInMonth;
    final averagePerExpense = totalCount > 0 ? (totalAmount / totalCount).toDouble() : 0.0;
    
    return MonthlyExpenseData(
      month: month,
      totalAmount: totalAmount,
      totalCount: totalCount,
      categorySpending: categorySpending,
      categoryCount: categoryCount,
      expenses: expenses,
      averagePerDay: averagePerDay,
      averagePerExpense: averagePerExpense,
    );
  }

  String _monthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  DateTime _parseMonthKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Utility methods
  
  Expense? getExpenseById(String id) {
    try {
      return _allExpenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  ExpenseCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get spending comparison with previous period
  Map<String, dynamic> getSpendingComparison(DateTime startDate, DateTime endDate) {
    final periodDuration = endDate.difference(startDate);
    final previousStart = startDate.subtract(periodDuration);
    final previousEnd = startDate.subtract(const Duration(days: 1));

    final currentExpenses = _allExpenses.where((expense) =>
      expense.date.isAfter(startDate) && expense.date.isBefore(endDate.add(const Duration(days: 1)))
    );
    
    final previousExpenses = _allExpenses.where((expense) =>
      expense.date.isAfter(previousStart) && expense.date.isBefore(previousEnd.add(const Duration(days: 1)))
    );

    final currentTotal = currentExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final previousTotal = previousExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    
    double changePercentage = 0;
    if (previousTotal > 0) {
      changePercentage = ((currentTotal - previousTotal) / previousTotal) * 100;
    }

    return {
      'currentTotal': currentTotal,
      'previousTotal': previousTotal,
      'changeAmount': currentTotal - previousTotal,
      'changePercentage': changePercentage,
      'isIncrease': currentTotal > previousTotal,
    };
  }
}