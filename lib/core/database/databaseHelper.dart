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
      version: 2,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
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

    // Users table for local auth
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        avatar_url TEXT
      )
    ''');

    await db.execute('''
    CREATE TABLE budgets(
      id TEXT PRIMARY KEY,
      limit_amount REAL NOT NULL,
      spent_amount REAL NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      month INTEGER NOT NULL,
      category TEXT
    )
  ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_budgets_month ON budgets(month);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_budgets_category ON budgets(category);');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ensure users table exists when upgrading from older schema
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          avatar_url TEXT
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);');

    }
    if (oldVersion < 3) {
      print("📊 CREATING BUDGETS TABLE FOR VERSION 3");
      // Add budgets table for version 3
      await db.execute('''
      CREATE TABLE IF NOT EXISTS budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        limit_amount REAL NOT NULL,
        spent_amount REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        month INTEGER NOT NULL,
        category TEXT
      )
    ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_budgets_month ON budgets(month);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_budgets_category ON budgets(category);');
    }
  }

}
