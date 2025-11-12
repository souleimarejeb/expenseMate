class AppUser {
  final int? id; // SQLite autoincrement id
  final String name;
  final String email;
  final String? avatarUrl;

  const AppUser({
    this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  AppUser copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int?,
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
      );
}
