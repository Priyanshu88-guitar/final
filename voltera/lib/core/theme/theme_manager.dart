import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  ThemeMode get themeMode => ThemeMode.light;

  void setThemeMode(ThemeMode mode) {
    // Application is locked to VOLTERA light theme
  }

  bool isDarkMode(BuildContext context) => false;
}
