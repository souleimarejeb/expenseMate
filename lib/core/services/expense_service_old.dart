import 'package:uuid/uuid.dart';
import '../database/databaseHelper.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/recurring_expense.dart';

class ExpenseService {
  static final ExpenseService _instance = ExpenseService._internal();
  factory ExpenseService() => _instance;
  ExpenseService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

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
  // Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    final maps = await _dbHelper.getAllExpenses();
    
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Read expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // Read expenses by category
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // Read single expense by ID
  Future<Expense?> getExpenseById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    }
    return null;
  }

  // Update expense
  Future<bool> updateExpense(Expense expense) async {
    final db = await _dbHelper.database;
    final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
    
    final count = await db.update(
      'expenses',
      updatedExpense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );

    return count > 0;
  }

  // Delete expense
  Future<bool> deleteExpense(String id) async {
    final db = await _dbHelper.database;
    final count = await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );

    return count > 0;
  }

  // Get expenses summary (total amount by category, month, etc.)
  Future<Map<String, double>> getExpensesSummaryByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbHelper.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'WHERE e.date >= ? AND e.date <= ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT c.name as categoryName, SUM(e.amount) as totalAmount
      FROM expenses e
      JOIN expense_categories c ON e.categoryId = c.id
      $whereClause
      GROUP BY e.categoryId, c.name
      ORDER BY totalAmount DESC
    ''', whereArgs);

    Map<String, double> summary = {};
    for (var row in result) {
      summary[row['categoryName']] = row['totalAmount'];
    }

    return summary;
  }

  // Get monthly expense totals
  Future<Map<String, double>> getMonthlyExpenseTotals(int year) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        strftime('%m', date) as month,
        SUM(amount) as totalAmount
      FROM expenses 
      WHERE strftime('%Y', date) = ?
      GROUP BY strftime('%Y-%m', date)
      ORDER BY month
    ''', [year.toString()]);

    Map<String, double> monthlyTotals = {};
    for (var row in result) {
      String month = _getMonthName(int.parse(row['month']));
      monthlyTotals[month] = row['totalAmount'];
    }

    return monthlyTotals;
  }

  // CRUD Operations for Categories

  // Create category
  Future<String> createCategory(ExpenseCategory category) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final now = DateTime.now();
    
    final categoryWithId = category.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert('expense_categories', categoryWithId.toMap());
    return id;
  }

  // Get all categories
  Future<List<ExpenseCategory>> getAllCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expense_categories',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => ExpenseCategory.fromMap(maps[i]));
  }

  // Initialize default categories
  Future<void> initializeDefaultCategories() async {
    final existingCategories = await getAllCategories();
    if (existingCategories.isEmpty) {
      final defaultCategories = ExpenseCategory.getDefaultCategories();
      for (var category in defaultCategories) {
        await createCategory(category);
      }
    }
  }

  // CRUD Operations for Recurring Expenses

  // Create recurring expense
  Future<String> createRecurringExpense(RecurringExpense recurringExpense) async {
    final db = await _dbHelper.database;
    final id = _uuid.v4();
    final now = DateTime.now();
    
    final recurringExpenseWithId = recurringExpense.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
      nextDueDate: recurringExpense.nextDueDate ?? recurringExpense.calculateNextDueDate(),
    );

    await db.insert('recurring_expenses', recurringExpenseWithId.toMap());
    return id;
  }

  // Get all recurring expenses
  Future<List<RecurringExpense>> getAllRecurringExpenses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_expenses',
      orderBy: 'nextDueDate ASC',
    );

    return List.generate(maps.length, (i) => RecurringExpense.fromMap(maps[i]));
  }

  // Get due recurring expenses
  Future<List<RecurringExpense>> getDueRecurringExpenses() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_expenses',
      where: 'isActive = ? AND nextDueDate <= ?',
      whereArgs: [1, now],
      orderBy: 'nextDueDate ASC',
    );

    return List.generate(maps.length, (i) => RecurringExpense.fromMap(maps[i]));
  }

  // Update recurring expense next due date
  Future<bool> updateRecurringExpenseNextDue(String id, DateTime nextDueDate) async {
    final db = await _dbHelper.database;
    final count = await db.update(
      'recurring_expenses',
      {
        'nextDueDate': nextDueDate.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    return count > 0;
  }

  // Process due recurring expenses (create actual expenses)
  Future<List<String>> processDueRecurringExpenses() async {
    final dueRecurringExpenses = await getDueRecurringExpenses();
    List<String> createdExpenseIds = [];

    for (var recurringExpense in dueRecurringExpenses) {
      // Create actual expense
      final expense = Expense(
        title: recurringExpense.title,
        description: '${recurringExpense.description} (Recurring)',
        amount: recurringExpense.amount,
        categoryId: recurringExpense.categoryId,
        date: recurringExpense.nextDueDate ?? DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final expenseId = await createExpense(expense);
      createdExpenseIds.add(expenseId);

      // Update next due date
      final nextDueDate = recurringExpense.calculateNextDueDate();
      await updateRecurringExpenseNextDue(recurringExpense.id!, nextDueDate);
    }

    return createdExpenseIds;
  }

  // Search expenses
  Future<List<Expense>> searchExpenses(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Get total expenses for a specific period
  Future<double> getTotalExpensesForPeriod(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM expenses 
      WHERE date >= ? AND date <= ?
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return result.first['total'] ?? 0.0;
  }

  // Delete all expenses (for testing/reset purposes)
  Future<void> deleteAllExpenses() async {
    final db = await _dbHelper.database;
    await db.delete('expenses');
  }
}