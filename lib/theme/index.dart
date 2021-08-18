import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

part './light.dart';
part './dark.dart';
part './gradient.dart';

class AppTheme with ChangeNotifier {
  static bool _isDarkTheme = true;
  late ThemeMode _mode = ThemeMode.system;
  // static const _themeKey = 'theme-mode-key';

  ThemeMode get current => _mode;

  set themeMode(ThemeMode mode) {
    _isDarkTheme = mode == ThemeMode.dark;
    _mode = mode;
  }

  bool get isDark => _isDarkTheme;

  LinearGradient get shimmerGradient =>
      _isDarkTheme ? darkGradient : lightGradient;
}
