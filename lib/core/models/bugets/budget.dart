
import 'package:expensemate/core/models/bugets/budget_status.dart';

class Budget {
   int? id;
   final double limitAmount;   
   final double spentAmount;   
   final BudgetStatus status; 
   final DateTime createdAt;   
   final DateTime updatedAt;   
   final int month;

   Budget({
     required this.limitAmount,
     required this.spentAmount,
     required this.status,
     required this.createdAt,
     required this.updatedAt,
     required this.month,
   });

   /// Convenience computed fields
   double get remaining => limitAmount - spentAmount;
   double get percentageUsed =>
       limitAmount <= 0 ? 0.0 : (spentAmount / limitAmount) * 100.0;

   double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }     


  Map<String, dynamic> toJson() {
    String statusToString(BudgetStatus s) {
      switch (s) {
        case BudgetStatus.nearLimit:
          return 'nearLimit';
        case BudgetStatus.exceeded:
          return 'exceeded';
        case BudgetStatus.ok:
        default:
          return 'ok';
      }
    }

    return {
      'limit_amount': limitAmount,
      'spent_amount': spentAmount,
      'status': statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'month': month,
    };
  }

  @override
  String toString() {
    return 'Budget(limit: $limitAmount, spent: $spentAmount, status: $status, month: $month)';
  }


}