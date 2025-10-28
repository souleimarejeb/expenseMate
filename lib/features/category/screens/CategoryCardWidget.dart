// widgets/category_card.dart
import 'package:flutter/material.dart';
import '';

class CategoryCard extends StatelessWidget {
  final ExpenseCategory category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              category.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(category.name),
        subtitle: Text(category.isCustom ? 'Custom' : 'Predefined'),
        trailing: category.isCustom ? _buildCustomCategoryActions() : null,
        onTap: onEdit,
      ),
    );
  }

  Widget _buildCustomCategoryActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
          onPressed: onDelete,
        ),
      ],
    );
  }
}