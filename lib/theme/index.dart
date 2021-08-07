import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part './light.dart';
part './dark.dart';
part './gradient.dart';

class AppTheme with ChangeNotifier {
  static bool _isDarkTheme = true;
  late ThemeMode _mode = ThemeMode.system;
  static const _themeKey = 'theme-mode-key';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  ThemeMode get current => _mode;

  set themeMode(ThemeMode mode) {
    _isDarkTheme = mode == ThemeMode.dark;
    _mode = mode;
  }

  bool get isDark => _isDarkTheme;

  Future<ThemeMode?> get storedTheme async {
    try {
      final prefs = await _prefs;
      return prefs.getTheme(_themeKey);
    } catch (e) {
      throw e;
    }
  }

  void toggleTheme() async {
    if (_isDarkTheme) {
      _mode = ThemeMode.light;
    } else {
      _mode = ThemeMode.dark;
    }
    notifyListeners();
    _isDarkTheme = !_isDarkTheme;
    try {
      final prefs = await _prefs;
      await prefs.setTheme(_themeKey, current);
    } catch (e) {
      print(e);
    }
  }

  LinearGradient get shimmerGradient =>
      _isDarkTheme ? darkGradient : lightGradient;
}

extension ThemeModeStoring on SharedPreferences {
  Future<bool> setTheme(String key, ThemeMode value) async {
    try {
      await this.setString(key, value.toString());
      return true;
    } catch (e) {
      return false;
    }
  }

  ThemeMode? getTheme(String key) {
    final mode = this.getString(key);
    return _parseMode(mode);
  }

  ThemeMode? _parseMode(String? value) {
    switch (value) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      default:
        return null;
    }
  }
}
