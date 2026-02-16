class UserPreferences {
  final bool darkMode;
  final bool notificationsEnabled;
  final String languageCode;

  UserPreferences({
    this.darkMode = true,
    this.notificationsEnabled = true,
    this.languageCode = 'en',
  });

  UserPreferences copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    String? languageCode,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toMap() => {
        'darkMode': darkMode,
        'notificationsEnabled': notificationsEnabled,
        'languageCode': languageCode,
      };

  factory UserPreferences.fromMap(Map<String, dynamic> map) => UserPreferences(
        darkMode: map['darkMode'] ?? true,
        notificationsEnabled: map['notificationsEnabled'] ?? true,
        languageCode: map['languageCode'] ?? 'en',
      );
}
