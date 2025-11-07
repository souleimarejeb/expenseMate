import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/expense_attachment.dart';

class LocalStorageHelper {
  static final LocalStorageHelper _instance = LocalStorageHelper._internal();
  static LocalStorageHelper get instance => _instance;
  LocalStorageHelper._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Initialize the local storage
  Future<void> initialize() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      await _initializeDefaultCategories();
    }
  }

  // Keys for different data types
  static const String _expensesKey = 'expenses';
  static const String _categoriesKey = 'categories';
  static const String _attachmentsKey = 'attachments';
  static const String _countersKey = 'counters';

  // Initialize default categories if none exist
  Future<void> _initializeDefaultCategories() async {
    final categories = await getCategories();
    if (categories.isEmpty) {
      final defaultCategories = [
        ExpenseCategory(
          id: '1',
          name: 'Food & Dining',
          description: 'Restaurant, groceries, etc.',
          icon: Icons.restaurant,
          color: Colors.orange,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ExpenseCategory(
          id: '2',
          name: 'Transportation',
          description: 'Gas, public transport, etc.',
          icon: Icons.directions_car,
          color: Colors.blue,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ExpenseCategory(
          id: '3',
          name: 'Shopping',
          description: 'Clothes, electronics, etc.',
          icon: Icons.shopping_bag,
          color: Colors.purple,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ExpenseCategory(
          id: '4',
          name: 'Entertainment',
          description: 'Movies, games, etc.',
          icon: Icons.movie,
          color: Colors.green,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ExpenseCategory(
          id: '5',
          name: 'Bills & Utilities',
          description: 'Electricity, water, internet, etc.',
          icon: Icons.receipt_long,
          color: Colors.red,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final category in defaultCategories) {
        await insertCategory(category);
      }
    }
  }

  // Generate unique IDs
  Future<String> _generateId(String type) async {
    final counters = _prefs.getString(_countersKey);
    Map<String, int> counterMap = {};
    
    if (counters != null) {
      counterMap = Map<String, int>.from(json.decode(counters));
    }
    
    final currentCount = counterMap[type] ?? 0;
    final newCount = currentCount + 1;
    counterMap[type] = newCount;
    
    await _prefs.setString(_countersKey, json.encode(counterMap));
    return '${type}_$newCount';
  }

  // EXPENSE METHODS
  
  Future<String> insertExpense(Expense expense) async {
    await initialize();
    
    final id = expense.id ?? await _generateId('expense');
    final expenseWithId = expense.copyWith(
      id: id,
      updatedAt: DateTime.now(),
    );
    
    final expenses = await getExpenses();
    expenses.removeWhere((e) => e.id == id); // Remove if exists (for updates)
    expenses.add(expenseWithId);
    
    final expenseJsonList = expenses.map((e) => e.toMap()).toList();
    await _prefs.setString(_expensesKey, json.encode(expenseJsonList));
    
    return id;
  }

  Future<List<Expense>> getExpenses() async {
    await initialize();
    
    final expensesJson = _prefs.getString(_expensesKey);
    if (expensesJson == null) return [];
    
    final List<dynamic> expenseList = json.decode(expensesJson);
    return expenseList.map((e) => Expense.fromMap(e)).toList();
  }

  Future<Expense?> getExpense(String id) async {
    final expenses = await getExpenses();
    try {
      return expenses.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<int> updateExpense(Expense expense) async {
    await insertExpense(expense); // Insert handles updates too
    return 1;
  }

  Future<int> deleteExpense(String id) async {
    await initialize();
    
    final expenses = await getExpenses();
    final originalLength = expenses.length;
    expenses.removeWhere((e) => e.id == id);
    
    final expenseJsonList = expenses.map((e) => e.toMap()).toList();
    await _prefs.setString(_expensesKey, json.encode(expenseJsonList));
    
    // Also delete associated attachments
    await deleteExpenseAttachments(id);
    
    return originalLength - expenses.length;
  }

  // CATEGORY METHODS
  
  Future<String> insertCategory(ExpenseCategory category) async {
    await initialize();
    
    final id = category.id ?? await _generateId('category');
    final categoryWithId = category.copyWith(
      id: id,
      updatedAt: DateTime.now(),
    );
    
    final categories = await getCategories();
    categories.removeWhere((c) => c.id == id); // Remove if exists
    categories.add(categoryWithId);
    
    final categoryJsonList = categories.map((c) => c.toMap()).toList();
    await _prefs.setString(_categoriesKey, json.encode(categoryJsonList));
    
    return id;
  }

  Future<List<ExpenseCategory>> getCategories() async {
    await initialize();
    
    final categoriesJson = _prefs.getString(_categoriesKey);
    if (categoriesJson == null) return [];
    
    final List<dynamic> categoryList = json.decode(categoriesJson);
    return categoryList.map((c) => ExpenseCategory.fromMap(c)).toList();
  }

  Future<ExpenseCategory?> getCategory(String id) async {
    final categories = await getCategories();
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<int> updateCategory(ExpenseCategory category) async {
    await insertCategory(category); // Insert handles updates too
    return 1;
  }

  Future<int> deleteCategory(String id) async {
    await initialize();
    
    final categories = await getCategories();
    final originalLength = categories.length;
    categories.removeWhere((c) => c.id == id);
    
    final categoryJsonList = categories.map((c) => c.toMap()).toList();
    await _prefs.setString(_categoriesKey, json.encode(categoryJsonList));
    
    return originalLength - categories.length;
  }

  // ATTACHMENT METHODS
  
  Future<String> insertExpenseAttachment(ExpenseAttachment attachment) async {
    await initialize();
    
    final id = attachment.id ?? await _generateId('attachment');
    final attachmentWithId = attachment.copyWith(
      id: id,
    );
    
    final attachments = await getAllExpenseAttachments();
    attachments.removeWhere((a) => a.id == id); // Remove if exists
    attachments.add(attachmentWithId);
    
    final attachmentJsonList = attachments.map((a) => a.toMap()).toList();
    await _prefs.setString(_attachmentsKey, json.encode(attachmentJsonList));
    
    return id;
  }

  Future<List<ExpenseAttachment>> getExpenseAttachments(String expenseId) async {
    final allAttachments = await getAllExpenseAttachments();
    return allAttachments.where((a) => a.expenseId == expenseId).toList();
  }

  Future<List<ExpenseAttachment>> getAllExpenseAttachments() async {
    await initialize();
    
    final attachmentsJson = _prefs.getString(_attachmentsKey);
    if (attachmentsJson == null) return [];
    
    final List<dynamic> attachmentList = json.decode(attachmentsJson);
    return attachmentList.map((a) => ExpenseAttachment.fromMap(a)).toList();
  }

  Future<ExpenseAttachment?> getExpenseAttachment(String attachmentId) async {
    final attachments = await getAllExpenseAttachments();
    try {
      return attachments.firstWhere((a) => a.id == attachmentId);
    } catch (e) {
      return null;
    }
  }

  Future<int> updateExpenseAttachment(ExpenseAttachment attachment) async {
    await insertExpenseAttachment(attachment); // Insert handles updates too
    return 1;
  }

  Future<int> deleteExpenseAttachment(String attachmentId) async {
    await initialize();
    
    final attachments = await getAllExpenseAttachments();
    final originalLength = attachments.length;
    attachments.removeWhere((a) => a.id == attachmentId);
    
    final attachmentJsonList = attachments.map((a) => a.toMap()).toList();
    await _prefs.setString(_attachmentsKey, json.encode(attachmentJsonList));
    
    return originalLength - attachments.length;
  }

  Future<int> deleteExpenseAttachments(String expenseId) async {
    await initialize();
    
    final attachments = await getAllExpenseAttachments();
    final originalLength = attachments.length;
    attachments.removeWhere((a) => a.expenseId == expenseId);
    
    final attachmentJsonList = attachments.map((a) => a.toMap()).toList();
    await _prefs.setString(_attachmentsKey, json.encode(attachmentJsonList));
    
    return originalLength - attachments.length;
  }

  Future<int> getAttachmentCount(String expenseId) async {
    final attachments = await getExpenseAttachments(expenseId);
    return attachments.length;
  }

  Future<int> getTotalAttachmentsSize(String expenseId) async {
    final attachments = await getExpenseAttachments(expenseId);
    return attachments.fold<int>(0, (total, attachment) => 
      total + (attachment.fileSize ?? 0));
  }

  // SEARCH AND ANALYTICS METHODS
  
  Future<List<Expense>> searchExpenses(String query) async {
    final expenses = await getExpenses();
    final lowerQuery = query.toLowerCase();
    
    return expenses.where((expense) {
      return expense.title.toLowerCase().contains(lowerQuery) ||
             expense.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    final expenses = await getExpenses();
    return expenses.where((e) => e.categoryId == categoryId).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final expenses = await getExpenses();
    return expenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
             expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<double> getTotalSpending() async {
    final expenses = await getExpenses();
    return expenses.fold<double>(0.0, (double total, expense) => total + expense.amount);
  }

  Future<double> getTotalSpendingByCategory(String categoryId) async {
    final expenses = await getExpensesByCategory(categoryId);
    return expenses.fold<double>(0.0, (double total, expense) => total + expense.amount);
  }

  Future<Map<String, double>> getSpendingByCategory() async {
    final expenses = await getExpenses();
    final categories = await getCategories();
    
    Map<String, double> spendingMap = {};
    
    for (final category in categories) {
      spendingMap[category.name] = 0.0;
    }
    
    for (final expense in expenses) {
      final category = categories.where((c) => c.id == expense.categoryId).firstOrNull;
      if (category != null) {
        spendingMap[category.name] = (spendingMap[category.name] ?? 0.0) + expense.amount;
      }
    }
    
    return spendingMap;
  }

  // UTILITY METHODS
  
  Future<void> clearAllData() async {
    await initialize();
    await _prefs.remove(_expensesKey);
    await _prefs.remove(_categoriesKey);
    await _prefs.remove(_attachmentsKey);
    await _prefs.remove(_countersKey);
  }

  Future<Map<String, dynamic>> exportData() async {
    await initialize();
    
    return {
      'expenses': await getExpenses(),
      'categories': await getCategories(),
      'attachments': await getAllExpenseAttachments(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    await initialize();
    
    if (data['expenses'] != null) {
      final expenses = (data['expenses'] as List)
          .map((e) => Expense.fromMap(e))
          .toList();
      
      for (final expense in expenses) {
        await insertExpense(expense);
      }
    }
    
    if (data['categories'] != null) {
      final categories = (data['categories'] as List)
          .map((c) => ExpenseCategory.fromMap(c))
          .toList();
      
      for (final category in categories) {
        await insertCategory(category);
      }
    }
    
    if (data['attachments'] != null) {
      final attachments = (data['attachments'] as List)
          .map((a) => ExpenseAttachment.fromMap(a))
          .toList();
      
      for (final attachment in attachments) {
        await insertExpenseAttachment(attachment);
      }
    }
  }
}