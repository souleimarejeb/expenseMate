import 'package:flutter/foundation.dart';
import '../../../core/models/user.dart';
import '../../../core/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  
  List<User> _users = [];
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all users
  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _userService.getAllUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new user
  Future<String?> createUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if email already exists
      final emailExists = await _userService.emailExists(user.email);
      if (emailExists) {
        _error = 'Email already exists';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final userId = await _userService.createUser(user);
      await loadUsers();
      _isLoading = false;
      notifyListeners();
      return userId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update a user
  Future<bool> updateUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _userService.updateUser(user);
      if (success) {
        await loadUsers();
        // Reload the user from database to get the latest data
        if (_currentUser?.id == user.id) {
          final reloadedUser = await _userService.getUserById(user.id!);
          if (reloadedUser != null) {
            _currentUser = reloadedUser;
          }
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a user
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _userService.deleteUser(userId);
      if (success) {
        await loadUsers();
        if (_currentUser?.id == userId) {
          _currentUser = null;
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Search users
  Future<List<User>> searchUsers(String query) async {
    try {
      return await _userService.searchUsers(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      return await _userService.getUserById(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Set current user
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Clear current user
  void clearCurrentUser() {
    _currentUser = null;
    notifyListeners();
  }

  // Update profile image
  Future<bool> updateProfileImage(String userId, String imagePath) async {
    try {
      final success = await _userService.updateProfileImage(userId, imagePath);
      if (success) {
        await loadUsers();
        if (_currentUser?.id == userId) {
          final updatedUser = await _userService.getUserById(userId);
          if (updatedUser != null) {
            _currentUser = updatedUser;
          }
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update user preferences
  Future<bool> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      final success = await _userService.updateUserPreferences(userId, preferences);
      if (success) {
        await loadUsers();
        if (_currentUser?.id == userId) {
          final updatedUser = await _userService.getUserById(userId);
          if (updatedUser != null) {
            _currentUser = updatedUser;
          }
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get user count
  Future<int> getUserCount() async {
    try {
      return await _userService.getUserCount();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
