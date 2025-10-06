class Expense {
  final String? id;
  final String title;
  final String description;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? receiptImagePath;
  final String? location;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.receiptImagePath,
    this.location,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Expense to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'receiptImagePath': receiptImagePath,
      'location': location,
      'metadata': metadata != null ? _encodeMetadata(metadata!) : null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Expense from Map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      categoryId: map['categoryId'] ?? '',
      date: DateTime.parse(map['date']),
      receiptImagePath: map['receiptImagePath'],
      location: map['location'],
      metadata: map['metadata'] != null ? _decodeMetadata(map['metadata']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Copy with method for immutable updates
  Expense copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? receiptImagePath,
    String? location,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for metadata encoding/decoding
  static String _encodeMetadata(Map<String, dynamic> metadata) {
    // Simple JSON encoding - you might want to use dart:convert in real implementation
    return metadata.toString();
  }

  static Map<String, dynamic> _decodeMetadata(String metadataString) {
    // Simple decoding - implement proper JSON parsing
    return {};
  }

  @override
  String toString() {
    return 'Expense{id: $id, title: $title, amount: $amount, date: $date}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}