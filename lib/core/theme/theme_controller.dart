import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier(ThemeMode.light);

  static const String _themeKey = 'theme_mode';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool(_themeKey) ?? false;

    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggle() async {
    final newMode = mode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    mode.value = newMode;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _themeKey,
      newMode == ThemeMode.dark,
    );
  }
}