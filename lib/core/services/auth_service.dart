import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expensemate/core/repositories/user_repository.dart';
import 'package:expensemate/core/models/user.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  static const _keySignedIn = 'auth_signed_in';
  static const _keyUserId = 'auth_user_id';
  final ValueNotifier<bool> isSignedIn = ValueNotifier<bool>(false);
  final ValueNotifier<int?> currentUserId = ValueNotifier<int?>(null);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isSignedIn.value = prefs.getBool(_keySignedIn) ?? false;
    currentUserId.value = prefs.getInt(_keyUserId);
  }

  Future<bool> signIn({required String email, required String password}) async {
    final repo = UserRepository();
    final userId = await repo.verifyCredentials(email: email, password: password);
    if (userId == null) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySignedIn, true);
    await prefs.setInt(_keyUserId, userId);
    currentUserId.value = userId;
    isSignedIn.value = true;
    return true;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySignedIn, false);
    await prefs.remove(_keyUserId);
    currentUserId.value = null;
    isSignedIn.value = false;
  }

  Future<bool> signUp({required String name, required String email, required String password}) async {
    final repo = UserRepository();
    try {
      final id = await repo.createUser(name: name, email: email, password: password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySignedIn, true);
      await prefs.setInt(_keyUserId, id);
      currentUserId.value = id;
      isSignedIn.value = true;
      return true;
    } catch (e) {
      // likely UNIQUE constraint failed on email
      return false;
    }
  }

  Future<AppUser?> getCurrentUser() async {
    final id = currentUserId.value;
    if (id == null) return null;
    final repo = UserRepository();
    return await repo.getUserById(id);
  }

  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    final id = currentUserId.value;
    if (id == null) return false;
    final repo = UserRepository();
    // verify current password
    final user = await repo.getUserById(id);
    if (user == null) return false;
    final ok = await repo.verifyCredentials(email: user.email, password: currentPassword) != null;
    if (!ok) return false;
    await repo.updatePassword(userId: id, newPassword: newPassword);
    return true;
  }

  Future<bool> updateProfile({required String name, required String email, String? avatarUrl}) async {
    final id = currentUserId.value;
    if (id == null) return false;
    final repo = UserRepository();
    try {
      await repo.updateProfile(userId: id, name: name, email: email, avatarUrl: avatarUrl);
      return true;
    } catch (e) {
      // likely UNIQUE constraint failed on email
      return false;
    }
  }
}
