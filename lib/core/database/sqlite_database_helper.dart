import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/expense_attachment.dart';

class SQLiteDatabaseHelper {
  static final SQLiteDatabaseHelper _instance = SQLiteDatabaseHelper._internal();
  static Database? _database;

  factory SQLiteDatabaseHelper() => _instance;

  SQLiteDatabaseHelper._internal();

  static SQLiteDatabaseHelper get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expensemate.db');
    
    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Expense Categories table
    await db.execute('''
      CREATE TABLE expense_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        budget_limit REAL DEFAULT 0.0,
        is_default INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Create Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category_id TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        payment_method TEXT,
        is_recurring INTEGER DEFAULT 0,
        recurring_frequency TEXT,
        tags TEXT,
        location TEXT,
        notes TEXT,
        receiptImagePath TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES expense_categories (id) ON DELETE CASCADE
      )
    ''');

    // Create Expense Attachments table
    await db.execute('''
      CREATE TABLE expense_attachments (
        id TEXT PRIMARY KEY,
        expense_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        uploaded_at TEXT NOT NULL,
        FOREIGN KEY (expense_id) REFERENCES expenses (id) ON DELETE CASCADE
      )
    ''');

    // Create Recurring Expenses table
    await db.execute('''
      CREATE TABLE recurring_expenses (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        category_id TEXT NOT NULL,
        description TEXT NOT NULL,
        frequency TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        last_processed TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES expense_categories (id)
      )
    ''');

    // Create Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone_number TEXT,
        profile_image_path TEXT,
        bio TEXT,
        preferences TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create Budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        limit_amount REAL NOT NULL,
        spent_amount REAL DEFAULT 0.0,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        category TEXT,
        FOREIGN KEY (category) REFERENCES expense_categories (id) ON DELETE SET NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_expenses_category_id ON expenses(category_id)');
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');
    await db.execute('CREATE INDEX idx_attachments_expense_id ON expense_attachments(expense_id)');
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_budgets_month_year ON budgets(month, year)');
    await db.execute('CREATE INDEX idx_budgets_category ON budgets(category)');
    
    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      // Add title and receiptImagePath columns to expenses table
      await db.execute('ALTER TABLE expenses ADD COLUMN title TEXT DEFAULT ""');
      await db.execute('ALTER TABLE expenses ADD COLUMN receiptImagePath TEXT');
    }
    if (oldVersion < 3) {
      // Add metadata column to expenses table
      await db.execute('ALTER TABLE expenses ADD COLUMN metadata TEXT');
    }
    if (oldVersion < 4) {
      // Check if users table exists
      var tableExists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='users'"
      );
      
      if (tableExists.isNotEmpty) {
        // Table exists, check if it has the name column
        var columns = await db.rawQuery("PRAGMA table_info(users)");
        var hasNameColumn = columns.any((col) => col['name'] == 'name');
        
        if (!hasNameColumn) {
          // Drop the old table and recreate it with the correct schema
          await db.execute('DROP TABLE IF EXISTS users');
          await db.execute('DROP INDEX IF EXISTS idx_users_email');
        }
      }
      
      // Now create the users table (if it doesn't exist or was just dropped)
      var tableExists2 = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='users'"
      );
      
      if (tableExists2.isEmpty) {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            phone_number TEXT,
            profile_image_path TEXT,
            bio TEXT,
            preferences TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_users_email ON users(email)');
      }
    }
    if (oldVersion < 5) {
      // Add budgets table
      var budgetsTableExists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='budgets'"
      );
      
      if (budgetsTableExists.isEmpty) {
        await db.execute('''
          CREATE TABLE budgets (
            id TEXT PRIMARY KEY,
            limit_amount REAL NOT NULL,
            spent_amount REAL DEFAULT 0.0,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            month INTEGER NOT NULL,
            year INTEGER NOT NULL,
            category TEXT,
            FOREIGN KEY (category) REFERENCES expense_categories (id) ON DELETE SET NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_budgets_month_year ON budgets(month, year)');
        await db.execute('CREATE INDEX idx_budgets_category ON budgets(category)');
      }
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {
        'id': 'food',
        'name': 'Food & Dining',
        'icon': '${Icons.restaurant.codePoint}', // restaurant icon
        'color': 0xFFFF6B6B,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'transport',
        'name': 'Transportation',
        'icon': '${Icons.directions_car.codePoint}', // car icon
        'color': 0xFF4ECDC4,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'shopping',
        'name': 'Shopping',
        'icon': '${Icons.shopping_bag.codePoint}', // shopping bag icon
        'color': 0xFF95E1D3,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'entertainment',
        'name': 'Entertainment',
        'icon': '${Icons.movie.codePoint}', // movie icon
        'color': 0xFFF38181,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'bills',
        'name': 'Bills & Utilities',
        'icon': '${Icons.receipt_long.codePoint}', // receipt icon
        'color': 0xFFAA96DA,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'health',
        'name': 'Healthcare',
        'icon': '${Icons.local_hospital.codePoint}', // hospital icon
        'color': 0xFFFCBAD3,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'other',
        'name': 'Other',
        'icon': '${Icons.category.codePoint}', // category icon
        'color': 0xFFB8B8D1,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (var category in defaultCategories) {
      await db.insert('expense_categories', category);
    }
  }

  // CRUD Operations for Expenses
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    final map = expense.toMap();
    // Tags are stored in metadata if needed
    return await db.insert('expenses', map);
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  Future<Expense?> getExpenseById(String id) async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return Expense.fromMap(maps.first);
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    final map = expense.toMap();
    return await db.update(
      'expenses',
      map,
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(String id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations for Categories
  Future<int> insertCategory(ExpenseCategory category) async {
    final db = await database;
    return await db.insert('expense_categories', category.toMap());
  }

  Future<List<ExpenseCategory>> getCategories() async {
    final db = await database;
    final maps = await db.query('expense_categories', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => ExpenseCategory.fromMap(maps[i]));
  }

  Future<ExpenseCategory?> getCategoryById(String id) async {
    final db = await database;
    final maps = await db.query(
      'expense_categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return ExpenseCategory.fromMap(maps.first);
  }

  Future<int> updateCategory(ExpenseCategory category) async {
    final db = await database;
    return await db.update(
      'expense_categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete(
      'expense_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations for Attachments
  Future<int> insertAttachment(ExpenseAttachment attachment) async {
    final db = await database;
    return await db.insert('expense_attachments', attachment.toMap());
  }

  Future<List<ExpenseAttachment>> getAttachmentsByExpenseId(String expenseId) async {
    final db = await database;
    final maps = await db.query(
      'expense_attachments',
      where: 'expense_id = ?',
      whereArgs: [expenseId],
    );
    return List.generate(maps.length, (i) => ExpenseAttachment.fromMap(maps[i]));
  }

  Future<int> deleteAttachment(String id) async {
    final db = await database;
    return await db.delete(
      'expense_attachments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAttachmentsByExpenseId(String expenseId) async {
    final db = await database;
    return await db.delete(
      'expense_attachments',
      where: 'expense_id = ?',
      whereArgs: [expenseId],
    );
  }

  // Statistics and Analytics
  Future<double> getTotalExpensesByCategory(String categoryId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE category_id = ?',
      [categoryId],
    );
    
    return result.first['total'] != null ? (result.first['total'] as num).toDouble() : 0.0;
  }

  Future<double> getTotalExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date BETWEEN ? AND ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    
    return result.first['total'] != null ? (result.first['total'] as num).toDouble() : 0.0;
  }

  Future<Map<String, double>> getExpensesByCategory() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT c.name, SUM(e.amount) as total
      FROM expenses e
      JOIN expense_categories c ON e.category_id = c.id
      GROUP BY c.name
    ''');
    
    Map<String, double> categoryTotals = {};
    for (var row in result) {
      categoryTotals[row['name'] as String] = (row['total'] as num).toDouble();
    }
    
    return categoryTotals;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('expenses');
    await db.delete('expense_attachments');
    await db.delete('expense_categories');
    await db.delete('recurring_expenses');
    await db.delete('users');
    await db.delete('budgets');
    
    // Re-insert default categories
    await _insertDefaultCategories(db);
  }

  // CRUD Operations for Users
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<int> updateUser(String id, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final db = await database;
    return await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
  }

  // CRUD Operations for Budgets
  Future<int> insertBudget(Map<String, dynamic> budget) async {
    final db = await database;
    return await db.insert('budgets', budget);
  }

  Future<List<Map<String, dynamic>>> getBudgets() async {
    final db = await database;
    return await db.query('budgets', orderBy: 'year DESC, month DESC');
  }

  Future<Map<String, dynamic>?> getBudgetById(String id) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<List<Map<String, dynamic>>> getBudgetsByMonth(int month, int year) async {
    final db = await database;
    return await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
  }

  Future<Map<String, dynamic>?> getBudgetByCategoryAndMonth(
    String category,
    int month,
    int year,
  ) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'category = ? AND month = ? AND year = ?',
      whereArgs: [category, month, year],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<int> updateBudget(String id, Map<String, dynamic> budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBudget(String id) async {
    final db = await database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBudgetsByMonth(int month, int year) async {
    final db = await database;
    return await db.delete(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
  }

  Future<double> getTotalBudgetForMonth(int month, int year) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(limit_amount) as total FROM budgets WHERE month = ? AND year = ?',
      [month, year],
    );
    
    return result.first['total'] != null ? (result.first['total'] as num).toDouble() : 0.0;
  }

  Future<double> getTotalSpentForMonth(int month, int year) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(spent_amount) as total FROM budgets WHERE month = ? AND year = ?',
      [month, year],
    );
    
    return result.first['total'] != null ? (result.first['total'] as num).toDouble() : 0.0;
  }
}
