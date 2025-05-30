library;

import 'package:flutter/material.dart';

part './light.dart';
part './dark.dart';
part './gradient.dart';

class AppTheme {
  LinearGradient shimmerGradient(bool isDarkTheme) =>
      isDarkTheme ? darkGradient : lightGradient;
}
