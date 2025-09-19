import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_notes/theme/theme_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';
  static const String _customColorsKey = 'custom_colors';

  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = AppTheme.defaultColors['purple']!;
  Map<String, Color> _customColors = {};

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  Map<String, Color> get availableColors => {...AppTheme.defaultColors, ..._customColors};

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeString = prefs.getString(_themeModeKey);
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
            (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }

    final colorValue = prefs.getInt(_primaryColorKey);
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }

    final customColorsJson = prefs.getString(_customColorsKey);
    if (customColorsJson != null) {
      final Map<String, dynamic> decoded = json.decode(customColorsJson);
      _customColors = decoded.map((key, value) => MapEntry(key, Color(value as int)));
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString());
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
  }

  Future<void> addCustomColor(String name, Color color) async {
    _customColors[name] = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(
        _customColors.map((key, value) => MapEntry(key, value.value))
    );
    await prefs.setString(_customColorsKey, encoded);
  }

  void toggleTheme() {
    setThemeMode(
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light
    );
  }
}