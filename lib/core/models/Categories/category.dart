// models/category_model.dart
import 'package:flutter/material.dart';

@immutable
class ExpenseCategory {
  final String id;
  final String name;
  final Color color;
  final String icon;
  final bool isCustom;
  final DateTime createdAt;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.isCustom = false,
    required this.createdAt,
  });

  ExpenseCategory copyWith({
    String? id,
    String? name,
    Color? color,
    String? icon,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon,
      'isCustom': isCustom,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      icon: map['icon'] as String,
      isCustom: map['isCustom'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ExpenseCategory(id: $id, name: $name, color: $color, icon: $icon, isCustom: $isCustom)';
  }
}