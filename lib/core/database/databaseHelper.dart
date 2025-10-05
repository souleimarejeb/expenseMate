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
      version: 1,
      onCreate: _createDb,
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
  }

}
