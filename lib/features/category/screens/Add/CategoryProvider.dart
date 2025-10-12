// providers/category_provider.dart
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:expensemate/core/models/Categories/category.dart';


import 'package:expensemate/core/database/CategoryRepository.dart';
class CategoryProvider with ChangeNotifier {
  final CategoryRepository _repository;
  
  List<ExpenseCategory> _predefinedCategories = [];
  List<ExpenseCategory> _customCategories = [];
  bool _isLoading = false;
  String? _error;

  CategoryProvider(this._repository);

  List<ExpenseCategory> get predefinedCategories => _predefinedCategories;
  List<ExpenseCategory> get customCategories => _customCategories;
  List<ExpenseCategory> get allCategories => [..._predefinedCategories, ..._customCategories];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _setLoading(true);
    _error = null;
    
    try {
      _predefinedCategories = await _repository.getPredefinedCategories();
      _customCategories = await _repository.getCustomCategories();
    } catch (e) {
      _error = 'Failed to load categories: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCustomCategory({
    required String name,
    required Color color,
    required String icon,
  }) async {
    _setLoading(true);
    
    try {
      final newCategory = ExpenseCategory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        color: color,
        icon: icon,
        isCustom: true,
        createdAt: DateTime.now(),
      );
      
      await _repository.addCustomCategory(newCategory);
      _customCategories.add(newCategory);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCategory(ExpenseCategory category) async {
    _setLoading(true);
    
    try {
      await _repository.updateCategory(category);
      
      final index = _customCategories.indexWhere((cat) => cat.id == category.id);
      if (index != -1) {
        _customCategories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    _setLoading(true);
    
    try {
      await _repository.deleteCategory(categoryId);
      _customCategories.removeWhere((cat) => cat.id == categoryId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete category: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  ExpenseCategory? getCategoryById(String id) {
    return allCategories.firstWhere((cat) => cat.id == id);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}