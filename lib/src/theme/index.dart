library;

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

part './light.dart';
part './dark.dart';
part './gradient.dart';

@lazySingleton
class AppTheme {
  LinearGradient shimmerGradient(bool isDarkTheme) =>
      isDarkTheme ? darkGradient : lightGradient;
}
