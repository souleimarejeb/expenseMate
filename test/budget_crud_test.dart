import 'package:flutter_test/flutter_test.dart';
import 'package:expensemate/core/services/budget_service.dart';
import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart';
import 'package:expensemate/core/database/sqlite_database_helper.dart';

void main() {
  late BudgetService budgetService;
  late SQLiteDatabaseHelper dbHelper;

  setUpAll(() async {
    // Initialize database
    dbHelper = SQLiteDatabaseHelper.instance;
    await dbHelper.database;
    budgetService = BudgetService();
  });

  setUp(() async {
    // Clear budgets before each test
    final db = await dbHelper.database;
    await db.delete('budgets');
  });

  group('Budget CRUD Operations', () {
    test('Create budget', () async {
      // Arrange
      final now = DateTime.now();
      
      // Act
      final budget = await budgetService.createBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
        spentAmount: 0.0,
      );

      // Assert
      expect(budget.id, isNotNull);
      expect(budget.limitAmount, 500.0);
      expect(budget.spentAmount, 0.0);
      expect(budget.month, now.month);
      expect(budget.category, 'food');
      expect(budget.status, BudgetStatus.ok);
    });

    test('Get budget by ID', () async {
      // Arrange
      final now = DateTime.now();
      final createdBudget = await budgetService.createBudget(
        limitAmount: 300.0,
        month: now.month,
        year: now.year,
        category: 'transport',
      );

      // Act
      final fetchedBudget = await budgetService.getBudgetById(createdBudget.id!);

      // Assert
      expect(fetchedBudget, isNotNull);
      expect(fetchedBudget!.id, createdBudget.id);
      expect(fetchedBudget.limitAmount, 300.0);
      expect(fetchedBudget.category, 'transport');
    });

    test('Get all budgets', () async {
      // Arrange
      final now = DateTime.now();
      await budgetService.createBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
      );
      await budgetService.createBudget(
        limitAmount: 300.0,
        month: now.month,
        year: now.year,
        category: 'transport',
      );

      // Act
      final budgets = await budgetService.getAllBudgets();

      // Assert
      expect(budgets.length, 2);
      expect(budgets[0].category, isIn(['food', 'transport']));
      expect(budgets[1].category, isIn(['food', 'transport']));
    });

    test('Get budgets for specific month', () async {
      // Arrange
      final now = DateTime.now();
      final nextMonth = DateTime(now.year, now.month + 1);
      
      await budgetService.createBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
      );
      await budgetService.createBudget(
        limitAmount: 300.0,
        month: nextMonth.month,
        year: nextMonth.year,
        category: 'transport',
      );

      // Act
      final currentMonthBudgets = await budgetService.getBudgetsForMonth(now.month, now.year);
      final nextMonthBudgets = await budgetService.getBudgetsForMonth(nextMonth.month, nextMonth.year);

      // Assert
      expect(currentMonthBudgets.length, 1);
      expect(currentMonthBudgets[0].category, 'food');
      expect(nextMonthBudgets.length, 1);
      expect(nextMonthBudgets[0].category, 'transport');
    });

    test('Update budget', () async {
      // Arrange
      final now = DateTime.now();
      final budget = await budgetService.createBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
      );

      // Act
      final updatedBudget = budget.copyWith(limitAmount: 600.0);
      await budgetService.updateBudget(updatedBudget);
      final fetchedBudget = await budgetService.getBudgetById(budget.id!);

      // Assert
      expect(fetchedBudget!.limitAmount, 600.0);
    });

    test('Update spent amount', () async {
      // Arrange
      final now = DateTime.now();
      final budget = await budgetService.createBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
      );

      // Act
      await budgetService.updateSpentAmount(budget.id!, 250.0);
      final updatedBudget = await budgetService.getBudgetById(budget.id!);

      // Assert
      expect(updatedBudget!.spentAmount, 250.0);
      expect(updatedBudget.status, BudgetStatus.ok); // 250/500 = 50%
    });

    test('Budget status changes based on spending', () async {
      // Arrange
      final now = DateTime.now();
      final budget = await budgetService.createBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
      );

      // Act & Assert - OK status
      await budgetService.updateSpentAmount(budget.id!, 300.0); // 60%
      var updatedBudget = await budgetService.getBudgetById(budget.id!);
      expect(updatedBudget!.status, BudgetStatus.ok);

      // Act & Assert - Near limit status
      await budgetService.updateSpentAmount(budget.id!, 420.0); // 84%
      updatedBudget = await budgetService.getBudgetById(budget.id!);
      expect(updatedBudget!.status, BudgetStatus.nearLimit);

      // Act & Assert - Exceeded status
      await budgetService.updateSpentAmount(budget.id!, 550.0); // 110%
      updatedBudget = await budgetService.getBudgetById(budget.id!);
      expect(updatedBudget!.status, BudgetStatus.exceeded);
    });

    test('Increment spent amount', () async {
      // Arrange
      final now = DateTime.now();
      final budget = await budgetService.createBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
        spentAmount: 100.0,
      );

      // Act
      await budgetService.incrementSpentAmount(budget.id!, 50.0);
      final updatedBudget = await budgetService.getBudgetById(budget.id!);

      // Assert
      expect(updatedBudget!.spentAmount, 150.0);
    });

    test('Decrement spent amount', () async {
      // Arrange
      final now = DateTime.now();
      final budget = await budgetService.createBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
        spentAmount: 100.0,
      );

      // Act
      await budgetService.decrementSpentAmount(budget.id!, 30.0);
      final updatedBudget = await budgetService.getBudgetById(budget.id!);

      // Assert
      expect(updatedBudget!.spentAmount, 70.0);
    });

    test('Delete budget', () async {
      // Arrange
      final now = DateTime.now();
      final budget = await budgetService.createBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
      );

      // Act
      await budgetService.deleteBudget(budget.id!);
      final fetchedBudget = await budgetService.getBudgetById(budget.id!);

      // Assert
      expect(fetchedBudget, isNull);
    });

    test('Upsert budget - create new', () async {
      // Arrange
      final now = DateTime.now();

      // Act
      final budget = await budgetService.upsertBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
      );

      // Assert
      expect(budget.id, isNotNull);
      expect(budget.limitAmount, 500.0);
    });

    test('Upsert budget - update existing', () async {
      // Arrange
      final now = DateTime.now();
      await budgetService.createBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
      );

      // Act
      final updatedBudget = await budgetService.upsertBudget(
        limitAmount: 600.0,
        month: now.month,
        year: now.year,
        category: 'food',
      );

      final allBudgets = await budgetService.getBudgetsForMonth(now.month, now.year);

      // Assert
      expect(allBudgets.length, 1); // Should still be 1 budget
      expect(updatedBudget.limitAmount, 600.0);
    });

    test('Get budget statistics', () async {
      // Arrange
      final now = DateTime.now();
      await budgetService.createBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
        spentAmount: 300.0,
      );
      await budgetService.createBudget(
        limitAmount: 300.0,
        month: now.month,
        year: now.year,
        category: 'transport',
        spentAmount: 150.0,
      );

      // Act
      final stats = await budgetService.getBudgetStatistics(now.month, now.year);

      // Assert
      expect(stats['totalLimit'], 800.0);
      expect(stats['totalSpent'], 450.0);
      expect(stats['remaining'], 350.0);
      expect(stats['percentage'], 56.25); // 450/800 * 100
      expect(stats['budgetCount'], 2);
    });

    test('Recalculate spent amounts', () async {
      // Arrange
      final now = DateTime.now();
      await budgetService.createBudget(
        limitAmount: 500.0,
        month: now.month,
        year: now.year,
        category: 'food',
        spentAmount: 0.0,
      );
      await budgetService.createBudget(
        limitAmount: 300.0,
        month: now.month,
        year: now.year,
        category: 'transport',
        spentAmount: 0.0,
      );

      final categorySpending = {
        'food': 250.0,
        'transport': 150.0,
      };

      // Act
      await budgetService.recalculateSpentAmounts(now.month, now.year, categorySpending);

      // Assert
      final foodBudget = await budgetService.getBudgetForCategoryAndMonth('food', now.month, now.year);
      final transportBudget = await budgetService.getBudgetForCategoryAndMonth('transport', now.month, now.year);
      
      expect(foodBudget!.spentAmount, 250.0);
      expect(transportBudget!.spentAmount, 150.0);
    });
  });
}
