import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme with ChangeNotifier {
  static bool _isDarkTheme = true;
  late ThemeMode _mode;
  static const _key = 'theme-mode';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  ThemeMode get current => _mode;
  set _current(ThemeMode mode) => _mode = mode;

  bool get isDark => _isDarkTheme;

  Future<void> initialize() async {
    try {
      final prefs = await _prefs;
      final _boolPref = prefs.getBool(_key);
      if (_boolPref == null) {
        _current = ThemeMode.system;
        _isDarkTheme = ThemeMode.system == ThemeMode.dark;
      } else {
        _current = _boolPref == false ? ThemeMode.light : ThemeMode.dark;
        _isDarkTheme = _boolPref;
      }
      print('theme: $current');
    } catch (e) {
      print(e);
    }
  }

  void toggleTheme() async {
    if (_isDarkTheme) {
      _current = ThemeMode.light;
    } else {
      _current = ThemeMode.dark;
    }
    notifyListeners();
    _isDarkTheme = !_isDarkTheme;
    try {
      final prefs = await _prefs;
      await prefs.setBool(_key, _isDarkTheme);
    } catch (e) {
      print(e);
    }
  }

  static ThemeData get light {
    final _light = ThemeData.light();
    final _text = _light.textTheme;
    final _appbar = _light.appBarTheme;
    final _input = _light.inputDecorationTheme;
    final _fab = _light.floatingActionButtonTheme;
    final _colorScheme = ColorScheme.light();

    return _light.copyWith(
      canvasColor: Colors.grey[50],
      appBarTheme: _appbar.copyWith(
        backgroundColor: Colors.grey[50],
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(color: Colors.grey.shade900),
      ),
      backgroundColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: _colorScheme.copyWith(
        onSurface: Colors.black,
        surface: Colors.black87,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.black87,
        colorScheme: _colorScheme,
      ),
      textTheme: TextTheme(
        headline1: _text.headline1?.copyWith(
          color: Colors.grey.shade900,
        ),
        headline2: _text.headline2?.copyWith(
          color: Colors.grey.shade900,
        ),
        headline3: _text.headline3?.copyWith(
          color: Colors.grey.shade900,
        ),
        headline4: _text.headline4?.copyWith(
          color: Colors.grey.shade900,
        ),
        headline5: _text.headline5?.copyWith(
          color: Colors.black,
        ),
        headline6: _text.headline6?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        subtitle1: _text.subtitle1?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        subtitle2: _text.subtitle2?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
      ),
      inputDecorationTheme: _input.copyWith(
        hintStyle: _input.hintStyle?.copyWith(
          color: Colors.black87,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(999.0),
          ),
          borderSide: BorderSide.none,
          // gapPadding: 10.0,
        ),
        fillColor: Colors.grey[100],
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      ),
      floatingActionButtonTheme: _fab.copyWith(
        backgroundColor: Colors.cyanAccent[700],
        foregroundColor: Colors.grey[50],
      ),
    );
  }

  static ThemeData get dark {
    final _dark = ThemeData.dark();
    final _text = _dark.textTheme;
    final _appbar = _dark.appBarTheme;
    final _input = _dark.inputDecorationTheme;
    final _fab = _dark.floatingActionButtonTheme;
    final _colorScheme = ColorScheme.dark();

    return _dark.copyWith(
      canvasColor: Colors.blueGrey[900],
      cardColor: Colors.blueGrey[700],
      appBarTheme: _appbar.copyWith(
        backgroundColor: Colors.blueGrey[900],
        iconTheme: IconThemeData(color: Colors.grey[100]),
      ),
      backgroundColor: Colors.blueGrey[900],
      scaffoldBackgroundColor: Colors.blueGrey[800],
      colorScheme: _colorScheme.copyWith(
        onSurface: Colors.white,
        surface: Colors.white70,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.black87,
        colorScheme: _colorScheme,
      ),
      textTheme: TextTheme(
        headline1: _text.headline1?.copyWith(
          color: Colors.white,
        ),
        headline2: _text.headline2?.copyWith(
          color: Colors.white,
        ),
        headline3: _text.headline3?.copyWith(
          color: Colors.white,
        ),
        headline4: _text.headline4?.copyWith(
          color: Colors.white,
        ),
        headline5: _text.headline5?.copyWith(
          color: Colors.white,
        ),
        headline6: _text.headline6?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.normal,
        ),
        subtitle1: _text.subtitle1?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
        subtitle2: _text.subtitle2?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
      inputDecorationTheme: _input.copyWith(
        hintStyle: _input.hintStyle?.copyWith(
          color: Colors.blueGrey[50],
          fontStyle: FontStyle.italic,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(999.0),
          ),
          borderSide: BorderSide.none,
          // gapPadding: 10.0,
        ),
        fillColor: Colors.blueGrey[900],
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      ),
      floatingActionButtonTheme: _fab.copyWith(
        backgroundColor: Colors.tealAccent[700],
        foregroundColor: Colors.grey[900],
      ),
    );
  }

  final _lightGradient = const LinearGradient(
    colors: [
      Color(0xFFEBEBF4),
      Color(0xFFF4F4F4),
      Color(0xFFEBEBF4),
    ],
    stops: [
      0.1,
      0.3,
      0.4,
    ],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    tileMode: TileMode.clamp,
  );
  final _darkGradient = LinearGradient(
    colors: [
      Colors.blueGrey.shade700,
      Colors.blueGrey.shade600,
      Colors.blueGrey.shade700,
    ],
    stops: const [
      0.1,
      0.3,
      0.4,
    ],
    begin: const Alignment(-1.0, -0.3),
    end: const Alignment(1.0, 0.3),
    tileMode: TileMode.clamp,
  );

  LinearGradient get shimmerGradient =>
      _isDarkTheme ? _darkGradient : _lightGradient;
}
