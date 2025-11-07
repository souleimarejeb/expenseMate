import 'local_storage_helper.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/expense_attachment.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  // Singleton pattern
  DatabaseHelper._internal();

  final LocalStorageHelper _localStorage = LocalStorageHelper.instance;

  // Initialize the database (just initializes local storage)
  Future<void> initialize() async {
    await _localStorage.initialize();
  }

  // EXPENSE METHODS
  
  Future<String> insertExpense(Expense expense) async {
    return await _localStorage.insertExpense(expense);
  }

  Future<List<Expense>> getExpenses() async {
    return await _localStorage.getExpenses();
  }

  Future<Expense?> getExpense(String id) async {
    return await _localStorage.getExpense(id);
  }

  Future<int> updateExpense(Expense expense) async {
    return await _localStorage.updateExpense(expense);
  }

  Future<int> deleteExpense(String id) async {
    return await _localStorage.deleteExpense(id);
  }

  // CATEGORY METHODS
  
  Future<String> insertCategory(ExpenseCategory category) async {
    return await _localStorage.insertCategory(category);
  }

  Future<List<ExpenseCategory>> getCategories() async {
    return await _localStorage.getCategories();
  }

  Future<ExpenseCategory?> getCategory(String id) async {
    return await _localStorage.getCategory(id);
  }

  Future<int> updateCategory(ExpenseCategory category) async {
    return await _localStorage.updateCategory(category);
  }

  Future<int> deleteCategory(String id) async {
    return await _localStorage.deleteCategory(id);
  }
    // Get the path to the database file
    String path = join(await getDatabasesPath(), 'my_expensesmate_app.db');

    // Open/create the database
    return await openDatabase(
      path,
      version: 4, // Increased version for advanced features
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
      onConfigure: (db) async {
        // Enable foreign key constraints
        await db.rawQuery('PRAGMA foreign_keys = ON');
      },
      onOpen: (db) async {
        // Configure database after opening
        try {
          // Enable Write-Ahead Logging for better performance
          await db.rawQuery('PRAGMA journal_mode = WAL');
          // Enable synchronous mode for better safety
          await db.rawQuery('PRAGMA synchronous = NORMAL');
        } catch (e) {
          print('Database configuration warning: $e');
          // Continue even if PRAGMA commands fail
        }
      },
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

    // Create advanced indexes for better performance
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');
    await db.execute('CREATE INDEX idx_expenses_category ON expenses(categoryId)');
    await db.execute('CREATE INDEX idx_expenses_amount ON expenses(amount)');
    await db.execute('CREATE INDEX idx_expenses_date_category ON expenses(date, categoryId)');
    await db.execute('CREATE INDEX idx_expenses_title ON expenses(title)');
    await db.execute('CREATE INDEX idx_expenses_description ON expenses(description)');
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

    // Create expense attachments table
    await db.execute('''
      CREATE TABLE expense_attachments(
        id TEXT PRIMARY KEY,
        expenseId TEXT NOT NULL,
        fileName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        fileType TEXT NOT NULL,
        fileSize INTEGER,
        mimeType TEXT,
        isReceipt INTEGER DEFAULT 1,
        ocrText TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (expenseId) REFERENCES expenses(id) ON DELETE CASCADE
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE budgets(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        categoryId TEXT,
        amount REAL NOT NULL,
        period TEXT NOT NULL, -- monthly, weekly, yearly
        startDate TEXT NOT NULL,
        endDate TEXT,
        isActive INTEGER DEFAULT 1,
        alertThreshold REAL DEFAULT 0.8,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES expense_categories(id)
      )
    ''');

    // Create expense sharing table
    await db.execute('''
      CREATE TABLE expense_shares(
        id TEXT PRIMARY KEY,
        expenseId TEXT NOT NULL,
        sharedWithEmail TEXT NOT NULL,
        shareAmount REAL NOT NULL,
        isPaid INTEGER DEFAULT 0,
        paidDate TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (expenseId) REFERENCES expenses(id) ON DELETE CASCADE
      )
    ''');

    // Create expense tags table for flexible categorization
    await db.execute('''
      CREATE TABLE expense_tags(
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        color TEXT NOT NULL,
        icon TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create expense-tag junction table
    await db.execute('''
      CREATE TABLE expense_tag_relations(
        expenseId TEXT NOT NULL,
        tagId TEXT NOT NULL,
        PRIMARY KEY (expenseId, tagId),
        FOREIGN KEY (expenseId) REFERENCES expenses(id) ON DELETE CASCADE,
        FOREIGN KEY (tagId) REFERENCES expense_tags(id) ON DELETE CASCADE
      )
    ''');

    // Create spending patterns analytics table
    await db.execute('''
      CREATE TABLE spending_analytics(
        id TEXT PRIMARY KEY,
        period TEXT NOT NULL, -- daily, weekly, monthly
        periodDate TEXT NOT NULL,
        categoryId TEXT,
        totalAmount REAL NOT NULL,
        transactionCount INTEGER NOT NULL,
        averageAmount REAL NOT NULL,
        maxAmount REAL NOT NULL,
        minAmount REAL NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES expense_categories(id)
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

    if (oldVersion < 4) {
      // Add fancy features for version 4
      
      // Add new indexes for better performance
      await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_amount ON expenses(amount)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_date_category ON expenses(date, categoryId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_title ON expenses(title)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_expenses_description ON expenses(description)');

      // Create expense attachments table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS expense_attachments(
          id TEXT PRIMARY KEY,
          expenseId TEXT NOT NULL,
          fileName TEXT NOT NULL,
          filePath TEXT NOT NULL,
          fileType TEXT NOT NULL,
          fileSize INTEGER,
          mimeType TEXT,
          isReceipt INTEGER DEFAULT 1,
          ocrText TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (expenseId) REFERENCES expenses(id) ON DELETE CASCADE
        )
      ''');

      // Create budgets table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS budgets(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          categoryId TEXT,
          amount REAL NOT NULL,
          period TEXT NOT NULL,
          startDate TEXT NOT NULL,
          endDate TEXT,
          isActive INTEGER DEFAULT 1,
          alertThreshold REAL DEFAULT 0.8,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (categoryId) REFERENCES expense_categories(id)
        )
      ''');

      // Create expense sharing table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS expense_shares(
          id TEXT PRIMARY KEY,
          expenseId TEXT NOT NULL,
          sharedWithEmail TEXT NOT NULL,
          shareAmount REAL NOT NULL,
          isPaid INTEGER DEFAULT 0,
          paidDate TEXT,
          notes TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (expenseId) REFERENCES expenses(id) ON DELETE CASCADE
        )
      ''');

      // Create expense tags table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS expense_tags(
          id TEXT PRIMARY KEY,
          name TEXT UNIQUE NOT NULL,
          color TEXT NOT NULL,
          icon TEXT,
          createdAt TEXT NOT NULL
        )
      ''');

      // Create expense-tag junction table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS expense_tag_relations(
          expenseId TEXT NOT NULL,
          tagId TEXT NOT NULL,
          PRIMARY KEY (expenseId, tagId),
          FOREIGN KEY (expenseId) REFERENCES expenses(id) ON DELETE CASCADE,
          FOREIGN KEY (tagId) REFERENCES expense_tags(id) ON DELETE CASCADE
        )
      ''');

      // Create spending analytics table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS spending_analytics(
          id TEXT PRIMARY KEY,
          period TEXT NOT NULL,
          periodDate TEXT NOT NULL,
          categoryId TEXT,
          totalAmount REAL NOT NULL,
          transactionCount INTEGER NOT NULL,
          averageAmount REAL NOT NULL,
          maxAmount REAL NOT NULL,
          minAmount REAL NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (categoryId) REFERENCES expense_categories(id)
        )
      ''');

      // Create additional indexes for new tables
      await db.execute('CREATE INDEX IF NOT EXISTS idx_attachments_expense ON expense_attachments(expenseId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_budgets_category ON budgets(categoryId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_budgets_period ON budgets(period, startDate)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_shares_expense ON expense_shares(expenseId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_analytics_period ON spending_analytics(period, periodDate)');
    }
  }

  // Expense Attachments Methods
  
  Future<String> insertExpenseAttachment(ExpenseAttachment attachment) async {
    final db = await database;
    final id = attachment.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final attachmentWithId = attachment.copyWith(id: id);
    
    await db.insert(
      'expense_attachments',
      attachmentWithId.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return id;
  }

  Future<List<ExpenseAttachment>> getExpenseAttachments(String expenseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expense_attachments',
      where: 'expenseId = ?',
      whereArgs: [expenseId],
      orderBy: 'createdAt ASC',
    );

    return List.generate(maps.length, (i) {
      return ExpenseAttachment.fromMap(maps[i]);
    });
  }

  Future<List<ExpenseAttachment>> getAllExpenseAttachments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expense_attachments',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return ExpenseAttachment.fromMap(maps[i]);
    });
  }

  Future<ExpenseAttachment?> getExpenseAttachment(String attachmentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expense_attachments',
      where: 'id = ?',
      whereArgs: [attachmentId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ExpenseAttachment.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateExpenseAttachment(ExpenseAttachment attachment) async {
    final db = await database;
    return await db.update(
      'expense_attachments',
      attachment.toMap(),
      where: 'id = ?',
      whereArgs: [attachment.id],
    );
  }

  Future<int> deleteExpenseAttachment(String attachmentId) async {
    final db = await database;
    return await db.delete(
      'expense_attachments',
      where: 'id = ?',
      whereArgs: [attachmentId],
    );
  }

  Future<int> deleteExpenseAttachments(String expenseId) async {
    final db = await database;
    return await db.delete(
      'expense_attachments',
      where: 'expenseId = ?',
      whereArgs: [expenseId],
    );
  }

  Future<int> getAttachmentCount(String expenseId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM expense_attachments WHERE expenseId = ?',
      [expenseId],
    );
    return result.first['count'] as int;
  }

  Future<int> getTotalAttachmentsSize(String expenseId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(fileSize) as totalSize FROM expense_attachments WHERE expenseId = ? AND fileSize IS NOT NULL',
      [expenseId],
    );
    return (result.first['totalSize'] as int?) ?? 0;
  }

}
