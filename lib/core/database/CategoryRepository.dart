// repositories/category_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:expensemate/core/models/Categories/category.dart';
abstract class CategoryRepository {
  Future<List<ExpenseCategory>> getPredefinedCategories();
  Future<List<ExpenseCategory>> getCustomCategories();
  Future<void> addCustomCategory(ExpenseCategory category);
  Future<void> updateCategory(ExpenseCategory category);
  Future<void> deleteCategory(String categoryId);
  Future<void> reorderCategories(List<String> categoryIds);
}

class LocalCategoryRepository implements CategoryRepository {
  static const String _predefinedCategoriesPath = 'assets/data/predefined_categories.json';
  static const String _storageKey = 'custom_categories';
  static const String _orderKey = 'categories_order';

  @override
  Future<List<ExpenseCategory>> getPredefinedCategories() async {
    try {
      final String data = await rootBundle.loadString(_predefinedCategoriesPath);
      final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
      
      return jsonList.map((json) => ExpenseCategory.fromMap(json)).toList();
    } catch (e) {
      // Fallback to default categories if asset loading fails
      return _getDefaultCategories();
    }
  }

  @override
  Future<List<ExpenseCategory>> getCustomCategories() async {
    // Implementation for local storage (shared_preferences or hive)
    // This is a placeholder - implement based on your storage solution
    final storage = await _getStorage();
    final List<String>? customCategoriesJson = storage.getStringList(_storageKey);
    
    if (customCategoriesJson == null) return [];
    
    return customCategoriesJson
        .map((json) => ExpenseCategory.fromMap(jsonDecode(json)))
        .toList();
  }

  @override
  Future<void> addCustomCategory(ExpenseCategory category) async {
    final storage = await _getStorage();
    final List<ExpenseCategory> existingCategories = await getCustomCategories();
    
    final updatedCategories = [...existingCategories, category];
    final categoriesJson = updatedCategories.map((cat) => jsonEncode(cat.toMap())).toList();
    
    await storage.setStringList(_storageKey, categoriesJson);
  }

  @override
  Future<void> updateCategory(ExpenseCategory category) async {
    final storage = await _getStorage();
    final List<ExpenseCategory> customCategories = await getCustomCategories();
    
    final updatedCategories = customCategories.map((cat) => 
        cat.id == category.id ? category : cat).toList();
        
    final categoriesJson = updatedCategories.map((cat) => jsonEncode(cat.toMap())).toList();
    await storage.setStringList(_storageKey, categoriesJson);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final storage = await _getStorage();
    final List<ExpenseCategory> customCategories = await getCustomCategories();
    
    final updatedCategories = customCategories.where((cat) => cat.id != categoryId).toList();
    final categoriesJson = updatedCategories.map((cat) => jsonEncode(cat.toMap())).toList();
    
    await storage.setStringList(_storageKey, categoriesJson);
  }

  @override
  Future<void> reorderCategories(List<String> categoryIds) async {
    final storage = await _getStorage();
    await storage.setStringList(_orderKey, categoryIds);
  }

  // Helper methods
  List<ExpenseCategory> _getDefaultCategories() {
    return [
      ExpenseCategory(
        id: '1',
        name: 'Food',
        color: Colors.orange,
        icon: '🍕',
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      ExpenseCategory(
        id: '2',
        name: 'Transportation',
        color: Colors.blue,
        icon: '🚗',
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      ExpenseCategory(
        id: '3',
        name: 'Entertainment',
        color: Colors.purple,
        icon: '🎬',
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      ExpenseCategory(
        id: '4',
        name: 'Utilities',
        color: Colors.green,
        icon: '💡',
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      ExpenseCategory(
        id: '5',
        name: 'Rent',
        color: Colors.red,
        icon: '🏠',
        isCustom: false,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<dynamic> _getStorage() async {
    // Replace with your preferred storage solution
    // Example: SharedPreferences.getInstance()
    return await MethodChannel('storage').invokeMethod('getStorage');
  }
}