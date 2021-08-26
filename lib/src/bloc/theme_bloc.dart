import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ytsmovies/src/theme/index.dart';

class ThemeCubit extends HydratedCubit<ThemeData> {
  final AppTheme theme;
  ThemeCubit({required this.theme}) : super(theme.light);

  void sync(Brightness mode) {
    if (mode != Brightness.dark) {
      this.emit(this.theme.dark);
    }
  }

  void toggle() {
    this.emit(
        this.state.brightness == Brightness.dark ? theme.light : theme.dark);
  }

  @override
  ThemeData? fromJson(Map<String, dynamic> json) {
    final isDark = json['value'] as bool;
    return isDark ? theme.dark : theme.light;
  }

  @override
  Map<String, dynamic>? toJson(ThemeData state) {
    final json = state.brightness == Brightness.dark ? true : false;
    return {'value': json};
  }
}
