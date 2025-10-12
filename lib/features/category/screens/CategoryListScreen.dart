// screens/categories_screen.dart
import 'package:flutter/material.dart';
import 'package:expensemate/features/category/screens/Add/CategoryProvider.dart';
import 'CategoryCardWidget.dart';
import 'package:expensemate/features/category/screens/Add/EditCategoryDialog.dart';
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryProvider _categoryProvider = CategoryProvider(LocalCategoryRepository());

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await _categoryProvider.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _categoryProvider,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_categoryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${_categoryProvider.error}'),
                  ElevatedButton(
                    onPressed: _loadCategories,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return _buildCategoryList();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList() {
    return ListView(
      children: [
        _buildCategorySection('Predefined Categories', _categoryProvider.predefinedCategories),
        _buildCategorySection('Custom Categories', _categoryProvider.customCategories),
      ],
    );
  }

  Widget _buildCategorySection(String title, List<ExpenseCategory> categories) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...categories.map((category) => CategoryCard(
            category: category,
            onEdit: () => _showEditCategoryDialog(category),
            onDelete: category.isCustom ? () => _deleteCategory(category) : null,
          )).toList(),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        onSave: (name, color, icon) {
          _categoryProvider.addCustomCategory(
            name: name,
            color: color,
            icon: icon,
          );
        },
      ),
    );
  }

  void _showEditCategoryDialog(ExpenseCategory category) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        category: category,
        onSave: (name, color, icon) {
          final updatedCategory = category.copyWith(
            name: name,
            color: color,
            icon: icon,
          );
          _categoryProvider.updateCategory(updatedCategory);
        },
      ),
    );
  }

  void _deleteCategory(ExpenseCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _categoryProvider.deleteCategory(category.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}