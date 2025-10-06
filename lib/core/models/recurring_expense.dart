enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
}

class RecurringExpense {
  final String? id;
  final String title;
  final String description;
  final double amount;
  final String categoryId;
  final RecurrenceType recurrenceType;
  final int recurrenceInterval; // Every N days/weeks/months/years
  final DateTime startDate;
  final DateTime? endDate;
  final List<int>? daysOfWeek; // For weekly recurrence (1=Monday, 7=Sunday)
  final int? dayOfMonth; // For monthly recurrence
  final DateTime? nextDueDate;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringExpense({
    this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.recurrenceType,
    this.recurrenceInterval = 1,
    required this.startDate,
    this.endDate,
    this.daysOfWeek,
    this.dayOfMonth,
    this.nextDueDate,
    this.isActive = true,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
      'recurrenceType': recurrenceType.index,
      'recurrenceInterval': recurrenceInterval,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'daysOfWeek': daysOfWeek?.join(','),
      'dayOfMonth': dayOfMonth,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'metadata': metadata?.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Map
  factory RecurringExpense.fromMap(Map<String, dynamic> map) {
    return RecurringExpense(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      categoryId: map['categoryId'] ?? '',
      recurrenceType: RecurrenceType.values[map['recurrenceType'] ?? 0],
      recurrenceInterval: map['recurrenceInterval'] ?? 1,
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      daysOfWeek: map['daysOfWeek'] != null 
          ? map['daysOfWeek'].split(',').map<int>((e) => int.parse(e)).toList()
          : null,
      dayOfMonth: map['dayOfMonth'],
      nextDueDate: map['nextDueDate'] != null 
          ? DateTime.parse(map['nextDueDate']) 
          : null,
      isActive: (map['isActive'] ?? 1) == 1,
      metadata: map['metadata'] != null ? _decodeMetadata(map['metadata']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Copy with method
  RecurringExpense copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? categoryId,
    RecurrenceType? recurrenceType,
    int? recurrenceInterval,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? nextDueDate,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate next due date based on recurrence type
  DateTime calculateNextDueDate() {
    final now = DateTime.now();
    DateTime nextDate = nextDueDate ?? startDate;

    while (nextDate.isBefore(now)) {
      switch (recurrenceType) {
        case RecurrenceType.daily:
          nextDate = nextDate.add(Duration(days: recurrenceInterval));
          break;
        case RecurrenceType.weekly:
          nextDate = nextDate.add(Duration(days: 7 * recurrenceInterval));
          break;
        case RecurrenceType.monthly:
          nextDate = DateTime(
            nextDate.year,
            nextDate.month + recurrenceInterval,
            dayOfMonth ?? nextDate.day,
          );
          break;
        case RecurrenceType.yearly:
          nextDate = DateTime(
            nextDate.year + recurrenceInterval,
            nextDate.month,
            nextDate.day,
          );
          break;
      }
    }

    return nextDate;
  }

  // Check if this recurring expense is due
  bool isDue() {
    final now = DateTime.now();
    final dueDate = nextDueDate ?? startDate;
    return isActive && 
           dueDate.isBefore(now) && 
           (endDate == null || now.isBefore(endDate!));
  }

  // Get recurrence description
  String get recurrenceDescription {
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return recurrenceInterval == 1 ? 'Daily' : 'Every $recurrenceInterval days';
      case RecurrenceType.weekly:
        return recurrenceInterval == 1 ? 'Weekly' : 'Every $recurrenceInterval weeks';
      case RecurrenceType.monthly:
        return recurrenceInterval == 1 ? 'Monthly' : 'Every $recurrenceInterval months';
      case RecurrenceType.yearly:
        return recurrenceInterval == 1 ? 'Yearly' : 'Every $recurrenceInterval years';
    }
  }

  static Map<String, dynamic> _decodeMetadata(String metadataString) {
    // Implement proper JSON parsing
    return {};
  }

  @override
  String toString() {
    return 'RecurringExpense{id: $id, title: $title, amount: $amount, recurrence: $recurrenceDescription}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurringExpense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}