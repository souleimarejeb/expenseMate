import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/databaseHelper.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/recurring_expense.dart';

class ExpenseService {
  static final ExpenseService _instance = ExpenseService._internal();
  factory ExpenseService() => _instance;
  ExpenseService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  // CRUD Operations for Expenses
  
  // Create a new expense
  Future<String> createExpense(Expense expense) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    
    final expenseWithId = expense.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );
    
    await _dbHelper.insert('expenses', expenseWithId.toMap());
    return id;
  }

  // Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    final maps = await _dbHelper.getAllExpenses();
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Get expense by ID
  Future<Expense?> getExpenseById(String id) async {
    final maps = await _dbHelper.getAllExpenses();
    final expenseMap = maps.where((map) => map['id'] == id).firstOrNull;
    return expenseMap != null ? Expense.fromMap(expenseMap) : null;
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    final maps = await _dbHelper.getExpensesByCategory(categoryId);
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final maps = await _dbHelper.getExpensesByDateRange(start, end);
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Update expense
  Future<bool> updateExpense(Expense expense) async {
    final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
    final count = await _dbHelper.update('expenses', updatedExpense.toMap());
    return count > 0;
  }

  // Delete expense
  Future<bool> deleteExpense(String id) async {
    final count = await _dbHelper.delete('expenses', where: 'id = ?', whereArgs: [id]);
    return count > 0;
  }

  // Search expenses
  Future<List<Expense>> searchExpenses(String query) async {
    final maps = await _dbHelper.searchExpenses(query);
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Get monthly spending summary
  Future<Map<String, double>> getMonthlySpending() async {
    final expenses = await getAllExpenses();
    Map<String, double> monthlySummary = {};
    
    for (var expense in expenses) {
      String monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlySummary[monthKey] = (monthlySummary[monthKey] ?? 0.0) + expense.amount;
    }
    
    return monthlySummary;
  }

  // Get category-wise spending
  Future<Map<String, double>> getCategorySpending() async {
    final expenses = await getAllExpenses();
    Map<String, double> categorySpending = {};
    
    for (var expense in expenses) {
      categorySpending[expense.categoryId] = (categorySpending[expense.categoryId] ?? 0.0) + expense.amount;
    }
    
    return categorySpending;
  }

  // CRUD Operations for Categories

  // Create category
  Future<String> createCategory(ExpenseCategory category) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    
    final categoryWithId = category.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );
    
    await _dbHelper.insert('expense_categories', categoryWithId.toMap());
    return id;
  }

  // Get all categories
  Future<List<ExpenseCategory>> getAllCategories() async {
    final maps = await _dbHelper.getAllCategories();
    return List.generate(maps.length, (i) {
      return ExpenseCategory.fromMap(maps[i]);
    });
  }

  // CRUD Operations for Recurring Expenses (Simplified)

  // Create recurring expense
  Future<String> createRecurringExpense(RecurringExpense recurringExpense) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    
    final recurringExpenseWithId = recurringExpense.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );
    
    await _dbHelper.insert('recurring_expenses', recurringExpenseWithId.toMap());
    return id;
  }

  // Get all recurring expenses
  Future<List<RecurringExpense>> getAllRecurringExpenses() async {
    // Since we don't have full recurring expense support in LocalStorage, return empty list
    return [];
  }

  // Update recurring expense
  Future<bool> updateRecurringExpense(RecurringExpense recurringExpense) async {
    final updatedRecurringExpense = recurringExpense.copyWith(updatedAt: DateTime.now());
    final count = await _dbHelper.update('recurring_expenses', updatedRecurringExpense.toMap());
    return count > 0;
  }

  // Get analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    return await _dbHelper.getAnalytics();
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _dbHelper.delete('expenses');
  }

  // Initialize default categories
  Future<void> initializeDefaultCategories() async {
    final categories = await getAllCategories();
    
    if (categories.isEmpty) {
      // Create default categories
      final defaultCategories = [
        ExpenseCategory(
          name: 'Food & Dining',
          description: 'Restaurants, groceries, and dining out',
          icon: Icons.restaurant,
          color: Colors.red,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ExpenseCategory(
          name: 'Transport',
          description: 'Gas, public transport, car maintenance',
          icon: Icons.directions_car,
          color: Colors.blue,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ExpenseCategory(
          name: 'Entertainment',
          description: 'Movies, games, hobbies',
          icon: Icons.movie,
          color: Colors.purple,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ExpenseCategory(
          name: 'Bills & Utilities',
          description: 'Electricity, water, internet, rent',
          icon: Icons.receipt_long,
          color: Colors.orange,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ExpenseCategory(
          name: 'Shopping',
          description: 'Clothes, electronics, general shopping',
          icon: Icons.shopping_bag,
          color: Colors.green,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      for (final category in defaultCategories) {
        await createCategory(category);
      }
    }
  }

  // Update recurring expense next due date
  Future<bool> updateRecurringExpenseNextDue(String recurringExpenseId, DateTime nextDue) async {
    // For now, return true as we don't have full recurring expense implementation
    return true;
  }

  // Get monthly expense totals for a year
  Future<Map<String, double>> getMonthlyExpenseTotals(int year) async {
    final expenses = await getAllExpenses();
    final Map<String, double> monthlyTotals = {};
    
    // Initialize all months with 0
    for (int month = 1; month <= 12; month++) {
      monthlyTotals[month.toString()] = 0.0;
    }
    
    // Calculate totals for each month
    for (final expense in expenses) {
      if (expense.date.year == year) {
        final monthKey = expense.date.month.toString();
        monthlyTotals[monthKey] = 
            (monthlyTotals[monthKey] ?? 0.0) + expense.amount;
      }
    }
    
    return monthlyTotals;
  }

  // Get total expenses for a specific period
  Future<double> getTotalExpensesForPeriod(DateTime startDate, DateTime endDate) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    double total = 0.0;
    for (final expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  // Process due recurring expenses
  Future<List<String>> processDueRecurringExpenses() async {
    // For now, return empty list as we don't have full recurring expense implementation
    return [];
  }

  // Get expenses summary by category
  Future<Map<String, double>> getExpensesSummaryByCategory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    final Map<String, double> categoryTotals = {};
    
    for (final expense in expenses) {
      categoryTotals[expense.categoryId] = 
          (categoryTotals[expense.categoryId] ?? 0.0) + expense.amount;
    }
    
    return categoryTotals;
  }

}