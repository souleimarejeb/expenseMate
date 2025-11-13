import 'package:uuid/uuid.dart';
import '../database/sqlite_database_helper.dart';
import '../models/bugets/budget.dart';
import '../models/bugets/budget_status.dart';

class BudgetService {
  final SQLiteDatabaseHelper _dbHelper = SQLiteDatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// Create a new budget
  Future<Budget> createBudget({
    required double limitAmount,
    required int month,
    required int year,
    String? category,
    double spentAmount = 0.0,
  }) async {
    final now = DateTime.now();
    final budget = Budget(
      id: _uuid.v4(),
      limitAmount: limitAmount,
      spentAmount: spentAmount,
      status: _calculateStatus(spentAmount, limitAmount),
      createdAt: now,
      updatedAt: now,
      month: month,
      category: category,
    );

    final budgetMap = _budgetToMap(budget, year);
    await _dbHelper.insertBudget(budgetMap);
    
    return budget;
  }

  /// Get all budgets
  Future<List<Budget>> getAllBudgets() async {
    final maps = await _dbHelper.getBudgets();
    return maps.map((map) => _budgetFromMap(map)).toList();
  }

  /// Get budget by ID
  Future<Budget?> getBudgetById(String id) async {
    final map = await _dbHelper.getBudgetById(id);
    if (map == null) return null;
    return _budgetFromMap(map);
  }

  /// Get budgets for a specific month and year
  Future<List<Budget>> getBudgetsForMonth(int month, int year) async {
    final maps = await _dbHelper.getBudgetsByMonth(month, year);
    return maps.map((map) => _budgetFromMap(map)).toList();
  }

  /// Get budget for a specific category, month, and year
  Future<Budget?> getBudgetForCategoryAndMonth(
    String category,
    int month,
    int year,
  ) async {
    final map = await _dbHelper.getBudgetByCategoryAndMonth(category, month, year);
    if (map == null) return null;
    return _budgetFromMap(map);
  }

  /// Update an existing budget
  Future<Budget> updateBudget(Budget budget) async {
    final updatedBudget = budget.copyWith(
      updatedAt: DateTime.now(),
      status: _calculateStatus(budget.spentAmount, budget.limitAmount),
    );

    // Extract year from the budget's createdAt or calculate from month
    final year = updatedBudget.createdAt.year;
    final budgetMap = _budgetToMap(updatedBudget, year);
    
    await _dbHelper.updateBudget(updatedBudget.id!, budgetMap);
    return updatedBudget;
  }

  /// Update budget spent amount
  Future<Budget> updateSpentAmount(String budgetId, double newSpentAmount) async {
    final budget = await getBudgetById(budgetId);
    if (budget == null) {
      throw Exception('Budget not found with ID: $budgetId');
    }

    final updatedBudget = budget.copyWith(
      spentAmount: newSpentAmount,
      updatedAt: DateTime.now(),
      status: _calculateStatus(newSpentAmount, budget.limitAmount),
    );

    await updateBudget(updatedBudget);
    return updatedBudget;
  }

  /// Increment budget spent amount
  Future<Budget> incrementSpentAmount(String budgetId, double amount) async {
    final budget = await getBudgetById(budgetId);
    if (budget == null) {
      throw Exception('Budget not found with ID: $budgetId');
    }

    final newSpentAmount = budget.spentAmount + amount;
    return await updateSpentAmount(budgetId, newSpentAmount);
  }

  /// Decrement budget spent amount
  Future<Budget> decrementSpentAmount(String budgetId, double amount) async {
    final budget = await getBudgetById(budgetId);
    if (budget == null) {
      throw Exception('Budget not found with ID: $budgetId');
    }

    final newSpentAmount = (budget.spentAmount - amount).clamp(0.0, double.infinity);
    return await updateSpentAmount(budgetId, newSpentAmount);
  }

  /// Delete a budget
  Future<void> deleteBudget(String id) async {
    await _dbHelper.deleteBudget(id);
  }

  /// Delete all budgets for a specific month and year
  Future<void> deleteBudgetsForMonth(int month, int year) async {
    await _dbHelper.deleteBudgetsByMonth(month, year);
  }

  /// Get total budget limit for a month
  Future<double> getTotalBudgetForMonth(int month, int year) async {
    return await _dbHelper.getTotalBudgetForMonth(month, year);
  }

  /// Get total spent for a month
  Future<double> getTotalSpentForMonth(int month, int year) async {
    return await _dbHelper.getTotalSpentForMonth(month, year);
  }

  /// Recalculate spent amounts for a specific month based on actual expenses
  Future<void> recalculateSpentAmounts(
    int month,
    int year,
    Map<String, double> categorySpending,
  ) async {
    final budgets = await getBudgetsForMonth(month, year);
    
    for (final budget in budgets) {
      if (budget.category != null) {
        final actualSpent = categorySpending[budget.category] ?? 0.0;
        if (actualSpent != budget.spentAmount) {
          await updateSpentAmount(budget.id!, actualSpent);
        }
      }
    }
  }

  /// Create or update budget for a category and month
  Future<Budget> upsertBudget({
    required double limitAmount,
    required int month,
    required int year,
    String? category,
    double? spentAmount,
  }) async {
    if (category != null) {
      final existingBudget = await getBudgetForCategoryAndMonth(category, month, year);
      
      if (existingBudget != null) {
        // Update existing budget
        return await updateBudget(existingBudget.copyWith(
          limitAmount: limitAmount,
          spentAmount: spentAmount ?? existingBudget.spentAmount,
        ));
      }
    }

    // Create new budget
    return await createBudget(
      limitAmount: limitAmount,
      month: month,
      year: year,
      category: category,
      spentAmount: spentAmount ?? 0.0,
    );
  }

  /// Batch create budgets for multiple categories
  Future<List<Budget>> createBudgetsForCategories(
    Map<String, double> categoryBudgets,
    int month,
    int year,
  ) async {
    final budgets = <Budget>[];
    
    for (final entry in categoryBudgets.entries) {
      final budget = await upsertBudget(
        limitAmount: entry.value,
        month: month,
        year: year,
        category: entry.key,
      );
      budgets.add(budget);
    }
    
    return budgets;
  }

  /// Get budget statistics for a month
  Future<Map<String, dynamic>> getBudgetStatistics(int month, int year) async {
    final budgets = await getBudgetsForMonth(month, year);
    
    double totalLimit = 0.0;
    double totalSpent = 0.0;
    int okCount = 0;
    int nearLimitCount = 0;
    int exceededCount = 0;
    
    for (final budget in budgets) {
      totalLimit += budget.limitAmount;
      totalSpent += budget.spentAmount;
      
      switch (budget.status) {
        case BudgetStatus.ok:
          okCount++;
          break;
        case BudgetStatus.nearLimit:
          nearLimitCount++;
          break;
        case BudgetStatus.exceeded:
          exceededCount++;
          break;
      }
    }
    
    return {
      'totalLimit': totalLimit,
      'totalSpent': totalSpent,
      'remaining': totalLimit - totalSpent,
      'percentage': totalLimit > 0 ? (totalSpent / totalLimit) * 100 : 0.0,
      'budgetCount': budgets.length,
      'okCount': okCount,
      'nearLimitCount': nearLimitCount,
      'exceededCount': exceededCount,
    };
  }

  // Private helper methods
  BudgetStatus _calculateStatus(double spent, double limit) {
    if (limit <= 0) return BudgetStatus.ok;
    
    final percentage = (spent / limit) * 100;
    
    if (percentage >= 100) {
      return BudgetStatus.exceeded;
    } else if (percentage >= 80) {
      return BudgetStatus.nearLimit;
    } else {
      return BudgetStatus.ok;
    }
  }

  Map<String, dynamic> _budgetToMap(Budget budget, int year) {
    return {
      'id': budget.id,
      'limit_amount': budget.limitAmount,
      'spent_amount': budget.spentAmount,
      'status': _statusToString(budget.status),
      'created_at': budget.createdAt.toIso8601String(),
      'updated_at': budget.updatedAt.toIso8601String(),
      'month': budget.month,
      'year': year,
      'category': budget.category,
    };
  }

  Budget _budgetFromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      limitAmount: (map['limit_amount'] as num).toDouble(),
      spentAmount: (map['spent_amount'] as num?)?.toDouble() ?? 0.0,
      status: _statusFromString(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      month: map['month'] as int,
      category: map['category'] as String?,
    );
  }

  String _statusToString(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.ok:
        return 'ok';
      case BudgetStatus.nearLimit:
        return 'nearLimit';
      case BudgetStatus.exceeded:
        return 'exceeded';
    }
  }

  BudgetStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'nearlimit':
      case 'near_limit':
      case 'near-limit':
        return BudgetStatus.nearLimit;
      case 'exceeded':
        return BudgetStatus.exceeded;
      case 'ok':
      default:
        return BudgetStatus.ok;
    }
  }
}
