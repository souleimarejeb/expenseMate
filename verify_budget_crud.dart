import 'package:flutter/material.dart';
import 'package:expensemate/core/services/budget_service.dart';
import 'package:expensemate/core/database/sqlite_database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== Budget CRUD Verification ===\n');
  
  final budgetService = BudgetService();
  final dbHelper = SQLiteDatabaseHelper.instance;
  
  try {
    // Clear existing budgets
    print('1. Clearing existing budgets...');
    final db = await dbHelper.database;
    await db.delete('budgets');
    print('   ✓ Budgets cleared\n');
    
    // Create budgets
    print('2. Creating budgets...');
    final now = DateTime.now();
    
    final foodBudget = await budgetService.createBudget(
      limitAmount: 500.0,
      month: now.month,
      year: now.year,
      category: 'food',
    );
    print('   ✓ Created food budget: ${foodBudget.id}');
    
    final transportBudget = await budgetService.createBudget(
      limitAmount: 300.0,
      month: now.month,
      year: now.year,
      category: 'transport',
    );
    print('   ✓ Created transport budget: ${transportBudget.id}');
    
    final entertainmentBudget = await budgetService.createBudget(
      limitAmount: 200.0,
      month: now.month,
      year: now.year,
      category: 'entertainment',
    );
    print('   ✓ Created entertainment budget: ${entertainmentBudget.id}\n');
    
    // Read all budgets
    print('3. Reading all budgets...');
    final allBudgets = await budgetService.getAllBudgets();
    print('   ✓ Found ${allBudgets.length} budgets:');
    for (final budget in allBudgets) {
      print('     - ${budget.category}: \$${budget.limitAmount} (spent: \$${budget.spentAmount})');
    }
    print('');
    
    // Read budgets for current month
    print('4. Reading budgets for current month...');
    final monthBudgets = await budgetService.getBudgetsForMonth(now.month, now.year);
    print('   ✓ Found ${monthBudgets.length} budgets for ${now.month}/${now.year}\n');
    
    // Update spent amount
    print('5. Updating spent amounts...');
    await budgetService.updateSpentAmount(foodBudget.id!, 250.0);
    print('   ✓ Updated food budget spent amount to \$250.0');
    
    await budgetService.incrementSpentAmount(transportBudget.id!, 120.0);
    print('   ✓ Incremented transport budget spent amount by \$120.0');
    
    final updatedFoodBudget = await budgetService.getBudgetById(foodBudget.id!);
    print('   ✓ Food budget status: ${updatedFoodBudget!.status}');
    print('   ✓ Food budget remaining: \$${updatedFoodBudget.remaining}\n');
    
    // Test budget status changes
    print('6. Testing budget status changes...');
    await budgetService.updateSpentAmount(entertainmentBudget.id!, 170.0); // 85%
    final nearLimitBudget = await budgetService.getBudgetById(entertainmentBudget.id!);
    print('   ✓ Entertainment at 85%: ${nearLimitBudget!.status}');
    
    await budgetService.updateSpentAmount(entertainmentBudget.id!, 220.0); // 110%
    final exceededBudget = await budgetService.getBudgetById(entertainmentBudget.id!);
    print('   ✓ Entertainment at 110%: ${exceededBudget!.status}\n');
    
    // Get budget statistics
    print('7. Getting budget statistics...');
    final stats = await budgetService.getBudgetStatistics(now.month, now.year);
    print('   ✓ Total limit: \$${stats['totalLimit']}');
    print('   ✓ Total spent: \$${stats['totalSpent']}');
    print('   ✓ Remaining: \$${stats['remaining']}');
    print('   ✓ Percentage used: ${stats['percentage'].toStringAsFixed(2)}%');
    print('   ✓ Budget count: ${stats['budgetCount']}');
    print('   ✓ OK: ${stats['okCount']}, Near limit: ${stats['nearLimitCount']}, Exceeded: ${stats['exceededCount']}\n');
    
    // Test upsert
    print('8. Testing upsert (update existing)...');
    final upsertedBudget = await budgetService.upsertBudget(
      limitAmount: 600.0,
      month: now.month,
      year: now.year,
      category: 'food',
    );
    print('   ✓ Food budget limit updated to \$${upsertedBudget.limitAmount}');
    
    final allBudgetsAfterUpsert = await budgetService.getBudgetsForMonth(now.month, now.year);
    print('   ✓ Still ${allBudgetsAfterUpsert.length} budgets (no duplicates)\n');
    
    // Test batch create
    print('9. Testing batch budget creation...');
    final nextMonth = DateTime(now.year, now.month + 1);
    final categoryBudgets = {
      'food': 550.0,
      'transport': 350.0,
      'bills': 400.0,
    };
    
    final batchBudgets = await budgetService.createBudgetsForCategories(
      categoryBudgets,
      nextMonth.month,
      nextMonth.year,
    );
    print('   ✓ Created ${batchBudgets.length} budgets for next month\n');
    
    // Test recalculate spent amounts
    print('10. Testing recalculate spent amounts...');
    final categorySpending = {
      'food': 325.0,
      'transport': 180.0,
      'entertainment': 95.0,
    };
    
    await budgetService.recalculateSpentAmounts(now.month, now.year, categorySpending);
    print('   ✓ Recalculated spent amounts based on actual spending');
    
    final recalculatedBudgets = await budgetService.getBudgetsForMonth(now.month, now.year);
    for (final budget in recalculatedBudgets) {
      print('     - ${budget.category}: spent \$${budget.spentAmount}');
    }
    print('');
    
    // Delete a budget
    print('11. Deleting a budget...');
    await budgetService.deleteBudget(entertainmentBudget.id!);
    final remainingBudgets = await budgetService.getBudgetsForMonth(now.month, now.year);
    print('   ✓ Deleted entertainment budget');
    print('   ✓ Remaining budgets: ${remainingBudgets.length}\n');
    
    // Delete budgets for a month
    print('12. Deleting all budgets for next month...');
    await budgetService.deleteBudgetsForMonth(nextMonth.month, nextMonth.year);
    final nextMonthBudgets = await budgetService.getBudgetsForMonth(nextMonth.month, nextMonth.year);
    print('   ✓ Deleted all budgets for ${nextMonth.month}/${nextMonth.year}');
    print('   ✓ Remaining next month budgets: ${nextMonthBudgets.length}\n');
    
    print('=== All Budget CRUD operations completed successfully! ===');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}
