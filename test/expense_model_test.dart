import 'package:flutter_test/flutter_test.dart';
import 'package:expensemate/core/models/expense.dart';
import 'package:expensemate/core/models/expense_category.dart';
import 'package:flutter/material.dart';

void main() {
  group('Expense Model Tests', () {
    test('Create expense object', () {
      final expense = Expense(
        title: 'Test Expense',
        description: 'Test description',
        amount: 100.0,
        categoryId: 'test-category',
        date: DateTime(2023, 12, 1),
        createdAt: DateTime(2023, 12, 1),
        updatedAt: DateTime(2023, 12, 1),
      );

      expect(expense.title, 'Test Expense');
      expect(expense.description, 'Test description');
      expect(expense.amount, 100.0);
      expect(expense.categoryId, 'test-category');
    });

    test('Expense to/from Map conversion', () {
      final originalExpense = Expense(
        id: 'test-id',
        title: 'Test Expense',
        description: 'Test description',
        amount: 100.0,
        categoryId: 'test-category',
        date: DateTime(2023, 12, 1),
        receiptImagePath: '/path/to/image.jpg',
        location: 'Test Location',
        createdAt: DateTime(2023, 12, 1),
        updatedAt: DateTime(2023, 12, 1),
      );

      // Convert to map
      final expenseMap = originalExpense.toMap();
      expect(expenseMap['id'], 'test-id');
      expect(expenseMap['title'], 'Test Expense');
      expect(expenseMap['amount'], 100.0);

      // Convert back from map
      final reconstructedExpense = Expense.fromMap(expenseMap);
      expect(reconstructedExpense.id, originalExpense.id);
      expect(reconstructedExpense.title, originalExpense.title);
      expect(reconstructedExpense.amount, originalExpense.amount);
      expect(reconstructedExpense.categoryId, originalExpense.categoryId);
    });

    test('Expense copyWith method', () {
      final originalExpense = Expense(
        title: 'Original Title',
        description: 'Original description',
        amount: 100.0,
        categoryId: 'original-category',
        date: DateTime(2023, 12, 1),
        createdAt: DateTime(2023, 12, 1),
        updatedAt: DateTime(2023, 12, 1),
      );

      final updatedExpense = originalExpense.copyWith(
        title: 'Updated Title',
        amount: 150.0,
      );

      expect(updatedExpense.title, 'Updated Title');
      expect(updatedExpense.amount, 150.0);
      expect(updatedExpense.description, 'Original description'); // Should remain unchanged
      expect(updatedExpense.categoryId, 'original-category'); // Should remain unchanged
    });
  });

  group('ExpenseCategory Model Tests', () {
    test('Create expense category object', () {
      final category = ExpenseCategory(
        name: 'Food',
        description: 'Food expenses',
        icon: Icons.restaurant,
        color: Colors.orange,
        createdAt: DateTime(2023, 12, 1),
        updatedAt: DateTime(2023, 12, 1),
      );

      expect(category.name, 'Food');
      expect(category.description, 'Food expenses');
      expect(category.icon, Icons.restaurant);
      expect(category.color, Colors.orange);
    });

    test('ExpenseCategory to/from Map conversion', () {
      final originalCategory = ExpenseCategory(
        id: 'food-category',
        name: 'Food',
        description: 'Food expenses',
        icon: Icons.restaurant,
        color: Colors.orange,
        createdAt: DateTime(2023, 12, 1),
        updatedAt: DateTime(2023, 12, 1),
      );

      // Convert to map
      final categoryMap = originalCategory.toMap();
      expect(categoryMap['id'], 'food-category');
      expect(categoryMap['name'], 'Food');

      // Convert back from map
      final reconstructedCategory = ExpenseCategory.fromMap(categoryMap);
      expect(reconstructedCategory.id, originalCategory.id);
      expect(reconstructedCategory.name, originalCategory.name);
      expect(reconstructedCategory.description, originalCategory.description);
    });
  });
}