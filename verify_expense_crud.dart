#!/usr/bin/env dart

/// Expense Module CRUD Verification Script
/// This script performs static analysis and basic functionality checks
/// to verify that the expense module CRUD operations are properly implemented.

import 'dart:io';

void main() {
  print('🔍 ExpenseMate - Expense Module CRUD Verification');
  print('=' * 50);
  
  // Check if we're in the right directory
  if (!Directory.current.path.contains('expenseMate')) {
    print('❌ Please run this script from the expenseMate project directory');
    exit(1);
  }
  
  var allChecks = <String, bool>{};
  
  // 1. Check Model Files
  print('\n📁 Checking Model Files...');
  allChecks['Expense Model'] = checkFile('lib/core/models/expense.dart', [
    'class Expense',
    'toMap()',
    'fromMap(',
    'copyWith('
  ]);
  
  allChecks['ExpenseCategory Model'] = checkFile('lib/core/models/expense_category.dart', [
    'class ExpenseCategory',
    'toMap()',
    'fromMap('
  ]);
  
  allChecks['RecurringExpense Model'] = checkFile('lib/core/models/recurring_expense.dart', [
    'class RecurringExpense'
  ]);
  
  // 2. Check Service Layer
  print('\n🔧 Checking Service Layer...');
  allChecks['Database Helper'] = checkFile('lib/core/database/databaseHelper.dart', [
    'class DatabaseHelper',
    'CREATE TABLE expenses',
    'CREATE TABLE expense_categories'
  ]);
  
  allChecks['Expense Service'] = checkFile('lib/core/services/expense_service.dart', [
    'createExpense(',
    'getAllExpenses(',
    'updateExpense(',
    'deleteExpense(',
    'getExpenseById('
  ]);
  
  // 3. Check Provider/State Management
  print('\n📊 Checking State Management...');
  allChecks['Expense Provider'] = checkFile('lib/features/expenses_management/providers/expense_provider.dart', [
    'class ExpenseProvider',
    'addExpense(',
    'updateExpense(',
    'deleteExpense(',
    'loadExpenses('
  ]);
  
  // 4. Check UI Components
  print('\n🖥️ Checking UI Components...');
  allChecks['Expenses Screen'] = checkFile('lib/features/expenses_management/screens/expenses_screen.dart', [
    'class ExpensesScreen',
    'Consumer<ExpenseProvider>',
    'FloatingActionButton'
  ]);
  
  allChecks['Add/Edit Screen'] = checkFile('lib/features/expenses_management/screens/add_edit_expense_screen.dart', [
    'class AddEditExpenseScreen',
    'TextEditingController',
    'GlobalKey<FormState>'
  ]);
  
  // 5. Check Integration
  print('\n🔗 Checking Integration...');
  allChecks['Main App Setup'] = checkFile('lib/main.dart', [
    'MultiProvider',
    'ChangeNotifierProvider',
    'ExpenseProvider'
  ]);
  
  allChecks['Main Layout'] = checkFile('lib/features/widgets/main_layout.dart', [
    'ExpensesScreen',
    'BottomNavigationBar'
  ]);
  
  // 6. Check Dependencies
  print('\n📦 Checking Dependencies...');
  allChecks['Dependencies'] = checkFile('pubspec.yaml', [
    'provider:',
    'sqflite:',
    'uuid:'
  ]);
  
  // 7. Run Model Tests
  print('\n🧪 Running Model Tests...');
  var testResult = runTests();
  allChecks['Model Tests'] = testResult;
  
  // Print Summary
  print('\n📋 VERIFICATION SUMMARY');
  print('=' * 50);
  
  var passedChecks = 0;
  var totalChecks = allChecks.length;
  
  allChecks.forEach((checkName, passed) {
    var status = passed ? '✅' : '❌';
    print('$status $checkName');
    if (passed) passedChecks++;
  });
  
  print('\nResult: $passedChecks/$totalChecks checks passed');
  
  if (passedChecks == totalChecks) {
    print('\n🎉 ALL CHECKS PASSED! The expense module CRUD functionality appears to be properly implemented.');
    print('\n📝 Next Steps:');
    print('   1. Run the app and manually test using: EXPENSE_CRUD_TEST_GUIDE.md');
    print('   2. Add some test expenses and verify all operations work');
    print('   3. Test the UI responsiveness and user experience');
  } else {
    print('\n⚠️  Some checks failed. Please review the missing components above.');
  }
  
  exit(passedChecks == totalChecks ? 0 : 1);
}

bool checkFile(String filePath, List<String> requiredContent) {
  try {
    var file = File(filePath);
    if (!file.existsSync()) {
      print('   ❌ $filePath - File not found');
      return false;
    }
    
    var content = file.readAsStringSync();
    var missingContent = <String>[];
    
    for (var required in requiredContent) {
      if (!content.contains(required)) {
        missingContent.add(required);
      }
    }
    
    if (missingContent.isEmpty) {
      print('   ✅ $filePath - All required content found');
      return true;
    } else {
      print('   ❌ $filePath - Missing: ${missingContent.join(", ")}');
      return false;
    }
  } catch (e) {
    print('   ❌ $filePath - Error reading file: $e');
    return false;
  }
}

bool runTests() {
  try {
    print('   🏃 Running model tests...');
    var result = Process.runSync('flutter', ['test', 'test/expense_model_test.dart']);
    
    if (result.exitCode == 0) {
      print('   ✅ Model tests passed');
      return true;
    } else {
      print('   ❌ Model tests failed');
      print('   Output: ${result.stdout}');
      print('   Error: ${result.stderr}');
      return false;
    }
  } catch (e) {
    print('   ⚠️ Could not run tests: $e');
    return false;
  }
}