import 'budget_status.dart'; 

class Budget {
  final String? id;          
  final double limitAmount;   
  final double spentAmount;   
  final BudgetStatus status;  
  final DateTime createdAt;  
  final DateTime updatedAt;   
  final int month;            
  final String? category;     

  Budget({
    this.id,
    required this.limitAmount,
    required this.spentAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.month,
    this.category,
  });

  /// Convenience computed fields
  double get remaining => limitAmount - spentAmount;
  double get percentageUsed =>
      limitAmount <= 0 ? 0.0 : (spentAmount / limitAmount) * 100.0;

  Budget copyWith({
    String? id,
    double? limitAmount,
    double? spentAmount,
    BudgetStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? month,
    String? category,
  }) {
    return Budget(
      id: id ?? this.id,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      month: month ?? this.month,
      category: category ?? this.category,
    );
  }

  /// JSON (de)serialization — ISO8601 for dates, status as string
  factory Budget.fromJson(Map<String, dynamic> json) {
    BudgetStatus parseStatus(String? s) {
      if (s == null) return BudgetStatus.ok;
      switch (s.toLowerCase()) {
        case 'nearlimit':
        case 'near_limit':
        case 'near-limit':
          return BudgetStatus.nearLimit;
        case 'exceeded':
          return BudgetStatus.exceeded;
        case 'ok':
        default:
          return BudgetStatus.ok;
      }
    }

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

    return Budget(
      id: json['id'] as String?,
      limitAmount: parseDouble(json['limit_amount'] ?? json['limitAmount']),
      spentAmount: parseDouble(json['spent_amount'] ?? json['spentAmount']),
      status: parseStatus(json['status'] as String?),
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
      month: (json['month'] is int)
          ? json['month'] as int
          : int.tryParse('${json['month']}') ?? DateTime.now().month,
      category: (json['category'] as String?) ??
          (json['category_name'] as String?) ??
          (json['categoryId'] as String?),
    );
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
      if (id != null) 'id': id,
      'limit_amount': limitAmount,
      'spent_amount': spentAmount,
      'status': statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'month': month,
      if (category != null) 'category': category,
    };
  }

  @override
  String toString() {
    return 'Budget(id:$id, category:$category, limit: $limitAmount, spent: $spentAmount, status: $status, month: $month)';
  }


  @override
  int get hashCode =>
      (id ?? '').hashCode ^
      limitAmount.hashCode ^
      spentAmount.hashCode ^
      status.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      month.hashCode ^
      (category ?? '').hashCode;
}
