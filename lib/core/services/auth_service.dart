import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import 'user_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final UserService _userService = UserService();
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      // Check if email already exists
      final existingUser = await _userService.getUserByEmail(email);
      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Email already registered',
        };
      }

      // Create new user with hashed password
      final hashedPwd = _hashPassword(password);
      print('DEBUG - Registration:');
      print('  Email: $email');
      print('  Password hash: $hashedPwd');
      
      final user = User(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        preferences: {
          'password': hashedPwd,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userId = await _userService.createUser(user);
      final createdUser = await _userService.getUserById(userId);
      
      print('  Created user preferences: ${createdUser?.preferences}');
      
      _currentUser = createdUser;

      return {
        'success': true,
        'message': 'Registration successful',
        'user': createdUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _userService.getUserByEmail(email);
      
      if (user == null) {
        return {
          'success': false,
          'message': 'User not found',
        };
      }

      // Check password
      final storedPassword = user.preferences?['password'];
      final hashedPassword = _hashPassword(password);

      // Debug logging
      print('DEBUG - Login attempt:');
      print('  Email: $email');
      print('  User preferences: ${user.preferences}');
      print('  Stored password hash: $storedPassword');
      print('  Computed password hash: $hashedPassword');
      print('  Match: ${storedPassword == hashedPassword}');

      if (storedPassword == null) {
        return {
          'success': false,
          'message': 'Account has no password set. Please contact support.',
        };
      }

      if (storedPassword != hashedPassword) {
        return {
          'success': false,
          'message': 'Invalid password',
        };
      }

      _currentUser = user;

      return {
        'success': true,
        'message': 'Login successful',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
  }

  // Check if user is logged in
  Future<bool> checkAuthStatus() async {
    return _currentUser != null;
  }

  // Update current user
  void updateCurrentUser(User user) {
    _currentUser = user;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  // Update profile
  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      if (_currentUser == null) {
        return false;
      }

      // Check if email is already taken by another user
      final existingUser = await _userService.getUserByEmail(email);
      if (existingUser != null && existingUser.id != _currentUser!.id) {
        return false; // Email already in use by another user
      }

      // Update user with new information
      final updatedUser = _currentUser!.copyWith(
        name: name,
        email: email,
        updatedAt: DateTime.now(),
      );

      final success = await _userService.updateUser(updatedUser);
      
      if (success) {
        // Reload the user from database to ensure we have the latest data
        final reloadedUser = await _userService.getUserById(_currentUser!.id!);
        if (reloadedUser != null) {
          _currentUser = reloadedUser;
        } else {
          _currentUser = updatedUser;
        }
      }

      return success;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = await _userService.getUserById(userId);
      
      if (user == null) {
        return {
          'success': false,
          'message': 'User not found',
        };
      }

      // Verify old password
      final storedPassword = user.preferences?['password'];
      final hashedOldPassword = _hashPassword(oldPassword);

      if (storedPassword != hashedOldPassword) {
        return {
          'success': false,
          'message': 'Invalid old password',
        };
      }

      // Update with new password
      final updatedPreferences = Map<String, dynamic>.from(user.preferences ?? {});
      updatedPreferences['password'] = _hashPassword(newPassword);

      await _userService.updateUserPreferences(userId, updatedPreferences);

      return {
        'success': true,
        'message': 'Password changed successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to change password: ${e.toString()}',
      };
    }
  }

  // Reset password (for future implementation with email)
  Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      final user = await _userService.getUserByEmail(email);
      
      if (user == null) {
        return {
          'success': false,
          'message': 'User not found',
        };
      }

      // In a real app, you would send an email here
      // For now, just return success
      return {
        'success': true,
        'message': 'Password reset link sent to your email',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to reset password: ${e.toString()}',
      };
    }
  }
}
