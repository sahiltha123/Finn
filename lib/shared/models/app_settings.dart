class AppSettings {
  const AppSettings({
    required this.darkMode,
    required this.notificationsEnabled,
    required this.biometricLock,
    required this.weeklyReminderDay,
    required this.dailyReminderTime,
  });

  final bool darkMode;
  final bool notificationsEnabled;
  final bool biometricLock;
  final int weeklyReminderDay;
  final String dailyReminderTime;

  AppSettings copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    bool? biometricLock,
    int? weeklyReminderDay,
    String? dailyReminderTime,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricLock: biometricLock ?? this.biometricLock,
      weeklyReminderDay: weeklyReminderDay ?? this.weeklyReminderDay,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'darkMode': darkMode,
      'notificationsEnabled': notificationsEnabled,
      'biometricLock': biometricLock,
      'weeklyReminderDay': weeklyReminderDay,
      'dailyReminderTime': dailyReminderTime,
    };
  }

  factory AppSettings.fromMap(Map<String, Object?> map) {
    return AppSettings(
      darkMode: map['darkMode'] as bool? ?? false,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      biometricLock: map['biometricLock'] as bool? ?? false,
      weeklyReminderDay: (map['weeklyReminderDay'] as num?)?.toInt() ?? 1,
      dailyReminderTime: map['dailyReminderTime'] as String? ?? '20:00',
    );
  }

  static const defaults = AppSettings(
    darkMode: false,
    notificationsEnabled: true,
    biometricLock: false,
    weeklyReminderDay: 1,
    dailyReminderTime: '20:00',
  );
}
