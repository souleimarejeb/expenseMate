// user_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Create a new user
  Future<bool> createUser(UserModel user) async {
    print('🔧 UserProvider.createUser called for: ${user.email}'); // Debug log
    
    try {
      _setLoading(true);
      _setError(null);

      print('📧 Checking if email exists: ${user.email}'); // Debug log
      
      // Check if email already exists
      final existingUser = await UserService.getUserByEmail(user.email);
      if (existingUser != null) {
        print('⚠️ Email already exists, logging in instead'); // Debug log
        _currentUser = existingUser;
        _setLoading(false);
        return true; // Return success and login existing user
      }

      print('➕ Creating new user...'); // Debug log
      
      final userId = await UserService.createUser(user);
      print('🆔 Created user with ID: $userId'); // Debug log
      
      final createdUser = await UserService.getUserById(userId);
      print('👤 Retrieved created user: ${createdUser?.email}'); // Debug log
      
      if (createdUser != null) {
        _currentUser = createdUser;
        await loadAllUsers(); // Refresh the users list
        _setLoading(false);
        print('✅ User creation successful!'); // Debug log
        return true;
      }
      
      print('❌ Failed to retrieve created user'); // Debug log
      _setError('Failed to create user');
      return false;
    } catch (e) {
      print('💥 Error in createUser: ${e.toString()}'); // Debug log
      _setError('Error creating user: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(int id) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final user = await UserService.getUserById(id);
      _setLoading(false);
      return user;
    } catch (e) {
      _setError('Error fetching user: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  // Login user (set as current user)
  Future<bool> loginUser(String email) async {
    print('🔑 UserProvider.loginUser called for: $email'); // Debug log
    
    try {
      _setLoading(true);
      _setError(null);
      
      print('🔍 Looking up user by email...'); // Debug log
      
      final user = await UserService.getUserByEmail(email);
      if (user != null) {
        print('👤 Found user: ${user.fullName}'); // Debug log
        _currentUser = user;
        _setLoading(false);
        print('✅ Login successful!'); // Debug log
        return true;
      }
      
      print('❌ User not found'); // Debug log
      _setError('User not found');
      return false;
    } catch (e) {
      print('💥 Error in loginUser: ${e.toString()}'); // Debug log
      _setError('Error logging in: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  void logoutUser() {
    _currentUser = null;
    notifyListeners();
  }

  // Update current user
  Future<bool> updateCurrentUser(UserModel updatedUser) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await UserService.updateUser(updatedUser);
      _currentUser = updatedUser;
      
      // Update the user in the users list
      final index = _users.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error updating user: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    String? occupation,
    DateTime? dateOfBirth,
    double? monthlyIncome,
    String? avatarPath,
  }) async {
    if (_currentUser == null) {
      _setError('No user logged in');
      return false;
    }

    final updatedUser = _currentUser!.copyWith(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      bio: bio,
      occupation: occupation,
      dateOfBirth: dateOfBirth,
      monthlyIncome: monthlyIncome,
      avatarPath: avatarPath,
    );

    return await updateCurrentUser(updatedUser);
  }

  // Load all users
  Future<void> loadAllUsers() async {
    try {
      _setLoading(true);
      _setError(null);
      
      _users = await UserService.getAllUsers();
      _setLoading(false);
    } catch (e) {
      _setError('Error loading users: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      _setError(null);
      return await UserService.searchUsers(query);
    } catch (e) {
      _setError('Error searching users: ${e.toString()}');
      return [];
    }
  }

  // Delete user
  Future<bool> deleteUser(int userId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await UserService.deleteUser(userId);
      
      // Remove from local list
      _users.removeWhere((user) => user.id == userId);
      
      // If it's the current user, logout
      if (_currentUser?.id == userId) {
        _currentUser = null;
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error deleting user: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(int userId) async {
    try {
      return await UserService.getUserStatistics(userId);
    } catch (e) {
      print('Error getting user statistics: ${e.toString()}');
      return {
        'totalExpenses': 0.0,
        'monthlyBudget': 0.0,
        'totalIncome': _currentUser?.monthlyIncome ?? 0.0,
        'expenseCount': 0,
      };
    }
  }

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate user data
  String? validateUserData({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
  }) {
    if (firstName.trim().isEmpty) {
      return 'First name is required';
    }
    if (lastName.trim().isEmpty) {
      return 'Last name is required';
    }
    if (email.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email';
    }
    if (phone != null && phone.isNotEmpty && phone.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Get current user's full name
  String get currentUserFullName {
    if (_currentUser == null) return 'Guest';
    return _currentUser!.fullName;
  }

  // Get current user's initials
  String get currentUserInitials {
    if (_currentUser == null) return 'G';
    return _currentUser!.initials;
  }

  // Check if user has avatar
  bool get currentUserHasAvatar {
    return _currentUser?.avatarPath != null && _currentUser!.avatarPath!.isNotEmpty;
  }
}