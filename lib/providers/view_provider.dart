import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:shared_preferences/shared_preferences.dart';

class GridListView extends _View {
  int get crossAxis => isTrue ? 2 : 1;
  double get aspectRatio => isTrue ? 17 / 20 : 9 / 4;
}

abstract class _View with ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _default = false;
  static const _key = 'view';

  Future<void> initialize() async {
    try {
      final prefs = await _prefs;
      _default = prefs.getBool(_key) ?? false;
      print('stored: $_default');
    } catch (e) {
      print(e);
    }
  }

  void toggle() => _toggler(!_default);

  void toggleValue(bool newVal) => _toggler(newVal);

  void _toggler(bool newVal) async {
    _default = newVal;
    notifyListeners();
    try {
      final prefs = await _prefs;
      await prefs.setBool(_key, _default);
    } catch (e) {
      print(e);
    }
  }

  bool get isTrue => _default;
}
