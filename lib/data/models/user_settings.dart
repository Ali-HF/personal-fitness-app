class UserSettings {
  final String planVariant; // JAN_3, JAN_17, JAN_24
  final String raceDate; // YYYY-MM-DD
  final String finalsStart; // YYYY-MM-DD
  final String finalsEnd; // YYYY-MM-DD
  final String units; // metric, imperial
  final String themeMode; // system, light, dark
  final bool reminderSundayExport;
  final bool reminderMorning;
  final String? test5kTime; // MM:SS or formatted time if completed

  const UserSettings({
    this.planVariant = 'JAN_3',
    this.raceDate = '2027-01-03',
    this.finalsStart = '2026-12-01',
    this.finalsEnd = '2026-12-15',
    this.units = 'metric',
    this.themeMode = 'system',
    this.reminderSundayExport = true,
    this.reminderMorning = false,
    this.test5kTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'plan_variant': planVariant,
      'race_date': raceDate,
      'finals_start': finalsStart,
      'finals_end': finalsEnd,
      'units': units,
      'theme_mode': themeMode,
      'reminder_sunday_export': reminderSundayExport ? 1 : 0,
      'reminder_morning': reminderMorning ? 1 : 0,
      'test_5k_time': test5kTime,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      planVariant: map['plan_variant'] as String? ?? 'JAN_3',
      raceDate: map['race_date'] as String? ?? '2027-01-03',
      finalsStart: map['finals_start'] as String? ?? '2026-12-01',
      finalsEnd: map['finals_end'] as String? ?? '2026-12-15',
      units: map['units'] as String? ?? 'metric',
      themeMode: map['theme_mode'] as String? ?? 'system',
      reminderSundayExport: (map['reminder_sunday_export'] as int? ?? 1) == 1,
      reminderMorning: (map['reminder_morning'] as int? ?? 0) == 1,
      test5kTime: map['test_5k_time'] as String?,
    );
  }

  UserSettings copyWith({
    String? planVariant,
    String? raceDate,
    String? finalsStart,
    String? finalsEnd,
    String? units,
    String? themeMode,
    bool? reminderSundayExport,
    bool? reminderMorning,
    String? test5kTime,
  }) {
    return UserSettings(
      planVariant: planVariant ?? this.planVariant,
      raceDate: raceDate ?? this.raceDate,
      finalsStart: finalsStart ?? this.finalsStart,
      finalsEnd: finalsEnd ?? this.finalsEnd,
      units: units ?? this.units,
      themeMode: themeMode ?? this.themeMode,
      reminderSundayExport: reminderSundayExport ?? this.reminderSundayExport,
      reminderMorning: reminderMorning ?? this.reminderMorning,
      test5kTime: test5kTime ?? this.test5kTime,
    );
  }
}
