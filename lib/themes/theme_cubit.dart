import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls whether the app uses the light or dark theme.
///
/// The choice is cached locally so the correct theme is shown immediately
/// on startup, and is also synced from the user's Firestore settings on login.
class ThemeCubit extends Cubit<ThemeMode> {
  static const _prefsKey = 'darkMode';

  ThemeCubit() : super(ThemeMode.light);

  bool get isDarkMode => state == ThemeMode.dark;

  /// Load the locally cached preference (call before runApp).
  Future<void> loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_prefsKey) ?? false;
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    } catch (_) {
      // Keep the default light theme if local storage is unavailable.
    }
  }

  /// Switch theme and cache the choice locally.
  Future<void> setDarkMode(bool isDark) async {
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, isDark);
    } catch (_) {
      // Theme still changes for this session even if caching fails.
    }
  }
}
