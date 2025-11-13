import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/expense_category.dart';
import '../../../core/models/bugets/budget.dart';
import '../../../core/models/bugets/budget_status.dart';
import '../../../core/services/expense_service.dart';
import '../../../core/services/budget_service.dart';

class MonthlyBudgetData {
  final DateTime month;
  final double totalBudget;
  final double totalSpent;
  final Map<String, double> categorySpending;
  final Map<String, double> categoryBudgets;
  final List<Expense> expenses;
  final List<Budget> budgets;

  MonthlyBudgetData({
    required this.month,
    required this.totalBudget,
    required this.totalSpent,
    required this.categorySpending,
    required this.categoryBudgets,
    required this.expenses,
    required this.budgets,
  });

  double get remainingBudget => totalBudget - totalSpent;
  double get spentPercentage => totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;

  MonthlyBudgetData copyWith({
    DateTime? month,
    double? totalBudget,
    double? totalSpent,
    Map<String, double>? categorySpending,
    Map<String, double>? categoryBudgets,
    List<Expense>? expenses,
    List<Budget>? budgets,
  }) {
    return MonthlyBudgetData(
      month: month ?? this.month,
      totalBudget: totalBudget ?? this.totalBudget,
      totalSpent: totalSpent ?? this.totalSpent,
      categorySpending: categorySpending ?? this.categorySpending,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      expenses: expenses ?? this.expenses,
      budgets: budgets ?? this.budgets,
    );
  }
}

class BudgetTrackingProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  final BudgetService _budgetService = BudgetService();
  
  bool _isLoading = false;
  String? _error;
  
  List<Expense> _allExpenses = [];
  List<ExpenseCategory> _categories = [];
  List<Budget> _budgets = [];
  Map<String, MonthlyBudgetData> _monthlyData = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Expense> get allExpenses => List.unmodifiable(_allExpenses);
  List<ExpenseCategory> get categories => List.unmodifiable(_categories);
  List<Budget> get budgets => List.unmodifiable(_budgets);

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
        _loadBudgets(),
      ]);
      
      _calculateAllMonthlyData();
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

      await _calculateMonthlyData(normalizedMonth);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load monthly data: $e');
    }
  }

  // Get monthly data
  MonthlyBudgetData? getMonthlyData(DateTime month) {
    final key = _monthKey(DateTime(month.year, month.month, 1));
    return _monthlyData[key];
  }

  // Get expenses for a specific month
  List<Expense> getExpensesForMonth(DateTime month) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    return _allExpenses.where((expense) {
      return expense.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
             expense.date.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();
  }

  // Get category by ID
  ExpenseCategory? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Get budget for category and month
  Budget? getBudgetForCategoryMonth(String categoryId, DateTime month) {
    return _budgets.where((budget) {
      return budget.category == categoryId && budget.month == month.month;
    }).isNotEmpty 
        ? _budgets.firstWhere((budget) => 
            budget.category == categoryId && budget.month == month.month)
        : null;
  }

  // Add expense
  Future<void> addExpense(Expense expense) async {
    try {
      await _expenseService.createExpense(expense);
      _allExpenses.add(expense);
      
      // Recalculate monthly data for the expense month
      final expenseMonth = DateTime(expense.date.year, expense.date.month, 1);
      await _calculateMonthlyData(expenseMonth);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to add expense: $e');
    }
  }

  // Update expense
  Future<void> updateExpense(Expense expense) async {
    try {
      await _expenseService.updateExpense(expense);
      
      final index = _allExpenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _allExpenses[index] = expense;
        
        // Recalculate monthly data for the expense month
        final expenseMonth = DateTime(expense.date.year, expense.date.month, 1);
        await _calculateMonthlyData(expenseMonth);
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update expense: $e');
    }
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _expenseService.deleteExpense(expenseId);
      
      final expense = _allExpenses.firstWhere((e) => e.id == expenseId);
      _allExpenses.removeWhere((e) => e.id == expenseId);
      
      // Recalculate monthly data for the expense month
      final expenseMonth = DateTime(expense.date.year, expense.date.month, 1);
      await _calculateMonthlyData(expenseMonth);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete expense: $e');
    }
  }

  // Create a new budget
  Future<Budget> createBudget({
    required double limitAmount,
    required int month,
    required int year,
    String? category,
  }) async {
    try {
      final budget = await _budgetService.createBudget(
        limitAmount: limitAmount,
        month: month,
        year: year,
        category: category,
      );
      
      _budgets.add(budget);
      
      // Recalculate monthly data
      final budgetMonth = DateTime(year, month, 1);
      await _calculateMonthlyData(budgetMonth);
      
      notifyListeners();
      return budget;
    } catch (e) {
      _setError('Failed to create budget: $e');
      rethrow;
    }
  }

  // Update budget
  Future<Budget> updateBudget(Budget budget) async {
    try {
      final updatedBudget = await _budgetService.updateBudget(budget);
      
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = updatedBudget;
        
        // Recalculate monthly data
        final budgetMonth = DateTime(updatedBudget.createdAt.year, updatedBudget.month, 1);
        await _calculateMonthlyData(budgetMonth);
        
        notifyListeners();
      }
      
      return updatedBudget;
    } catch (e) {
      _setError('Failed to update budget: $e');
      rethrow;
    }
  }

  // Delete budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      final budget = _budgets.firstWhere((b) => b.id == budgetId);
      
      await _budgetService.deleteBudget(budgetId);
      _budgets.removeWhere((b) => b.id == budgetId);
      
      // Recalculate monthly data
      final budgetMonth = DateTime(budget.createdAt.year, budget.month, 1);
      await _calculateMonthlyData(budgetMonth);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete budget: $e');
    }
  }

  // Create or update budget for a category
  Future<Budget> upsertBudget({
    required double limitAmount,
    required int month,
    required int year,
    String? category,
  }) async {
    try {
      final budget = await _budgetService.upsertBudget(
        limitAmount: limitAmount,
        month: month,
        year: year,
        category: category,
      );
      
      // Update local list
      final existingIndex = _budgets.indexWhere(
        (b) => b.category == category && b.month == month,
      );
      
      if (existingIndex != -1) {
        _budgets[existingIndex] = budget;
      } else {
        _budgets.add(budget);
      }
      
      // Recalculate monthly data
      final budgetMonth = DateTime(year, month, 1);
      await _calculateMonthlyData(budgetMonth);
      
      notifyListeners();
      return budget;
    } catch (e) {
      _setError('Failed to upsert budget: $e');
      rethrow;
    }
  }

  // Sync budgets with actual spending
  Future<void> syncBudgetsWithSpending(DateTime month) async {
    try {
      final normalizedMonth = DateTime(month.year, month.month, 1);
      final monthExpenses = getExpensesForMonth(normalizedMonth);
      
      // Calculate spending by category
      final categorySpending = <String, double>{};
      for (final expense in monthExpenses) {
        categorySpending[expense.categoryId] = 
            (categorySpending[expense.categoryId] ?? 0.0) + expense.amount;
      }
      
      // Update budgets with actual spending
      await _budgetService.recalculateSpentAmounts(
        normalizedMonth.month,
        normalizedMonth.year,
        categorySpending,
      );
      
      // Reload budgets
      await _loadBudgets();
      await _calculateMonthlyData(normalizedMonth);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to sync budgets: $e');
    }
  }

  // Get spending comparison data
  Map<String, double> getSpendingComparison(DateTime currentMonth, DateTime previousMonth) {
    final currentData = getMonthlyData(currentMonth);
    final previousData = getMonthlyData(previousMonth);
    
    final comparison = <String, double>{};
    
    if (currentData != null && previousData != null) {
      comparison['current'] = currentData.totalSpent;
      comparison['previous'] = previousData.totalSpent;
      comparison['change'] = currentData.totalSpent - previousData.totalSpent;
      comparison['changePercentage'] = previousData.totalSpent > 0 
          ? ((currentData.totalSpent - previousData.totalSpent) / previousData.totalSpent) * 100
          : 0.0;
    }
    
    return comparison;
  }

  // Get category spending trends
  List<Map<String, dynamic>> getCategoryTrends(DateTime month, int monthsBack) {
    final trends = <Map<String, dynamic>>[];
    
    for (final category in _categories) {
      final categoryTrend = <String, dynamic>{
        'category': category,
        'monthlySpending': <double>[],
      };
      
      for (int i = monthsBack; i >= 0; i--) {
        final targetMonth = DateTime(month.year, month.month - i, 1);
        final monthlyData = getMonthlyData(targetMonth);
        final spending = monthlyData?.categorySpending[category.id!] ?? 0.0;
        (categoryTrend['monthlySpending'] as List<double>).add(spending);
      }
      
      trends.add(categoryTrend);
    }
    
    return trends;
  }

  // Private methods
  Future<void> _loadExpenses() async {
    try {
      _allExpenses = await _expenseService.getAllExpenses();
    } catch (e) {
      throw Exception('Failed to load expenses: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _expenseService.getAllCategories();
      
      // Add default categories if empty
      if (_categories.isEmpty) {
        _categories = _getDefaultCategories();
      }
    } catch (e) {
      _categories = _getDefaultCategories();
    }
  }

  Future<void> _loadBudgets() async {
    try {
      _budgets = await _budgetService.getAllBudgets();
    } catch (e) {
      _budgets = [];
      throw Exception('Failed to load budgets: $e');
    }
  }

  void _calculateAllMonthlyData() {
    final now = DateTime.now();
    
    // Calculate data for current month and previous 11 months
    for (int i = 0; i < 12; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      _calculateMonthlyDataSync(month);
    }
  }

  Future<void> _calculateMonthlyData(DateTime month) async {
    _calculateMonthlyDataSync(month);
  }

  void _calculateMonthlyDataSync(DateTime month) {
    final monthExpenses = getExpensesForMonth(month);
    final monthBudgets = _budgets.where((budget) => budget.month == month.month).toList();
    
    final categorySpending = <String, double>{};
    final categoryBudgets = <String, double>{};
    
    double totalSpent = 0.0;
    double totalBudget = 0.0;
    
    // Calculate spending by category
    for (final expense in monthExpenses) {
      categorySpending[expense.categoryId] = 
          (categorySpending[expense.categoryId] ?? 0.0) + expense.amount;
      totalSpent += expense.amount;
    }
    
    // Calculate budgets by category
    for (final budget in monthBudgets) {
      if (budget.category != null) {
        categoryBudgets[budget.category!] = budget.limitAmount;
        totalBudget += budget.limitAmount;
      }
    }
    
    final monthlyData = MonthlyBudgetData(
      month: month,
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      categorySpending: categorySpending,
      categoryBudgets: categoryBudgets,
      expenses: monthExpenses,
      budgets: monthBudgets,
    );
    
    _monthlyData[_monthKey(month)] = monthlyData;
  }

  String _monthKey(DateTime month) {
    return '${month.year}-${month.month.toString().padLeft(2, '0')}';
  }

  List<ExpenseCategory> _getDefaultCategories() {
    return [
      ExpenseCategory(
        id: 'food',
        name: 'Food & Dining',
        description: 'Restaurants, groceries, and dining out',
        icon: Icons.restaurant,
        color: Colors.red,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ExpenseCategory(
        id: 'transport',
        name: 'Transport',
        description: 'Gas, public transport, car maintenance',
        icon: Icons.directions_car,
        color: Colors.blue,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ExpenseCategory(
        id: 'entertainment',
        name: 'Entertainment',
        description: 'Movies, games, hobbies',
        icon: Icons.movie,
        color: Colors.purple,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ExpenseCategory(
        id: 'bills',
        name: 'Bills & Utilities',
        description: 'Electricity, water, internet, rent',
        icon: Icons.receipt_long,
        color: Colors.orange,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ExpenseCategory(
        id: 'shopping',
        name: 'Shopping',
        description: 'Clothes, electronics, general shopping',
        icon: Icons.shopping_bag,
        color: Colors.green,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }



  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}