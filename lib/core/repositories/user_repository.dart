import 'package:sqflite/sqflite.dart';
import 'package:expensemate/core/database/databaseHelper.dart';
import 'package:expensemate/core/models/user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserRepository {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  String _hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  Future<int> createUser({
    required String name,
    required String email,
    required String password,
    String? avatarUrl,
  }) async {
    final db = await _db;
    final data = {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password_hash': _hash(password),
      'avatar_url': avatarUrl,
    };
    return await db.insert('users', data, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await _db;
    final res = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (res.isEmpty) return null;
    final row = res.first;
    return AppUser(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
      avatarUrl: row['avatar_url'] as String?,
    );
  }

  Future<AppUser?> getUserById(int id) async {
    final db = await _db;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (res.isEmpty) return null;
    final row = res.first;
    return AppUser(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
      avatarUrl: row['avatar_url'] as String?,
    );
  }

  Future<int?> verifyCredentials({required String email, required String password}) async {
    final db = await _db;
    final res = await db.query(
      'users',
      columns: ['id', 'password_hash'],
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (res.isEmpty) return null;
    final row = res.first;
    final saved = row['password_hash'] as String;
    if (saved == _hash(password)) {
      return row['id'] as int;
    }
    return null;
  }

  Future<void> updatePassword({required int userId, required String newPassword}) async {
    final db = await _db;
    await db.update(
      'users',
      {'password_hash': _hash(newPassword)},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateProfile({required int userId, required String name, required String email, String? avatarUrl}) async {
    final db = await _db;
    await db.update(
      'users',
      {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'avatar_url': avatarUrl,
      },
      where: 'id = ?',
      whereArgs: [userId],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}
