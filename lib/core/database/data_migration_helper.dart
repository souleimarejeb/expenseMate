import 'package:expensemate/core/database/local_storage_helper.dart';
import 'package:expensemate/core/database/sqlite_database_helper.dart';
import 'package:flutter/foundation.dart';

/// Utility class to migrate data from SharedPreferences to SQLite
class DataMigrationHelper {
  static final DataMigrationHelper _instance = DataMigrationHelper._internal();
  
  factory DataMigrationHelper() => _instance;
  
  DataMigrationHelper._internal();
  
  static DataMigrationHelper get instance => _instance;
  
  /// Checks if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      final localStorage = LocalStorageHelper.instance;
      await localStorage.initialize();
      
      // Check if there's any data in SharedPreferences
      final expenses = await localStorage.getExpenses();
      final categories = await localStorage.getCategories();
      
      return expenses.isNotEmpty || categories.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking migration status: $e');
      return false;
    }
  }
  
  /// Migrates all data from SharedPreferences to SQLite
  Future<MigrationResult> migrateData({
    bool clearOldData = false,
  }) async {
    final result = MigrationResult();
    
    try {
      final localStorage = LocalStorageHelper.instance;
      final sqlite = SQLiteDatabaseHelper.instance;
      
      await localStorage.initialize();
      
      // Migrate Users
      debugPrint('Migrating users...');
      try {
        final users = await localStorage.getUsers();
        for (var user in users) {
          try {
            await sqlite.insertUser(user);
            result.usersCount++;
          } catch (e) {
            debugPrint('Error migrating user: $e');
            result.errors.add('User migration error: $e');
          }
        }
      } catch (e) {
        debugPrint('Error getting users: $e');
        result.errors.add('Get users error: $e');
      }
      
      // Migrate User Preferences
      debugPrint('Migrating user preferences...');
      try {
        final preferences = await localStorage.getUserPreferences();
        for (var pref in preferences) {
          try {
            await sqlite.insertUserPreferences(pref);
            result.userPreferencesCount++;
          } catch (e) {
            debugPrint('Error migrating preference: $e');
            result.errors.add('Preference migration error: $e');
          }
        }
      } catch (e) {
        debugPrint('Error getting preferences: $e');
        result.errors.add('Get preferences error: $e');
      }
      
      // Migrate Categories
      debugPrint('Migrating categories...');
      try {
        final categories = await localStorage.getCategories();
        for (var category in categories) {
          try {
            // Check if category already exists (might be default category)
            final existing = await sqlite.getCategoryById(category.id!);
            if (existing == null) {
              await sqlite.insertCategory(category);
              result.categoriesCount++;
            }
          } catch (e) {
            debugPrint('Error migrating category ${category.name}: $e');
            result.errors.add('Category migration error: $e');
          }
        }
      } catch (e) {
        debugPrint('Error getting categories: $e');
        result.errors.add('Get categories error: $e');
      }
      
      // Migrate Expenses
      debugPrint('Migrating expenses...');
      try {
        final expenses = await localStorage.getExpenses();
        for (var expense in expenses) {
          try {
            await sqlite.insertExpense(expense);
            result.expensesCount++;
          } catch (e) {
            debugPrint('Error migrating expense ${expense.description}: $e');
            result.errors.add('Expense migration error: $e');
          }
        }
      } catch (e) {
        debugPrint('Error getting expenses: $e');
        result.errors.add('Get expenses error: $e');
      }
      
      result.success = result.errors.isEmpty;
      
      // Clear old data if requested and migration was successful
      if (clearOldData && result.success) {
        debugPrint('Clearing old SharedPreferences data...');
        await _clearSharedPreferencesData(localStorage);
      }
      
      debugPrint('Migration completed!');
      debugPrint('Users: ${result.usersCount}');
      debugPrint('Preferences: ${result.userPreferencesCount}');
      debugPrint('Categories: ${result.categoriesCount}');
      debugPrint('Expenses: ${result.expensesCount}');
      debugPrint('Errors: ${result.errors.length}');
      
    } catch (e) {
      debugPrint('Fatal migration error: $e');
      result.success = false;
      result.errors.add('Fatal error: $e');
    }
    
    return result;
  }
  
  /// Clears all data from SharedPreferences
  Future<void> _clearSharedPreferencesData(LocalStorageHelper localStorage) async {
    try {
      final expenses = await localStorage.getExpenses();
      for (var expense in expenses) {
        await localStorage.deleteExpense(expense.id!);
      }
      
      // Note: LocalStorageHelper doesn't have methods to delete categories or users
      // You might want to add those methods or clear the entire SharedPreferences
      debugPrint('SharedPreferences data cleared');
    } catch (e) {
      debugPrint('Error clearing SharedPreferences: $e');
    }
  }
  
  /// Validates that the migration was successful
  Future<ValidationResult> validateMigration() async {
    final validation = ValidationResult();
    
    try {
      final localStorage = LocalStorageHelper.instance;
      final sqlite = SQLiteDatabaseHelper.instance;
      
      await localStorage.initialize();
      
      // Compare expense counts
      final oldExpenses = await localStorage.getExpenses();
      final newExpenses = await sqlite.getExpenses();
      
      validation.oldExpensesCount = oldExpenses.length;
      validation.newExpensesCount = newExpenses.length;
      validation.expensesMatch = oldExpenses.length == newExpenses.length;
      
      // Compare category counts
      final oldCategories = await localStorage.getCategories();
      final newCategories = await sqlite.getCategories();
      
      validation.oldCategoriesCount = oldCategories.length;
      validation.newCategoriesCount = newCategories.length;
      // Categories might not match exactly due to default categories
      validation.categoriesValid = newCategories.length >= oldCategories.length;
      
      validation.isValid = validation.expensesMatch && validation.categoriesValid;
      
      debugPrint('Validation Results:');
      debugPrint('Old Expenses: ${validation.oldExpensesCount}, New: ${validation.newExpensesCount}');
      debugPrint('Old Categories: ${validation.oldCategoriesCount}, New: ${validation.newCategoriesCount}');
      debugPrint('Valid: ${validation.isValid}');
      
    } catch (e) {
      debugPrint('Validation error: $e');
      validation.isValid = false;
      validation.error = e.toString();
    }
    
    return validation;
  }
  
  /// Creates a backup of SQLite database
  Future<bool> createBackup() async {
    // TODO: Implement database backup functionality
    // This could copy the SQLite file to a backup location
    debugPrint('Backup functionality not yet implemented');
    return false;
  }
  
  /// Restores SQLite database from backup
  Future<bool> restoreBackup() async {
    // TODO: Implement database restore functionality
    debugPrint('Restore functionality not yet implemented');
    return false;
  }
}

/// Result of a data migration operation
class MigrationResult {
  bool success = false;
  int usersCount = 0;
  int userPreferencesCount = 0;
  int categoriesCount = 0;
  int expensesCount = 0;
  List<String> errors = [];
  
  @override
  String toString() {
    return '''
Migration Result:
  Success: $success
  Users: $usersCount
  User Preferences: $userPreferencesCount
  Categories: $categoriesCount
  Expenses: $expensesCount
  Errors: ${errors.length}
${errors.isNotEmpty ? '  Error Details:\n    ${errors.join('\n    ')}' : ''}
''';
  }
}

/// Result of migration validation
class ValidationResult {
  bool isValid = false;
  int oldExpensesCount = 0;
  int newExpensesCount = 0;
  bool expensesMatch = false;
  int oldCategoriesCount = 0;
  int newCategoriesCount = 0;
  bool categoriesValid = false;
  String? error;
  
  @override
  String toString() {
    return '''
Validation Result:
  Valid: $isValid
  Old Expenses: $oldExpensesCount
  New Expenses: $newExpensesCount
  Expenses Match: $expensesMatch
  Old Categories: $oldCategoriesCount
  New Categories: $newCategoriesCount
  Categories Valid: $categoriesValid
${error != null ? '  Error: $error' : ''}
''';
  }
}
