// budget_service.dart
import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:flutter/foundation.dart';
import 'package:expensemate/core/repositories/budget_repository.dart';


class BudgetService {
  BudgetService._internal();
  static final BudgetService _instance = BudgetService._internal();
  factory BudgetService() => _instance;

  final BudgetRepository _repository = BudgetRepository();
  final ValueNotifier<List<Budget>> currentBudgets = ValueNotifier<List<Budget>>([]);

  Future<void> loadCurrentMonthBudgets() async {
    final currentMonth = DateTime.now().month;
    final budgets = await _repository.getBudgetsByMonth(currentMonth);
    currentBudgets.value = budgets;
  }

  Future<bool> createBudget({
    required double limitAmount,
    required int month,
    String? category,
  }) async {
    try {
      final now = DateTime.now();
      await _repository.createBudget(
        limitAmount: limitAmount,
        month: month,
        createdAt: now,
        updatedAt: now,
        category: category,
      );
      
      // Reload current budgets if we're creating for current month
      if (month == DateTime.now().month) {
        await loadCurrentMonthBudgets();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> addExpenseToBudget(String budgetId, double amount) async {
    await _repository.addExpenseToBudget(id: budgetId, expenseAmount: amount);
    await loadCurrentMonthBudgets();
  }

  Future<List<Budget>> getBudgetsByMonth(int month) async {
    return await _repository.getBudgetsByMonth(month);
  }

  Future<void> deleteBudget(String id) async {
    await _repository.deleteBudget(id);
    await loadCurrentMonthBudgets();
  }
}