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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create User Preferences table
    await db.execute('''
      CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        theme TEXT DEFAULT 'light',
        currency TEXT DEFAULT 'USD',
        notification_enabled INTEGER DEFAULT 1,
        budget_limit REAL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

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
        user_id INTEGER,
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
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
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
        user_id INTEGER,
        amount REAL NOT NULL,
        category_id TEXT NOT NULL,
        description TEXT NOT NULL,
        frequency TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        last_processed TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES expense_categories (id)
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_expenses_user_id ON expenses(user_id)');
    await db.execute('CREATE INDEX idx_expenses_category_id ON expenses(category_id)');
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');
    await db.execute('CREATE INDEX idx_attachments_expense_id ON expense_attachments(expense_id)');
    
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
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {
        'id': 'food',
        'name': 'Food & Dining',
        'icon': '🍔',
        'color': 0xFFFF6B6B,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'transport',
        'name': 'Transportation',
        'icon': '🚗',
        'color': 0xFF4ECDC4,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'shopping',
        'name': 'Shopping',
        'icon': '🛍️',
        'color': 0xFF95E1D3,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'entertainment',
        'name': 'Entertainment',
        'icon': '🎬',
        'color': 0xFFF38181,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'bills',
        'name': 'Bills & Utilities',
        'icon': '📄',
        'color': 0xFFAA96DA,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'health',
        'name': 'Healthcare',
        'icon': '⚕️',
        'color': 0xFFFCBAD3,
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'other',
        'name': 'Other',
        'icon': '📌',
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

  Future<List<Expense>> getExpenses({String? userId}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    
    if (userId != null) {
      maps = await db.query(
        'expenses',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
    } else {
      maps = await db.query('expenses', orderBy: 'date DESC');
    }
    
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

  // User Operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  // User Preferences Operations
  Future<int> insertUserPreferences(Map<String, dynamic> preferences) async {
    final db = await database;
    return await db.insert('user_preferences', preferences);
  }

  Future<List<Map<String, dynamic>>> getUserPreferences({int? userId}) async {
    final db = await database;
    if (userId != null) {
      return await db.query(
        'user_preferences',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
    return await db.query('user_preferences');
  }

  Future<int> updateUserPreferences(Map<String, dynamic> preferences) async {
    final db = await database;
    return await db.update(
      'user_preferences',
      preferences,
      where: 'user_id = ?',
      whereArgs: [preferences['user_id']],
    );
  }

  // Statistics and Analytics
  Future<double> getTotalExpensesByCategory(String categoryId, {String? userId}) async {
    final db = await database;
    String whereClause = 'category_id = ?';
    List<dynamic> whereArgs = [categoryId];
    
    if (userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(userId);
    }
    
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE $whereClause',
      whereArgs,
    );
    
    return result.first['total'] != null ? (result.first['total'] as num).toDouble() : 0.0;
  }

  Future<double> getTotalExpensesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  }) async {
    final db = await database;
    String whereClause = 'date BETWEEN ? AND ?';
    List<dynamic> whereArgs = [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ];
    
    if (userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(userId);
    }
    
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE $whereClause',
      whereArgs,
    );
    
    return result.first['total'] != null ? (result.first['total'] as num).toDouble() : 0.0;
  }

  Future<Map<String, double>> getExpensesByCategory({String? userId}) async {
    final db = await database;
    String query = '''
      SELECT c.name, SUM(e.amount) as total
      FROM expenses e
      JOIN expense_categories c ON e.category_id = c.id
    ''';
    
    List<dynamic> whereArgs = [];
    if (userId != null) {
      query += ' WHERE e.user_id = ?';
      whereArgs.add(userId);
    }
    
    query += ' GROUP BY c.name';
    
    final result = await db.rawQuery(query, whereArgs);
    
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
    await db.delete('user_preferences');
    await db.delete('users');
    await db.delete('recurring_expenses');
    
    // Re-insert default categories
    await _insertDefaultCategories(db);
  }
}
