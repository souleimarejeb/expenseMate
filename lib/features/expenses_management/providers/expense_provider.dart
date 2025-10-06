import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/expense_category.dart';
import '../../../core/models/recurring_expense.dart';
import '../../../core/services/expense_service.dart';
import '../../../core/services/expense_scheduler.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  final ExpenseScheduler _expenseScheduler = ExpenseScheduler();

  // State variables
  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = [];
  List<RecurringExpense> _recurringExpenses = [];
  
  bool _isLoading = false;
  String? _error;
  
  // Filters
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String? _categoryFilter;
  String _searchQuery = '';

  // Getters
  List<Expense> get expenses => _filteredExpenses;
  List<ExpenseCategory> get categories => _categories;
  List<RecurringExpense> get recurringExpenses => _recurringExpenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get startDateFilter => _startDateFilter;
  DateTime? get endDateFilter => _endDateFilter;
  String? get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;

  // Filtered expenses based on current filters
  List<Expense> get _filteredExpenses {
    List<Expense> filtered = List.from(_expenses);

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

  // Total amount of filtered expenses
  double get totalAmount => _filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

  // Expenses by category (for current filtered expenses)
  Map<String, double> get expensesByCategory {
    Map<String, double> categoryTotals = {};
    
    for (var expense in _filteredExpenses) {
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

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _expenseScheduler.initialize();
      await _expenseService.initializeDefaultCategories();
      await loadData();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all data
  Future<void> loadData() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadExpenses(),
        loadCategories(),
        loadRecurringExpenses(),
      ]);
      _clearError();
    } catch (e) {
      _setError('Failed to load data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load expenses
  Future<void> loadExpenses() async {
    try {
      _expenses = await _expenseService.getAllExpenses();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load expenses: $e');
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await _expenseService.getAllCategories();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    }
  }

  // Load recurring expenses
  Future<void> loadRecurringExpenses() async {
    try {
      _recurringExpenses = await _expenseService.getAllRecurringExpenses();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recurring expenses: $e');
    }
  }

  // CRUD Operations for Expenses

  // Add expense
  Future<bool> addExpense(Expense expense) async {
    _setLoading(true);
    try {
      await _expenseService.createExpense(expense);
      await loadExpenses();
      
      // Check for budget warnings
      await _checkBudgetLimits(expense.categoryId);
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to add expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update expense
  Future<bool> updateExpense(Expense expense) async {
    _setLoading(true);
    try {
      await _expenseService.updateExpense(expense);
      await loadExpenses();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String expenseId) async {
    _setLoading(true);
    try {
      await _expenseService.deleteExpense(expenseId);
      await loadExpenses();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to delete expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // CRUD Operations for Recurring Expenses

  // Add recurring expense
  Future<bool> addRecurringExpense(RecurringExpense recurringExpense) async {
    _setLoading(true);
    try {
      await _expenseService.createRecurringExpense(recurringExpense);
      await _expenseScheduler.scheduleRecurringExpenseReminder(recurringExpense);
      await loadRecurringExpenses();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to add recurring expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update recurring expense
  Future<bool> updateRecurringExpense(RecurringExpense recurringExpense) async {
    _setLoading(true);
    try {
      await _expenseService.updateRecurringExpenseNextDue(
        recurringExpense.id!,
        recurringExpense.calculateNextDueDate(),
      );
      await loadRecurringExpenses();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update recurring expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Filter operations

  // Set date range filter
  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    _startDateFilter = startDate;
    _endDateFilter = endDate;
    notifyListeners();
  }

  // Set category filter
  void setCategoryFilter(String? categoryId) {
    _categoryFilter = categoryId;
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _startDateFilter = null;
    _endDateFilter = null;
    _categoryFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Analytics methods

  // Get monthly expense data
  Future<Map<String, double>> getMonthlyExpenses(int year) async {
    try {
      return await _expenseService.getMonthlyExpenseTotals(year);
    } catch (e) {
      _setError('Failed to get monthly expenses: $e');
      return {};
    }
  }

  // Get expense predictions
  Future<Map<String, dynamic>> getExpensePredictions() async {
    try {
      return await _expenseScheduler.getExpensePredictions();
    } catch (e) {
      _setError('Failed to get predictions: $e');
      return {};
    }
  }

  // Get category suggestion for expense
  Future<String?> getCategorySuggestion(String title, String description) async {
    try {
      return await _expenseScheduler.suggestCategory(title, description);
    } catch (e) {
      print('Failed to get category suggestion: $e');
      return null;
    }
  }

  // Process due recurring expenses manually
  Future<void> processRecurringExpenses() async {
    _setLoading(true);
    try {
      final createdIds = await _expenseScheduler.processRecurringExpensesManually();
      if (createdIds.isNotEmpty) {
        await loadExpenses();
        await loadRecurringExpenses();
      }
      _clearError();
    } catch (e) {
      _setError('Failed to process recurring expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods

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

  // Check budget limits and show warnings
  Future<void> _checkBudgetLimits(String categoryId) async {
    // This is a placeholder - you would implement actual budget checking here
    // For now, we'll use a simple threshold system
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final monthlyTotal = await _expenseService.getTotalExpensesForPeriod(
        startOfMonth,
        endOfMonth,
      );
      
      // Simple budget limit example (you would get this from user settings)
      const double monthlyBudgetLimit = 2000.0;
      
      if (monthlyTotal > monthlyBudgetLimit * 0.8) {
        await _expenseScheduler.scheduleBudgetWarning(
          categoryId,
          monthlyTotal,
          monthlyBudgetLimit,
        );
      }
    } catch (e) {
      print('Error checking budget limits: $e');
    }
  }

  // Get expense by ID
  Expense? getExpenseById(String id) {
    try {
      return _expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category by ID
  ExpenseCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _expenseScheduler.dispose();
    super.dispose();
  }
}