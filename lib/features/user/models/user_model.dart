// user_model.dart
import 'dart:convert';

class UserModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? avatarPath;
  final DateTime? dateOfBirth;
  final String? bio;
  final String? occupation;
  final double? monthlyIncome;
  final String? currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? preferences;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatarPath,
    this.dateOfBirth,
    this.bio,
    this.occupation,
    this.monthlyIncome,
    this.currency = 'USD',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
    this.preferences,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Computed properties
  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';
  
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // CopyWith method for immutable updates
  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarPath,
    DateTime? dateOfBirth,
    String? bio,
    String? occupation,
    double? monthlyIncome,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarPath: avatarPath ?? this.avatarPath,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      occupation: occupation ?? this.occupation,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
    );
  }

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'avatarPath': avatarPath,
      'dateOfBirth': dateOfBirth?.millisecondsSinceEpoch,
      'bio': bio,
      'occupation': occupation,
      'monthlyIncome': monthlyIncome,
      'currency': currency,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isActive': isActive ? 1 : 0,
      'preferences': preferences != null ? jsonEncode(preferences) : null,
    };
  }

  // Create from Map (database result)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toInt(),
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      avatarPath: map['avatarPath'],
      dateOfBirth: map['dateOfBirth'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'])
          : null,
      bio: map['bio'],
      occupation: map['occupation'],
      monthlyIncome: map['monthlyIncome']?.toDouble(),
      currency: map['currency'] ?? 'USD',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      isActive: map['isActive'] == 1,
      preferences: map['preferences'] != null 
          ? jsonDecode(map['preferences'])
          : null,
    );
  }

  // Convert to JSON
  String toJson() => jsonEncode(toMap());

  // Create from JSON
  factory UserModel.fromJson(String source) => UserModel.fromMap(jsonDecode(source));

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, email: $email, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}