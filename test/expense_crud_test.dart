import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:expensemate/core/services/expense_service.dart';
import 'package:expensemate/core/models/expense.dart';
import 'package:expensemate/core/models/expense_category.dart';
import 'package:expensemate/features/expenses_management/providers/expense_provider.dart';
import 'package:flutter/material.dart';

void main() {
  group('Expense Module CRUD Tests', () {
    late ExpenseService expenseService;
    late ExpenseProvider expenseProvider;

    setUpAll(() {
      // Initialize SQLite for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() {
      expenseService = ExpenseService();
      expenseProvider = ExpenseProvider();
    });

    test('ExpenseService - Create Expense', () async {
      // Create a test expense
      final testExpense = Expense(
        title: 'Test Grocery Shopping',
        description: 'Weekly groceries',
        amount: 75.50,
        categoryId: 'test-category-1',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test creating expense
      final expenseId = await expenseService.createExpense(testExpense);
      
      expect(expenseId, isNotEmpty);
      expect(expenseId, isA<String>());
      
      // Verify expense was created
      final retrievedExpense = await expenseService.getExpenseById(expenseId);
      expect(retrievedExpense, isNotNull);
      expect(retrievedExpense!.title, equals('Test Grocery Shopping'));
      expect(retrievedExpense.amount, equals(75.50));
    });

    test('ExpenseService - Read All Expenses', () async {
      // Create multiple test expenses
      final expenses = [
        Expense(
          title: 'Gas Station',
          description: 'Fill up tank',
          amount: 45.00,
          categoryId: 'transport',
          date: DateTime.now().subtract(Duration(days: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Expense(
          title: 'Coffee Shop',
          description: 'Morning coffee',
          amount: 5.50,
          categoryId: 'food',
          date: DateTime.now().subtract(Duration(days: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Create expenses
      for (var expense in expenses) {
        await expenseService.createExpense(expense);
      }

      // Retrieve all expenses
      final allExpenses = await expenseService.getAllExpenses();
      
      expect(allExpenses.length, greaterThanOrEqualTo(2));
      expect(allExpenses.any((e) => e.title == 'Gas Station'), isTrue);
      expect(allExpenses.any((e) => e.title == 'Coffee Shop'), isTrue);
    });

    test('ExpenseService - Update Expense', () async {
      // Create initial expense
      final originalExpense = Expense(
        title: 'Original Title',
        description: 'Original description',
        amount: 100.0,
        categoryId: 'test-category',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final expenseId = await expenseService.createExpense(originalExpense);
      
      // Update the expense
      final updatedExpense = originalExpense.copyWith(
        id: expenseId,
        title: 'Updated Title',
        description: 'Updated description',
        amount: 150.0,
      );

      final updateSuccess = await expenseService.updateExpense(updatedExpense);
      expect(updateSuccess, isTrue);

      // Verify the update
      final retrievedExpense = await expenseService.getExpenseById(expenseId);
      expect(retrievedExpense!.title, equals('Updated Title'));
      expect(retrievedExpense.description, equals('Updated description'));
      expect(retrievedExpense.amount, equals(150.0));
    });

    test('ExpenseService - Delete Expense', () async {
      // Create expense to delete
      final expenseToDelete = Expense(
        title: 'Expense to Delete',
        description: 'This will be deleted',
        amount: 25.0,
        categoryId: 'test-category',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final expenseId = await expenseService.createExpense(expenseToDelete);
      
      // Verify expense exists
      final expenseBeforeDelete = await expenseService.getExpenseById(expenseId);
      expect(expenseBeforeDelete, isNotNull);

      // Delete the expense
      final deleteSuccess = await expenseService.deleteExpense(expenseId);
      expect(deleteSuccess, isTrue);

      // Verify expense no longer exists
      final expenseAfterDelete = await expenseService.getExpenseById(expenseId);
      expect(expenseAfterDelete, isNull);
    });

    test('ExpenseProvider - Add Expense Through Provider', () async {
      // Initialize the provider
      await expenseProvider.initialize();

      // Create test expense
      final testExpense = Expense(
        title: 'Provider Test Expense',
        description: 'Testing through provider',
        amount: 85.75,
        categoryId: 'test-category',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add expense through provider
      final success = await expenseProvider.addExpense(testExpense);
      expect(success, isTrue);

      // Check if expense appears in provider's expense list
      final expenses = expenseProvider.expenses;
      expect(expenses.any((e) => e.title == 'Provider Test Expense'), isTrue);
    });

    test('ExpenseProvider - Filter Functionality', () async {
      // Initialize the provider
      await expenseProvider.initialize();

      // Create test expenses with different categories
      final foodExpense = Expense(
        title: 'Food Expense',
        description: 'Test food expense',
        amount: 30.0,
        categoryId: 'food-category',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final transportExpense = Expense(
        title: 'Transport Expense',
        description: 'Test transport expense',
        amount: 40.0,
        categoryId: 'transport-category',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add expenses
      await expenseProvider.addExpense(foodExpense);
      await expenseProvider.addExpense(transportExpense);

      // Test category filter
      expenseProvider.setCategoryFilter('food-category');
      final foodOnlyExpenses = expenseProvider.expenses;
      expect(foodOnlyExpenses.every((e) => e.categoryId == 'food-category'), isTrue);

      // Test search filter
      expenseProvider.clearFilters();
      expenseProvider.setSearchQuery('Food');
      final searchResults = expenseProvider.expenses;
      expect(searchResults.any((e) => e.title.contains('Food')), isTrue);
    });

    test('ExpenseProvider - Total Amount Calculation', () async {
      // Initialize the provider
      await expenseProvider.initialize();

      // Create test expenses
      final expenses = [
        Expense(
          title: 'Expense 1',
          description: 'Test expense 1',
          amount: 10.0,
          categoryId: 'test-category',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Expense(
          title: 'Expense 2',
          description: 'Test expense 2',
          amount: 20.0,
          categoryId: 'test-category',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Expense(
          title: 'Expense 3',
          description: 'Test expense 3',
          amount: 30.0,
          categoryId: 'test-category',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Add all expenses
      for (var expense in expenses) {
        await expenseProvider.addExpense(expense);
      }

      // Check total amount
      final totalAmount = expenseProvider.totalAmount;
      expect(totalAmount, equals(60.0)); // 10 + 20 + 30
    });
  });
}