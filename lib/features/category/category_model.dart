import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'category_model.g.dart'; // Make sure this matches your filename

@HiveType(typeId: 0)
class Category {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final int colorValue;
  
  @HiveField(4)
  final int iconCode;
  
  @HiveField(5)
  final bool isPredefined;

  Category({
    required this.id,
    required this.name,
    required this.amount,
    required this.colorValue,
    required this.iconCode,
    this.isPredefined = false,
  });

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  Category copyWith({
    String? id,
    String? name,
    double? amount,
    int? colorValue,
    int? iconCode,
    bool? isPredefined,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      colorValue: colorValue ?? this.colorValue,
      iconCode: iconCode ?? this.iconCode,
      isPredefined: isPredefined ?? this.isPredefined,
    );
  }
}