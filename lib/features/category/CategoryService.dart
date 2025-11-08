import 'package:hive/hive.dart';
import 'category_model.dart';

class HiveService {
  static const String categoriesBox = 'categories';
  static Box<Category>? _categoriesBox;

  static Future<void> init() async {
    // Open the box first
    _categoriesBox = await Hive.openBox<Category>(categoriesBox);
    await _initializePredefinedCategories();
  }

  static Future<void> _initializePredefinedCategories() async {
    if (_categoriesBox == null) {
      throw Exception('Categories box is not initialized. Call init() first.');
    }

    if (_categoriesBox!.isEmpty) {
      final predefinedCategories = [
        Category(
          id: '1',
          name: 'Food',
          amount: 0.0,
          colorValue: Colors.orange.value,
          iconCode: Icons.fastfood.codePoint,
          isPredefined: true,
        ),
        Category(
          id: '2',
          name: 'Transport',
          amount: 0.0,
          colorValue: Colors.blue.value,
          iconCode: Icons.directions_car.codePoint,
          isPredefined: true,
        ),
        Category(
          id: '3',
          name: 'Entertainment',
          amount: 0.0,
          colorValue: Colors.purple.value,
          iconCode: Icons.movie.codePoint,
          isPredefined: true,
        ),
        Category(
          id: '4',
          name: 'Bills',
          amount: 0.0,
          colorValue: Colors.red.value,
          iconCode: Icons.receipt_long.codePoint,
          isPredefined: true,
        ),
        Category(
          id: '5',
          name: 'Shopping',
          amount: 0.0,
          colorValue: Colors.green.value,
          iconCode: Icons.shopping_bag.codePoint,
          isPredefined: true,
        ),
      ];

      for (final category in predefinedCategories) {
        await _categoriesBox!.put(category.id, category);
      }
    }
  }

  static Box<Category> get categoriesBox {
    if (_categoriesBox == null) {
      throw Exception('Categories box is not initialized. Call init() first.');
    }
    return _categoriesBox!;
  }

  static List<Category> getAllCategories() {
    return categoriesBox.values.toList();
  }

  static Future<void> addCategory(Category category) async {
    await categoriesBox.put(category.id, category);
  }

  static Future<void> updateCategory(Category category) async {
    await categoriesBox.put(category.id, category);
  }

  static Future<void> deleteCategory(String id) async {
    await categoriesBox.delete(id);
  }

  static Future<void> updateCategoryAmount(String id, double newAmount) async {
    final category = categoriesBox.get(id);
    if (category != null) {
      final updatedCategory = category.copyWith(amount: newAmount);
      await categoriesBox.put(id, updatedCategory);
    }
  }
}