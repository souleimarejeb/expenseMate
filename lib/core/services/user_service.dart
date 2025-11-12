import 'package:uuid/uuid.dart';
import '../database/databaseHelper.dart';
import '../models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  // CRUD Operations for Users

  // Create a new user
  Future<String> createUser(User user) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    
    final userWithId = user.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );
    
    await _dbHelper.insert('users', userWithId.toMap());
    return id;
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    final maps = await _dbHelper.query('users', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // Get user by ID
  Future<User?> getUserById(String id) async {
    final maps = await _dbHelper.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    final maps = await _dbHelper.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  // Update user
  Future<bool> updateUser(User user) async {
    try {
      if (user.id == null) {
        print('ERROR: Cannot update user - ID is null');
        return false;
      }
      
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      final userMap = updatedUser.toMap();
      
      // Remove id from the map as it shouldn't be updated
      userMap.remove('id');
      
      print('DEBUG - Updating user:');
      print('  User ID: ${user.id}');
      print('  User Map: $userMap');
      
      final count = await _dbHelper.update(
        'users',
        userMap,
        where: 'id = ?',
        whereArgs: [user.id],
      );
      
      print('  Rows updated: $count');
      return count > 0;
    } catch (e, stackTrace) {
      print('ERROR updating user: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String id) async {
    final count = await _dbHelper.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // Search users by name or email
  Future<List<User>> searchUsers(String query) async {
    final maps = await _dbHelper.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    final maps = await _dbHelper.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  // Get user count
  Future<int> getUserCount() async {
    final maps = await _dbHelper.query('users');
    return maps.length;
  }

  // Update user profile image
  Future<bool> updateProfileImage(String userId, String imagePath) async {
    final count = await _dbHelper.update(
      'users',
      {
        'profile_image_path': imagePath,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }

  // Update user preferences
  Future<bool> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    final count = await _dbHelper.update(
      'users',
      {
        'preferences': User(
          name: '',
          email: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          preferences: preferences,
        ).toMap()['preferences'],
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }

  // Get users with pagination
  Future<List<User>> getUsersWithPagination({
    int limit = 10,
    int offset = 0,
  }) async {
    final maps = await _dbHelper.query(
      'users',
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }
}
