import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ytsmovies/theme/index.dart';

class ThemeCubit extends HydratedCubit<ThemeData> {
  ThemeCubit(ThemeData _initialState) : super(_initialState);

  void toggle() {
    this.emit(this.state.brightness == Brightness.dark
        ? LightTheme.light
        : DarkTheme.dark);
  }

  @override
  ThemeData? fromJson(Map<String, dynamic> json) {
    final isDark = json['value'] as bool;
    return isDark ? DarkTheme.dark : LightTheme.light;
  }

  @override
  Map<String, dynamic>? toJson(ThemeData state) {
    final json = state.brightness == Brightness.dark ? true : false;
    return {'value': json};
  }
}
