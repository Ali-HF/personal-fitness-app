import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/models/user_settings.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(const UserSettings()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final settings = await DatabaseHelper.instance.getSettings();
    state = settings;
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    state = newSettings;
    await DatabaseHelper.instance.saveSettings(newSettings);
  }

  Future<void> setPlanVariant(String variant) async {
    final updated = state.copyWith(planVariant: variant);
    await updateSettings(updated);
  }

  Future<void> setRaceDate(String raceDate) async {
    final updated = state.copyWith(raceDate: raceDate);
    await updateSettings(updated);
  }

  Future<void> setFinalsDates(String start, String end) async {
    final updated = state.copyWith(finalsStart: start, finalsEnd: end);
    await updateSettings(updated);
  }

  Future<void> setThemeMode(String themeMode) async {
    final updated = state.copyWith(themeMode: themeMode);
    await updateSettings(updated);
  }

  Future<void> setUnits(String units) async {
    final updated = state.copyWith(units: units);
    await updateSettings(updated);
  }

  Future<void> setReminderSundayExport(bool value) async {
    final updated = state.copyWith(reminderSundayExport: value);
    await updateSettings(updated);
  }

  Future<void> setReminderMorning(bool value) async {
    final updated = state.copyWith(reminderMorning: value);
    await updateSettings(updated);
  }

  Future<void> setTest5kTime(String time) async {
    final updated = state.copyWith(test5kTime: time);
    await updateSettings(updated);
  }

  ThemeMode get currentThemeMode {
    switch (state.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

