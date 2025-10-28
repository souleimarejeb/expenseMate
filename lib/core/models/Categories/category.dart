// models/category.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double budget;
  final double spent;
  final int transactions;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.budget,
    required this.spent,
    required this.transactions,
  });
}