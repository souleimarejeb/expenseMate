import 'dart:convert';

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
      'category_id': categoryId, // SQLite uses snake_case
      'date': date.toIso8601String(),
      'receiptImagePath': receiptImagePath,
      'location': location,
      'metadata': metadata != null ? _encodeMetadata(metadata!) : null,
      'created_at': createdAt.toIso8601String(), // SQLite uses snake_case
      'updated_at': updatedAt.toIso8601String(), // SQLite uses snake_case
    };
  }

  // Create Expense from Map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      categoryId: map['category_id'] ?? map['categoryId'] ?? '', // Support both formats for backward compatibility
      date: DateTime.parse(map['date']),
      receiptImagePath: map['receiptImagePath'],
      location: map['location'],
      metadata: map['metadata'] != null ? _decodeMetadata(map['metadata']) : null,
      createdAt: DateTime.parse(map['created_at'] ?? map['createdAt'] ?? DateTime.now().toIso8601String()), // Support both formats
      updatedAt: DateTime.parse(map['updated_at'] ?? map['updatedAt'] ?? DateTime.now().toIso8601String()), // Support both formats
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
    // Proper JSON encoding using dart:convert
    try {
      return jsonEncode(metadata);
    } catch (e) {
      return '{}';
    }
  }

  static Map<String, dynamic> _decodeMetadata(String metadataString) {
    // Proper JSON decoding using dart:convert
    try {
      final decoded = jsonDecode(metadataString);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (e) {
      return {};
    }
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