// user_preferences_model.dart
import 'dart:convert';

class UserPreferencesModel {
  final String theme; // 'light', 'dark', 'system'
  final String language; // 'en', 'fr', 'es', etc.
  final String currency;
  final bool enableNotifications;
  final bool enableBiometric;
  final bool enableBackup;
  final bool enableAnalytics;
  final String dateFormat; // 'MM/dd/yyyy', 'dd/MM/yyyy', etc.
  final String timeFormat; // '12h', '24h'
  final Map<String, bool> categoryVisibility;
  final Map<String, dynamic> dashboardLayout;
  final List<String> favoriteCategories;
  final double budgetAlertThreshold; // 0.0 to 1.0 (percentage)

  UserPreferencesModel({
    this.theme = 'system',
    this.language = 'en',
    this.currency = 'USD',
    this.enableNotifications = true,
    this.enableBiometric = false,
    this.enableBackup = true,
    this.enableAnalytics = true,
    this.dateFormat = 'MM/dd/yyyy',
    this.timeFormat = '12h',
    this.categoryVisibility = const {},
    this.dashboardLayout = const {},
    this.favoriteCategories = const [],
    this.budgetAlertThreshold = 0.8,
  });

  UserPreferencesModel copyWith({
    String? theme,
    String? language,
    String? currency,
    bool? enableNotifications,
    bool? enableBiometric,
    bool? enableBackup,
    bool? enableAnalytics,
    String? dateFormat,
    String? timeFormat,
    Map<String, bool>? categoryVisibility,
    Map<String, dynamic>? dashboardLayout,
    List<String>? favoriteCategories,
    double? budgetAlertThreshold,
  }) {
    return UserPreferencesModel(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableBiometric: enableBiometric ?? this.enableBiometric,
      enableBackup: enableBackup ?? this.enableBackup,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      categoryVisibility: categoryVisibility ?? this.categoryVisibility,
      dashboardLayout: dashboardLayout ?? this.dashboardLayout,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      budgetAlertThreshold: budgetAlertThreshold ?? this.budgetAlertThreshold,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'language': language,
      'currency': currency,
      'enableNotifications': enableNotifications ? 1 : 0,
      'enableBiometric': enableBiometric ? 1 : 0,
      'enableBackup': enableBackup ? 1 : 0,
      'enableAnalytics': enableAnalytics ? 1 : 0,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'categoryVisibility': jsonEncode(categoryVisibility),
      'dashboardLayout': jsonEncode(dashboardLayout),
      'favoriteCategories': jsonEncode(favoriteCategories),
      'budgetAlertThreshold': budgetAlertThreshold,
    };
  }

  factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel(
      theme: map['theme'] ?? 'system',
      language: map['language'] ?? 'en',
      currency: map['currency'] ?? 'USD',
      enableNotifications: map['enableNotifications'] == 1,
      enableBiometric: map['enableBiometric'] == 1,
      enableBackup: map['enableBackup'] == 1,
      enableAnalytics: map['enableAnalytics'] == 1,
      dateFormat: map['dateFormat'] ?? 'MM/dd/yyyy',
      timeFormat: map['timeFormat'] ?? '12h',
      categoryVisibility: map['categoryVisibility'] != null
          ? Map<String, bool>.from(jsonDecode(map['categoryVisibility']))
          : {},
      dashboardLayout: map['dashboardLayout'] != null
          ? Map<String, dynamic>.from(jsonDecode(map['dashboardLayout']))
          : {},
      favoriteCategories: map['favoriteCategories'] != null
          ? List<String>.from(jsonDecode(map['favoriteCategories']))
          : [],
      budgetAlertThreshold: map['budgetAlertThreshold']?.toDouble() ?? 0.8,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserPreferencesModel.fromJson(String source) =>
      UserPreferencesModel.fromMap(jsonDecode(source));

  @override
  String toString() {
    return 'UserPreferencesModel(theme: $theme, language: $language, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferencesModel &&
        other.theme == theme &&
        other.language == language &&
        other.currency == currency;
  }

  @override
  int get hashCode => theme.hashCode ^ language.hashCode ^ currency.hashCode;
}