import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/models/expense_category.dart';
import '../../../core/services/expense_service.dart';

class CategoryProvider extends ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  
  bool _isLoading = false;
  String? _error;
  
  List<ExpenseCategory> _categories = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ExpenseCategory> get categories => List.unmodifiable(_categories);
  
  // Initialize and load categories
  Future<void> initialize() async {
    await loadCategories();
  }
  
  // Load all categories
  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();
    
    try {
      _categories = await _expenseService.getAllCategories();
      
      // If no categories exist, initialize default ones
      if (_categories.isEmpty) {
        await _expenseService.initializeDefaultCategories();
        _categories = await _expenseService.getAllCategories();
      }
      
      // Sort categories by name
      _categories.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      _setError('Failed to load categories: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Add new category
  Future<bool> addCategory(ExpenseCategory category) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _expenseService.createCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      _setError('Failed to add category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update category
  Future<bool> updateCategory(ExpenseCategory category) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _expenseService.updateCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      _setError('Failed to update category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete category
  Future<bool> deleteCategory(String categoryId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _expenseService.deleteCategory(categoryId);
      await loadCategories();
      return true;
    } catch (e) {
      _setError('Failed to delete category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get category by ID
  ExpenseCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get active categories
  List<ExpenseCategory> getActiveCategories() {
    return _categories.where((category) => category.isActive).toList();
  }
  
  // Get category count
  int getCategoryCount() {
    return _categories.length;
  }
  
  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
