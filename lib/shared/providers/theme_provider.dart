import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeModeKey = 'app_theme_mode';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? modeStr = prefs.getString(_themeModeKey);
    if (modeStr != null) {
      if (modeStr == ThemeMode.light.name) {
        state = ThemeMode.light;
      } else if (modeStr == ThemeMode.dark.name) {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }
}

final StateNotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
