import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  // Singleton pattern
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }


  // Opening the Database
  Future<Database> _initDatabase() async {
    // Get the path to the database file
    String path = join(await getDatabasesPath(), 'my_expensesmate_app.db');

    // Open/create the database
    return await openDatabase(
      path,
      version: 3, // Increased version for user tables
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Create the tables   here an example on how to create a table
    await db.execute('''
      CREATE TABLE example(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        image TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create expense categories table
    await db.execute('''
      CREATE TABLE expense_categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        iconCodePoint INTEGER NOT NULL,
        iconFontFamily TEXT,
        colorValue INTEGER NOT NULL,
        parentCategoryId TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (parentCategoryId) REFERENCES expense_categories(id)
      )
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        categoryId TEXT NOT NULL,
        date TEXT NOT NULL,
        receiptImagePath TEXT,
        location TEXT,
        metadata TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES expense_categories(id)
      )
    ''');

    // Create recurring expenses table
    await db.execute('''
      CREATE TABLE recurring_expenses(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        categoryId TEXT NOT NULL,
        recurrenceType INTEGER NOT NULL,
        recurrenceInterval INTEGER NOT NULL DEFAULT 1,
        startDate TEXT NOT NULL,
        endDate TEXT,
        daysOfWeek TEXT,
        dayOfMonth INTEGER,
        nextDueDate TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        metadata TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES expense_categories(id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');
    await db.execute('CREATE INDEX idx_expenses_category ON expenses(categoryId)');
    await db.execute('CREATE INDEX idx_recurring_next_due ON recurring_expenses(nextDueDate)');

    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT,
        avatarPath TEXT,
        dateOfBirth INTEGER,
        bio TEXT,
        occupation TEXT,
        monthlyIncome REAL,
        currency TEXT DEFAULT 'USD',
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        isActive INTEGER DEFAULT 1,
        preferences TEXT
      )
    ''');

    // Create user preferences table
    await db.execute('''
      CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        theme TEXT DEFAULT 'system',
        language TEXT DEFAULT 'en',
        currency TEXT DEFAULT 'USD',
        enableNotifications INTEGER DEFAULT 1,
        enableBiometric INTEGER DEFAULT 0,
        enableBackup INTEGER DEFAULT 1,
        enableAnalytics INTEGER DEFAULT 1,
        dateFormat TEXT DEFAULT 'MM/dd/yyyy',
        timeFormat TEXT DEFAULT '12h',
        categoryVisibility TEXT DEFAULT '{}',
        dashboardLayout TEXT DEFAULT '{}',
        favoriteCategories TEXT DEFAULT '[]',
        budgetAlertThreshold REAL DEFAULT 0.8,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for users
    await db.execute('CREATE INDEX idx_users_email ON users (email)');
    await db.execute('CREATE INDEX idx_users_active ON users (isActive)');
    await db.execute('CREATE INDEX idx_preferences_user ON user_preferences (userId)');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add expense-related tables for version 2
      await db.execute('''
        CREATE TABLE expense_categories(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          iconCodePoint INTEGER NOT NULL,
          iconFontFamily TEXT,
          colorValue INTEGER NOT NULL,
          parentCategoryId TEXT,
          isActive INTEGER NOT NULL DEFAULT 1,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (parentCategoryId) REFERENCES expense_categories(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE expenses(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          amount REAL NOT NULL,
          categoryId TEXT NOT NULL,
          date TEXT NOT NULL,
          receiptImagePath TEXT,
          location TEXT,
          metadata TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (categoryId) REFERENCES expense_categories(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE recurring_expenses(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          amount REAL NOT NULL,
          categoryId TEXT NOT NULL,
          recurrenceType INTEGER NOT NULL,
          recurrenceInterval INTEGER NOT NULL DEFAULT 1,
          startDate TEXT NOT NULL,
          endDate TEXT,
          daysOfWeek TEXT,
          dayOfMonth INTEGER,
          nextDueDate TEXT,
          isActive INTEGER NOT NULL DEFAULT 1,
          metadata TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (categoryId) REFERENCES expense_categories(id)
        )
      ''');

      await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');
      await db.execute('CREATE INDEX idx_expenses_category ON expenses(categoryId)');
      await db.execute('CREATE INDEX idx_recurring_next_due ON recurring_expenses(nextDueDate)');
    }

    if (oldVersion < 3) {
      // Add user-related tables for version 3
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          firstName TEXT NOT NULL,
          lastName TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          phone TEXT,
          avatarPath TEXT,
          dateOfBirth INTEGER,
          bio TEXT,
          occupation TEXT,
          monthlyIncome REAL,
          currency TEXT DEFAULT 'USD',
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL,
          isActive INTEGER DEFAULT 1,
          preferences TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE user_preferences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          theme TEXT DEFAULT 'system',
          language TEXT DEFAULT 'en',
          currency TEXT DEFAULT 'USD',
          enableNotifications INTEGER DEFAULT 1,
          enableBiometric INTEGER DEFAULT 0,
          enableBackup INTEGER DEFAULT 1,
          enableAnalytics INTEGER DEFAULT 1,
          dateFormat TEXT DEFAULT 'MM/dd/yyyy',
          timeFormat TEXT DEFAULT '12h',
          categoryVisibility TEXT DEFAULT '{}',
          dashboardLayout TEXT DEFAULT '{}',
          favoriteCategories TEXT DEFAULT '[]',
          budgetAlertThreshold REAL DEFAULT 0.8,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('CREATE INDEX idx_users_email ON users (email)');
      await db.execute('CREATE INDEX idx_users_active ON users (isActive)');
      await db.execute('CREATE INDEX idx_preferences_user ON user_preferences (userId)');
    }
  }

}
