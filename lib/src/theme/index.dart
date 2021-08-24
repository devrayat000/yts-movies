library app_theme;

import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

part './light.dart';
part './dark.dart';
part './gradient.dart';

class AppTheme {
  LinearGradient shimmerGradient(bool _isDarkTheme) =>
      _isDarkTheme ? darkGradient : lightGradient;
}
