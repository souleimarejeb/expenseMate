import 'package:flutter/material.dart';

class ExpenseCategory {
  final String? id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String? parentCategoryId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseCategory({
    this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.parentCategoryId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': String.fromCharCode(icon.codePoint), // Store as emoji character
      'color': color.value,
      'is_default': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    // Handle both old and new schema
    IconData iconData;
    if (map.containsKey('icon') && map['icon'] is String) {
      // New schema: icon as emoji string
      final String iconStr = map['icon'] ?? '📌';
      iconData = IconData(
        iconStr.isNotEmpty ? iconStr.codeUnitAt(0) : Icons.category.codePoint,
        fontFamily: 'MaterialIcons',
      );
    } else if (map.containsKey('iconCodePoint')) {
      // Old schema: icon as IconData
      iconData = IconData(
        map['iconCodePoint'] ?? Icons.category.codePoint,
        fontFamily: map['iconFontFamily'],
      );
    } else {
      iconData = Icons.category;
    }
    
    return ExpenseCategory(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: iconData,
      color: Color(map['color'] ?? map['colorValue'] ?? Colors.blue.value),
      parentCategoryId: map['parentCategoryId'],
      isActive: (map['is_default'] ?? map['isActive'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] ?? map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with method
  ExpenseCategory copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    String? parentCategoryId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ExpenseCategory{id: $id, name: $name, color: $color}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Default categories
  static List<ExpenseCategory> getDefaultCategories() {
    final now = DateTime.now();
    return [
      ExpenseCategory(
        id: 'food',
        name: 'Food & Dining',
        description: 'Restaurants, groceries, food delivery',
        icon: Icons.restaurant,
        color: Colors.orange,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: 'transport',
        name: 'Transportation',
        description: 'Gas, public transport, taxi, car maintenance',
        icon: Icons.directions_car,
        color: Colors.blue,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: 'shopping',
        name: 'Shopping',
        description: 'Clothes, electronics, general shopping',
        icon: Icons.shopping_bag,
        color: Colors.purple,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: 'entertainment',
        name: 'Entertainment',
        description: 'Movies, games, hobbies, subscriptions',
        icon: Icons.movie,
        color: Colors.pink,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: 'health',
        name: 'Health & Fitness',
        description: 'Medical expenses, gym, pharmacy',
        icon: Icons.local_hospital,
        color: Colors.green,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: 'bills',
        name: 'Bills & Utilities',
        description: 'Electricity, internet, phone, rent',
        icon: Icons.receipt_long,
        color: Colors.red,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: 'education',
        name: 'Education',
        description: 'Books, courses, school fees',
        icon: Icons.school,
        color: Colors.indigo,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: 'travel',
        name: 'Travel',
        description: 'Vacation, business trips, accommodation',
        icon: Icons.flight,
        color: Colors.teal,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}