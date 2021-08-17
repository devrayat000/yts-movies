import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ytsmovies/theme/index.dart';

class ThemeBloc extends HydratedBloc<ThemeMode, ThemeData> {
  ThemeBloc(ThemeData state) : super(state);

  @override
  Stream<ThemeData> mapEventToState(ThemeMode event) async* {
    switch (event) {
      case ThemeMode.light:
        yield LightTheme.light;
        break;
      case ThemeMode.dark:
        yield DarkTheme.dark;
        break;
      default:
        yield state;
    }
  }

  void toggle() {
    this.add(this.state == DarkTheme.dark ? ThemeMode.light : ThemeMode.dark);
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
