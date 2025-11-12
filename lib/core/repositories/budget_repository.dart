// budget_repository.dart
import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expensemate/core/database/databaseHelper.dart';


class BudgetRepository {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<int> createBudget({
    required double limitAmount,
    required int month,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? category,
  }) async {
    final db = await _db;
    
    // Calculate initial status
    final status = BudgetStatus.ok;
    final spentAmount = 0.0;
    
    final data = {
      'limit_amount': limitAmount,
      'spent_amount': spentAmount,
      'status': _statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'month': month,
      'category': category,
    };
    
    return await db.insert('budgets', data, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<Budget?> getBudgetById(String id) async {
    final db = await _db;
    final res = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (res.isEmpty) return null;
    return Budget.fromJson(res.first);
  }

  Future<List<Budget>> getBudgetsByMonth(int month) async {
    final db = await _db;
    final res = await db.query(
      'budgets',
      where: 'month = ?',
      whereArgs: [month],
      orderBy: 'created_at DESC',
    );
    
    return res.map((row) => Budget.fromJson(row)).toList();
  }

  Future<List<Budget>> getBudgetsByCategory(String category) async {
    final db = await _db;
    final res = await db.query(
      'budgets',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'month DESC, created_at DESC',
    );
    
    return res.map((row) => Budget.fromJson(row)).toList();
  }

  Future<Budget?> getBudgetByMonthAndCategory(int month, String category) async {
    final db = await _db;
    final res = await db.query(
      'budgets',
      where: 'month = ? AND category = ?',
      whereArgs: [month, category],
      limit: 1,
    );
    
    if (res.isEmpty) return null;
    return Budget.fromJson(res.first);
  }

  Future<List<Budget>> getAllBudgets() async {
    final db = await _db;
    final res = await db.query(
      'budgets',
      orderBy: 'month DESC, created_at DESC',
    );
    
    return res.map((row) => Budget.fromJson(row)).toList();
  }

  Future<void> updateBudget({
    required String id,
    double? limitAmount,
    double? spentAmount,
    BudgetStatus? status,
    DateTime? updatedAt,
  }) async {
    final db = await _db;
    
    final updateData = <String, dynamic>{};
    
    if (limitAmount != null) updateData['limit_amount'] = limitAmount;
    if (spentAmount != null) updateData['spent_amount'] = spentAmount;
    if (status != null) updateData['status'] = _statusToString(status);
    updateData['updated_at'] = (updatedAt ?? DateTime.now()).toIso8601String();
    
    if (updateData.isEmpty) return;
    
    await db.update(
      'budgets',
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSpentAmount({
    required String id,
    required double spentAmount,
  }) async {
    final db = await _db;
    
    // Get current budget to calculate new status
    final budget = await getBudgetById(id);
    if (budget == null) return;
    
    BudgetStatus newStatus = BudgetStatus.ok;
    if (spentAmount >= budget.limitAmount) {
      newStatus = BudgetStatus.exceeded;
    } else if (spentAmount >= budget.limitAmount * 0.8) {
      newStatus = BudgetStatus.nearLimit;
    }
    
    await db.update(
      'budgets',
      {
        'spent_amount': spentAmount,
        'status': _statusToString(newStatus),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addExpenseToBudget({
    required String id,
    required double expenseAmount,
  }) async {
    final budget = await getBudgetById(id);
    if (budget == null) return;
    
    final newSpentAmount = budget.spentAmount + expenseAmount;
    await updateSpentAmount(id: id, spentAmount: newSpentAmount);
  }

  Future<void> deleteBudget(String id) async {
    final db = await _db;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteBudgetsByMonth(int month) async {
    final db = await _db;
    await db.delete(
      'budgets',
      where: 'month = ?',
      whereArgs: [month],
    );
  }

  // Helper method to convert BudgetStatus to string
  String _statusToString(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.nearLimit:
        return 'nearLimit';
      case BudgetStatus.exceeded:
        return 'exceeded';
      case BudgetStatus.ok:
      default:
        return 'ok';
    }
  }
}