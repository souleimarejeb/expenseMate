import 'dart:convert';

class User {
  final String? id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImagePath;
  final String? bio;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImagePath,
    this.bio,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert User to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image_path': profileImagePath,
      'bio': bio,
      'preferences': preferences != null ? _encodePreferences(preferences!) : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create User from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? map['phoneNumber'],
      profileImagePath: map['profile_image_path'] ?? map['profileImagePath'],
      bio: map['bio'],
      preferences: map['preferences'] != null ? _decodePreferences(map['preferences']) : null,
      createdAt: DateTime.parse(map['created_at'] ?? map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with method for immutable updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImagePath,
    String? bio,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for preferences encoding/decoding
  static String _encodePreferences(Map<String, dynamic> preferences) {
    try {
      return jsonEncode(preferences);
    } catch (e) {
      return '{}';
    }
  }

  static Map<String, dynamic> _decodePreferences(dynamic preferences) {
    if (preferences == null) return {};
    
    try {
      if (preferences is String) {
        return jsonDecode(preferences) as Map<String, dynamic>;
      } else if (preferences is Map) {
        return Map<String, dynamic>.from(preferences);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // Convert to JSON
  String toJson() => jsonEncode(toMap());

  // Create from JSON
  factory User.fromJson(String source) => User.fromMap(jsonDecode(source));

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phoneNumber: $phoneNumber, profileImagePath: $profileImagePath, bio: $bio, preferences: $preferences, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is User &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.phoneNumber == phoneNumber &&
      other.profileImagePath == profileImagePath &&
      other.bio == bio &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phoneNumber.hashCode ^
      profileImagePath.hashCode ^
      bio.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}
