// user_preferences_provider.dart
import 'package:flutter/material.dart';
import '../models/user_preferences_model.dart';
import '../services/user_service.dart';

class UserPreferencesProvider with ChangeNotifier {
  UserPreferencesModel _preferences = UserPreferencesModel();
  bool _isLoading = false;
  String? _error;

  // Getters
  UserPreferencesModel get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Theme getters
  bool get isDarkMode => _preferences.theme == 'dark';
  bool get isSystemTheme => _preferences.theme == 'system';
  ThemeMode get themeMode {
    switch (_preferences.theme) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

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

  // Load user preferences
  Future<void> loadPreferences(int userId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userPreferences = await UserService.getUserPreferences(userId);
      if (userPreferences != null) {
        _preferences = userPreferences;
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('Error loading preferences: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Update preferences
  Future<bool> updatePreferences(int userId, UserPreferencesModel newPreferences) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await UserService.updateUserPreferences(userId, newPreferences);
      _preferences = newPreferences;
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error updating preferences: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Theme management
  Future<void> setTheme(int userId, String theme) async {
    final updatedPreferences = _preferences.copyWith(theme: theme);
    await updatePreferences(userId, updatedPreferences);
  }

  Future<void> toggleTheme(int userId) async {
    String newTheme;
    switch (_preferences.theme) {
      case 'light':
        newTheme = 'dark';
        break;
      case 'dark':
        newTheme = 'system';
        break;
      default:
        newTheme = 'light';
        break;
    }
    await setTheme(userId, newTheme);
  }

  // Language management
  Future<void> setLanguage(int userId, String language) async {
    final updatedPreferences = _preferences.copyWith(language: language);
    await updatePreferences(userId, updatedPreferences);
  }

  // Currency management
  Future<void> setCurrency(int userId, String currency) async {
    final updatedPreferences = _preferences.copyWith(currency: currency);
    await updatePreferences(userId, updatedPreferences);
  }

  // Notification settings
  Future<void> toggleNotifications(int userId) async {
    final updatedPreferences = _preferences.copyWith(
      enableNotifications: !_preferences.enableNotifications,
    );
    await updatePreferences(userId, updatedPreferences);
  }

  Future<void> setNotifications(int userId, bool enable) async {
    final updatedPreferences = _preferences.copyWith(enableNotifications: enable);
    await updatePreferences(userId, updatedPreferences);
  }

  // Biometric settings
  Future<void> toggleBiometric(int userId) async {
    final updatedPreferences = _preferences.copyWith(
      enableBiometric: !_preferences.enableBiometric,
    );
    await updatePreferences(userId, updatedPreferences);
  }

  Future<void> setBiometric(int userId, bool enable) async {
    final updatedPreferences = _preferences.copyWith(enableBiometric: enable);
    await updatePreferences(userId, updatedPreferences);
  }

  // Backup settings
  Future<void> toggleBackup(int userId) async {
    final updatedPreferences = _preferences.copyWith(
      enableBackup: !_preferences.enableBackup,
    );
    await updatePreferences(userId, updatedPreferences);
  }

  Future<void> setBackup(int userId, bool enable) async {
    final updatedPreferences = _preferences.copyWith(enableBackup: enable);
    await updatePreferences(userId, updatedPreferences);
  }

  // Analytics settings
  Future<void> toggleAnalytics(int userId) async {
    final updatedPreferences = _preferences.copyWith(
      enableAnalytics: !_preferences.enableAnalytics,
    );
    await updatePreferences(userId, updatedPreferences);
  }

  Future<void> setAnalytics(int userId, bool enable) async {
    final updatedPreferences = _preferences.copyWith(enableAnalytics: enable);
    await updatePreferences(userId, updatedPreferences);
  }

  // Date format settings
  Future<void> setDateFormat(int userId, String dateFormat) async {
    final updatedPreferences = _preferences.copyWith(dateFormat: dateFormat);
    await updatePreferences(userId, updatedPreferences);
  }

  // Time format settings
  Future<void> setTimeFormat(int userId, String timeFormat) async {
    final updatedPreferences = _preferences.copyWith(timeFormat: timeFormat);
    await updatePreferences(userId, updatedPreferences);
  }

  // Budget alert threshold
  Future<void> setBudgetAlertThreshold(int userId, double threshold) async {
    final updatedPreferences = _preferences.copyWith(budgetAlertThreshold: threshold);
    await updatePreferences(userId, updatedPreferences);
  }

  // Category visibility
  Future<void> setCategoryVisibility(int userId, String category, bool visible) async {
    final updatedVisibility = Map<String, bool>.from(_preferences.categoryVisibility);
    updatedVisibility[category] = visible;
    
    final updatedPreferences = _preferences.copyWith(categoryVisibility: updatedVisibility);
    await updatePreferences(userId, updatedPreferences);
  }

  // Favorite categories
  Future<void> addFavoriteCategory(int userId, String category) async {
    if (!_preferences.favoriteCategories.contains(category)) {
      final updatedFavorites = List<String>.from(_preferences.favoriteCategories);
      updatedFavorites.add(category);
      
      final updatedPreferences = _preferences.copyWith(favoriteCategories: updatedFavorites);
      await updatePreferences(userId, updatedPreferences);
    }
  }

  Future<void> removeFavoriteCategory(int userId, String category) async {
    if (_preferences.favoriteCategories.contains(category)) {
      final updatedFavorites = List<String>.from(_preferences.favoriteCategories);
      updatedFavorites.remove(category);
      
      final updatedPreferences = _preferences.copyWith(favoriteCategories: updatedFavorites);
      await updatePreferences(userId, updatedPreferences);
    }
  }

  // Dashboard layout
  Future<void> updateDashboardLayout(int userId, Map<String, dynamic> layout) async {
    final updatedPreferences = _preferences.copyWith(dashboardLayout: layout);
    await updatePreferences(userId, updatedPreferences);
  }

  // Reset preferences to default
  Future<void> resetPreferences(int userId) async {
    final defaultPreferences = UserPreferencesModel();
    await updatePreferences(userId, defaultPreferences);
  }

  // Get localized date format
  String getFormattedDate(DateTime date) {
    switch (_preferences.dateFormat) {
      case 'dd/MM/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'MM/dd/yyyy':
      default:
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  // Get localized time format
  String getFormattedTime(DateTime time) {
    if (_preferences.timeFormat == '24h') {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  // Check if category is visible
  bool isCategoryVisible(String category) {
    return _preferences.categoryVisibility[category] ?? true;
  }

  // Check if category is favorite
  bool isCategoryFavorite(String category) {
    return _preferences.favoriteCategories.contains(category);
  }
}