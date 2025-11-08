import 'dart:developer';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Service for managing app preferences and settings
class PreferencesService {
  static const String _boxName = 'app_preferences';
  static const String _downloadPathKey = 'download_path';

  static PreferencesService? _instance;
  static PreferencesService get instance => _instance!;

  late Box _box;

  PreferencesService._();

  /// Initialize the preferences service
  static Future<PreferencesService> initialize() async {
    if (_instance != null) return _instance!;

    final service = PreferencesService._();
    await service._initBox();
    _instance = service;
    return service;
  }

  Future<void> _initBox() async {
    try {
      _box = await Hive.openBox(_boxName);
      log('Preferences box opened successfully');
    } catch (e, s) {
      log('Error opening preferences box: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Get the custom download path set by user
  String? get customDownloadPath {
    return _box.get(_downloadPathKey) as String?;
  }

  /// Set custom download path
  Future<void> setCustomDownloadPath(String? path) async {
    try {
      if (path == null) {
        await _box.delete(_downloadPathKey);
      } else {
        await _box.put(_downloadPathKey, path);
      }
      log('Download path updated: $path');
    } catch (e, s) {
      log('Error setting download path: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Clear all preferences
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Close the preferences box
  Future<void> close() async {
    await _box.close();
  }
}
