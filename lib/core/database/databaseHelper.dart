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
      version: 2, // Increased version for new tables
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
  }

}
