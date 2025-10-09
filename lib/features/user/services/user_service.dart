// user_service.dart
import 'package:sqflite/sqflite.dart';
import '../../../core/database/databaseHelper.dart';
import '../models/user_model.dart';
import '../models/user_preferences_model.dart';

class UserService {
  static const String tableName = 'users';
  static const String preferencesTableName = 'user_preferences';

  // Get database instance from DatabaseHelper
  static Future<Database> get database async {
    return await DatabaseHelper.instance.database;
  }

  // CRUD Operations for User

  // Create user
  static Future<int> createUser(UserModel user) async {
    final db = await database;
    try {
      final userId = await db.insert(tableName, user.toMap());
      
      // Create default preferences for the new user
      final defaultPreferences = UserPreferencesModel();
      await createUserPreferences(userId, defaultPreferences);
      
      return userId;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Read user by ID
  static Future<UserModel?> getUserById(int id) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ? AND isActive = ?',
        whereArgs: [id, 1],
      );

      if (maps.isNotEmpty) {
        return UserModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Read user by email
  static Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'email = ? AND isActive = ?',
        whereArgs: [email, 1],
      );

      if (maps.isNotEmpty) {
        return UserModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Get all users
  static Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'isActive = ?',
        whereArgs: [1],
        orderBy: 'firstName ASC',
      );

      return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  // Update user
  static Future<int> updateUser(UserModel user) async {
    final db = await database;
    try {
      return await db.update(
        tableName,
        user.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Soft delete user (set isActive to false)
  static Future<int> deleteUser(int id) async {
    final db = await database;
    try {
      return await db.update(
        tableName,
        {
          'isActive': 0,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Hard delete user (permanent)
  static Future<int> permanentDeleteUser(int id) async {
    final db = await database;
    try {
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to permanently delete user: $e');
    }
  }

  // CRUD Operations for User Preferences

  // Create user preferences
  static Future<int> createUserPreferences(int userId, UserPreferencesModel preferences) async {
    final db = await database;
    try {
      final preferencesMap = preferences.toMap();
      preferencesMap['userId'] = userId;
      return await db.insert(preferencesTableName, preferencesMap);
    } catch (e) {
      throw Exception('Failed to create user preferences: $e');
    }
  }

  // Get user preferences
  static Future<UserPreferencesModel?> getUserPreferences(int userId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        preferencesTableName,
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (maps.isNotEmpty) {
        return UserPreferencesModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user preferences: $e');
    }
  }

  // Update user preferences
  static Future<int> updateUserPreferences(int userId, UserPreferencesModel preferences) async {
    final db = await database;
    try {
      final preferencesMap = preferences.toMap();
      return await db.update(
        preferencesTableName,
        preferencesMap,
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  // Search users
  static Future<List<UserModel>> searchUsers(String query) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '''
          (firstName LIKE ? OR lastName LIKE ? OR email LIKE ?) 
          AND isActive = ?
        ''',
        whereArgs: ['%$query%', '%$query%', '%$query%', 1],
        orderBy: 'firstName ASC',
      );

      return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Get user statistics
  static Future<Map<String, dynamic>> getUserStatistics(int userId) async {
    try {
      // This is a placeholder for user statistics
      // You can extend this based on your expense and budget data
      final user = await getUserById(userId);
      if (user == null) return {};

      return {
        'totalExpenses': 0.0, // Calculate from expenses table
        'totalBudgets': 0.0,  // Calculate from budgets table
        'accountAge': DateTime.now().difference(user.createdAt).inDays,
        'lastUpdated': user.updatedAt,
      };
    } catch (e) {
      throw Exception('Failed to get user statistics: $e');
    }
  }
}