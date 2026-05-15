import 'dart:developer';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

/// Service for managing app preferences and settings
@singleton
class PreferencesService {
  static const String _boxName = 'app_preferences';
  static const String _downloadPathKey = 'download_path';
  static const String _globalDownloadLimitKey = 'global_download_limit';
  static const String _globalUploadLimitKey = 'global_upload_limit';
  static const String _maxConcurrentDownloadsKey = 'max_concurrent_downloads';
  static const String _defaultTrackersKey = 'default_trackers';

  late Box _box;

  PreferencesService();

  @postConstruct
  Future<void> initialize() async {
    await _initBox();
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

  String? get customDownloadPath => _box.get(_downloadPathKey) as String?;

  Future<void> setCustomDownloadPath(String? path) async {
    if (path == null) {
      await _box.delete(_downloadPathKey);
    } else {
      await _box.put(_downloadPathKey, path);
    }
  }

  /// Global download speed limit in bytes/sec (null = unlimited)
  int? get globalDownloadLimit => _box.get(_globalDownloadLimitKey) as int?;

  Future<void> setGlobalDownloadLimit(int? bytesPerSecond) async {
    if (bytesPerSecond == null) {
      await _box.delete(_globalDownloadLimitKey);
    } else {
      await _box.put(_globalDownloadLimitKey, bytesPerSecond);
    }
  }

  /// Global upload speed limit in bytes/sec (null = unlimited)
  int? get globalUploadLimit => _box.get(_globalUploadLimitKey) as int?;

  Future<void> setGlobalUploadLimit(int? bytesPerSecond) async {
    if (bytesPerSecond == null) {
      await _box.delete(_globalUploadLimitKey);
    } else {
      await _box.put(_globalUploadLimitKey, bytesPerSecond);
    }
  }

  /// Max concurrent downloads (default 3)
  int get maxConcurrentDownloads =>
      (_box.get(_maxConcurrentDownloadsKey) as int?) ?? 3;

  Future<void> setMaxConcurrentDownloads(int value) async {
    await _box.put(_maxConcurrentDownloadsKey, value.clamp(1, 10));
  }

  /// User-supplied default trackers applied to every new download
  List<String> get defaultTrackers {
    final raw = _box.get(_defaultTrackersKey);
    if (raw is List) {
      return raw.cast<String>();
    }
    return const <String>[];
  }

  Future<void> setDefaultTrackers(List<String> trackers) async {
    await _box.put(_defaultTrackersKey, trackers);
  }

  Future<void> addDefaultTracker(String url) async {
    final current = List<String>.from(defaultTrackers);
    if (!current.contains(url)) {
      current.add(url);
      await setDefaultTrackers(current);
    }
  }

  Future<void> removeDefaultTracker(String url) async {
    final current = List<String>.from(defaultTrackers)..remove(url);
    await setDefaultTrackers(current);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  Future<void> close() async {
    await _box.close();
  }
}
