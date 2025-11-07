import 'local_storage_helper.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/expense_attachment.dart';

import 'local_storage_helper.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static LocalStorageHelper get _localStorage => LocalStorageHelper.instance;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  // For compatibility - returns the LocalStorageHelper instance
  LocalStorageHelper get database => _localStorage;

  // Initialize method for compatibility
  Future<void> initDatabase() async {
    await _localStorage.initialize();
  }

  // SQLite-like methods for compatibility
  Future<int> insert(String table, Map<String, dynamic> values) async {
    switch (table) {
      case 'expenses':
        final expense = Expense.fromMap(values);
        await _localStorage.insertExpense(expense);
        return 1;
      case 'expense_categories':
        final category = ExpenseCategory.fromMap(values);
        await _localStorage.insertCategory(category);
        return 1;
      case 'recurring_expenses':
      case 'expense_learning':
        // For unsupported tables, just return success
        return 1;
      default:
        return 0;
    }
  }

  Future<List<Map<String, dynamic>>> query(String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    switch (table) {
      case 'expenses':
        final expenses = await _localStorage.getExpenses();
        return expenses.map((e) => e.toMap()).toList();
      case 'expense_categories':
        final categories = await _localStorage.getCategories();
        return categories.map((c) => c.toMap()).toList();
      default:
        return [];
    }
  }

  Future<int> update(String table, Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    switch (table) {
      case 'expenses':
        final expense = Expense.fromMap(values);
        await _localStorage.updateExpense(expense);
        return 1;
      default:
        return 0;
    }
  }

  Future<int> delete(String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (table == 'expenses') {
      if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
        // Assuming the where clause is for id
        await _localStorage.deleteExpense(whereArgs[0].toString());
        return 1;
      } else {
        // Clear all expenses - need to delete one by one since there's no clearAll method
        final expenses = await _localStorage.getExpenses();
        for (final expense in expenses) {
          await _localStorage.deleteExpense(expense.id!);
        }
        return expenses.length;
      }
    }
    return 0;
  }

  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    // For compatibility with SQL execute commands
    // Most of these are table creation or index creation which we don't need for SharedPreferences
    print('SQL execute called (ignored in SharedPreferences): $sql');
  }

  // Delegate methods from original DatabaseHelper
  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final expenses = await _localStorage.getExpenses();
    return expenses.map((e) => e.toMap()).toList();
  }

  Future<void> addExpense(Map<String, dynamic> expense) async {
    final expenseObj = Expense.fromMap(expense);
    await _localStorage.insertExpense(expenseObj);
  }

  Future<void> updateExpense(Map<String, dynamic> expense) async {
    final expenseObj = Expense.fromMap(expense);
    await _localStorage.updateExpense(expenseObj);
  }

  Future<void> deleteExpense(String id) async {
    await _localStorage.deleteExpense(id);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final categories = await _localStorage.getCategories();
    return categories.map((c) => c.toMap()).toList();
  }

  Future<void> addCategory(Map<String, dynamic> category) async {
    final categoryObj = ExpenseCategory.fromMap(category);
    await _localStorage.insertCategory(categoryObj);
  }

  Future<List<Map<String, dynamic>>> searchExpenses(String query) async {
    final expenses = await _localStorage.searchExpenses(query);
    return expenses.map((e) => e.toMap()).toList();
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    // Build analytics from LocalStorage data
    final expenses = await _localStorage.getExpenses();
    final totalSpending = await _localStorage.getTotalSpending();
    final spendingByCategory = await _localStorage.getSpendingByCategory();
    
    return {
      'totalExpenses': expenses.length,
      'totalSpending': totalSpending,
      'spendingByCategory': spendingByCategory,
    };
  }

  Future<List<Map<String, dynamic>>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final expenses = await _localStorage.getExpensesByDateRange(start, end);
    return expenses.map((e) => e.toMap()).toList();
  }

  Future<List<Map<String, dynamic>>> getExpensesByCategory(String categoryId) async {
    final expenses = await _localStorage.getExpensesByCategory(categoryId);
    return expenses.map((e) => e.toMap()).toList();
  }

  // Attachment methods
  Future<String> insertExpenseAttachment(Map<String, dynamic> attachment) async {
    // For simplified version, just return a generated ID
    return 'attachment_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<List<Map<String, dynamic>>> getExpenseAttachments(String expenseId) async {
    // For simplified version, return empty list
    return [];
  }

  Future<List<Map<String, dynamic>>> getAllExpenseAttachments() async {
    // For simplified version, return empty list
    return [];
  }

  Future<int> deleteExpenseAttachment(String attachmentId) async {
    // For simplified version, always return success
    return 1;
  }

  // Raw query support for legacy code
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    // For compatibility, we'll try to handle some basic queries
    if (sql.contains('SELECT * FROM expenses')) {
      return await getAllExpenses();
    } else if (sql.contains('SELECT * FROM expense_categories')) {
      return await getAllCategories();
    }
    
    // For unsupported queries, return empty list
    return [];
  }
}