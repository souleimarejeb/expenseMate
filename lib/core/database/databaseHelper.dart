import 'package:sqflite/sqflite.dart';
import 'sqlite_database_helper.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/expense_attachment.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static SQLiteDatabaseHelper get _sqlite => SQLiteDatabaseHelper.instance;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  // For compatibility - returns the database instance
  Future<Database> get database async => await _sqlite.database;

  // Initialize method for compatibility
  Future<void> initDatabase() async {
    await _sqlite.database; // Initialize SQLite database
  }

  // Database methods for compatibility
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    
    switch (table) {
      case 'expenses':
        final expense = Expense.fromMap(values);
        return await _sqlite.insertExpense(expense);
      case 'expense_categories':
        final category = ExpenseCategory.fromMap(values);
        return await _sqlite.insertCategory(category);
      case 'expense_attachments':
        return await db.insert(table, values);
      case 'recurring_expenses':
        return await db.insert(table, values);
      default:
        return await db.insert(table, values);
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
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(String table, Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    await db.execute(sql, arguments);
  }

  // Delegate methods from original DatabaseHelper
  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final expenses = await _sqlite.getExpenses();
    return expenses.map((e) => e.toMap()).toList();
  }

  Future<void> addExpense(Map<String, dynamic> expense) async {
    final expenseObj = Expense.fromMap(expense);
    await _sqlite.insertExpense(expenseObj);
  }

  Future<void> updateExpense(Map<String, dynamic> expense) async {
    final expenseObj = Expense.fromMap(expense);
    await _sqlite.updateExpense(expenseObj);
  }

  Future<void> deleteExpense(String id) async {
    await _sqlite.deleteExpense(id);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final categories = await _sqlite.getCategories();
    return categories.map((c) => c.toMap()).toList();
  }

  Future<void> addCategory(Map<String, dynamic> category) async {
    final categoryObj = ExpenseCategory.fromMap(category);
    await _sqlite.insertCategory(categoryObj);
  }

  Future<List<Map<String, dynamic>>> searchExpenses(String query) async {
    final db = await database;
    final results = await db.query(
      'expenses',
      where: 'description LIKE ? OR notes LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return results;
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    final expenses = await _sqlite.getExpenses();
    final spendingByCategory = await _sqlite.getExpensesByCategory();
    
    double totalSpending = 0;
    for (var expense in expenses) {
      totalSpending += expense.amount;
    }
    
    return {
      'totalExpenses': expenses.length,
      'totalSpending': totalSpending,
      'spendingByCategory': spendingByCategory,
    };
  }

  Future<List<Map<String, dynamic>>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final results = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return results;
  }

  Future<List<Map<String, dynamic>>> getExpensesByCategory(String categoryId) async {
    final db = await database;
    final results = await db.query(
      'expenses',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return results;
  }

  // Attachment methods
  Future<String> insertExpenseAttachment(Map<String, dynamic> attachment) async {
    final attachmentObj = ExpenseAttachment.fromMap(attachment);
    await _sqlite.insertAttachment(attachmentObj);
    return attachmentObj.id!;
  }

  Future<List<Map<String, dynamic>>> getExpenseAttachments(String expenseId) async {
    final attachments = await _sqlite.getAttachmentsByExpenseId(expenseId);
    return attachments.map((a) => a.toMap()).toList();
  }

  Future<List<Map<String, dynamic>>> getAllExpenseAttachments() async {
    final db = await database;
    return await db.query('expense_attachments');
  }

  Future<int> deleteExpenseAttachment(String attachmentId) async {
    return await _sqlite.deleteAttachment(attachmentId);
  }

  // Raw query support for legacy code
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  // Close database
  Future<void> close() async {
    await _sqlite.close();
  }
}