import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/torrent_service_models.dart';
import 'package:ytsmovies/src/services/torrent_task_handler.dart';
import 'package:ytsmovies/src/services/preferences_service.dart';
import 'package:ytsmovies/src/utils/storage_permission.dart';

/// Service to manage foreground torrent downloads
@singleton
class ForegroundDownloadService {
  final PreferencesService _preferencesService;

  ForegroundDownloadService(this._preferencesService);

  bool _isInitialized = false;
  String? _downloadPath;
  final StreamController<ProgressUpdate> _progressController =
      StreamController<ProgressUpdate>.broadcast();

  Stream<ProgressUpdate> get progressStream => _progressController.stream;

  /// Resolved download directory. Always app-scoped (no MANAGE_EXTERNAL_STORAGE
  /// required) unless the user picked a custom path via SAF.
  /// Callers must await [initialize] before reading.
  String get downloadPath {
    final p = _downloadPath;
    if (p == null) {
      throw StateError('ForegroundDownloadService not initialized');
    }
    return p;
  }

  @postConstruct
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initDownloadPath();
    await _requestPermissions();

    final notificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'Torrent Downloads',
      description: 'Shows progress for active torrent downloads',
      importance: Importance.low,
    );
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStartBackgroundService,
        onBackground: _onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStartBackgroundService,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'YTS Movies',
        initialNotificationContent: 'Torrent download service running',
        foregroundServiceNotificationId: notificationId,
      ),
    );

    service.on('progressUpdate').listen((event) {
      if (event == null) return;
      try {
        _progressController.add(ProgressUpdate.fromJson(event));
      } catch (e) {
        log('Error parsing progress update: $e');
      }
    });

    _isInitialized = true;
  }

  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async => true;

  /// Resolves the default save location:
  ///   Android  -> /storage/emulated/0/Download/Movies (public Downloads,
  ///              matches Chrome / 1DM / ADM). Requires
  ///              MANAGE_EXTERNAL_STORAGE; the directory is created lazily
  ///              once the user grants it at the first download attempt.
  ///   iOS      -> app documents/Downloads/Movies (no public Downloads on iOS)
  /// A user-picked [customDownloadPath] from preferences always wins.
  Future<void> _initDownloadPath() async {
    try {
      final customPath = _preferencesService.customDownloadPath;
      if (customPath != null && await Directory(customPath).exists()) {
        _downloadPath = customPath;
        return;
      }
      _downloadPath = await _defaultPath();
      // Don't create directory here — requires storage permission on Android
      // and we don't want to prompt at app startup. Created on first write
      // (see `ensureSavePathExists`).
    } catch (e, s) {
      log('Error initializing download path: $e', error: e, stackTrace: s);
      final appDir = await getApplicationDocumentsDirectory();
      _downloadPath = '${appDir.path}/downloads';
      await Directory(_downloadPath!).create(recursive: true);
    }
  }

  Future<String> _defaultPath() async {
    if (Platform.isAndroid) {
      return '$kAndroidPublicDownloadsRoot/$kDefaultDownloadSubdir';
    }
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/Downloads/$kDefaultDownloadSubdir';
  }

  /// Creates the save directory if missing. Must be called after the user
  /// has granted MANAGE_EXTERNAL_STORAGE (Android 11+) — see
  /// [ensurePublicStorageWrite].
  Future<void> ensureSavePathExists() async {
    final p = _downloadPath;
    if (p == null) return;
    final dir = Directory(p);
    if (!await dir.exists()) await dir.create(recursive: true);
  }

  Future<void> updateDownloadPath(String newPath) async {
    final dir = Directory(newPath);
    if (!await dir.exists()) await dir.create(recursive: true);
    await _preferencesService.setCustomDownloadPath(newPath);
    _downloadPath = newPath;
  }

  Future<void> resetToDefaultPath() async {
    await _preferencesService.setCustomDownloadPath(null);
    _downloadPath = await _defaultPath();
    // Directory created lazily on first write — see [ensureSavePathExists].
  }

  /// Only POST_NOTIFICATIONS is required at runtime — the foreground service
  /// notification channel needs it on Android 13+. Downloads write to
  /// app-scoped external storage (no storage perm) or to a SAF-granted
  /// directory chosen by the user (perm is the URI grant itself).
  Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  Future<bool> checkPermissions() async {
    try {
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        if (!status.isGranted) return false;
      }
      return true;
    } catch (e, s) {
      log('Error checking permissions: $e', error: e, stackTrace: s);
      return false;
    }
  }

  Future<bool> startService() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) return true;
    if (!await checkPermissions()) return false;
    await service.startService();
    return true;
  }

  Future<void> startDownload({
    required int taskId,
    required String magnetUri,
    required String savePath,
    required String movieTitle,
    int? downloadLimit,
    int? uploadLimit,
    List<int>? selectedIndices,
    bool previewMode = false,
  }) async {
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) {
      final started = await startService();
      if (!started) {
        throw Exception(
          'Failed to start foreground service. Please grant notification '
          'and storage permissions in app settings.',
        );
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    service.invoke(
      'startDownload',
      StartDownloadRequest(
        taskId: taskId,
        magnetUri: magnetUri,
        savePath: savePath,
        movieTitle: movieTitle,
        initialDownloadLimit:
            downloadLimit ?? _preferencesService.globalDownloadLimit,
        initialUploadLimit:
            uploadLimit ?? _preferencesService.globalUploadLimit,
        selectedIndices: selectedIndices,
        previewMode: previewMode,
      ).toJson(),
    );
  }

  Future<void> pauseDownload(int taskId) async {
    FlutterBackgroundService().invoke(
      'pauseDownload',
      DownloadControlRequest(taskId: taskId).toJson(),
    );
  }

  Future<void> resumeDownload(int taskId) async {
    FlutterBackgroundService().invoke(
      'resumeDownload',
      DownloadControlRequest(taskId: taskId).toJson(),
    );
  }

  Future<void> stopDownload(int taskId) async {
    FlutterBackgroundService().invoke(
      'stopDownload',
      DownloadControlRequest(taskId: taskId).toJson(),
    );
  }

  /// libtorrent_flutter exposes only session-wide limits. The handler applies
  /// the most-recent request across all tasks; the per-task field is kept for
  /// UI display but the cap is effectively global.
  Future<void> setSpeedLimit({
    required int taskId,
    int? downloadLimit,
    int? uploadLimit,
  }) async {
    FlutterBackgroundService().invoke(
      'setSpeedLimit',
      SetSpeedLimitRequest(
        taskId: taskId,
        downloadLimit: downloadLimit,
        uploadLimit: uploadLimit,
      ).toJson(),
    );
  }

  Future<void> setFilePriority({
    required int taskId,
    required int fileIndex,
    required FilePriorityLevel priority,
  }) async {
    FlutterBackgroundService().invoke(
      'setFilePriority',
      SetFilePriorityRequest(
        taskId: taskId,
        fileIndex: fileIndex,
        priority: priority,
      ).toJson(),
    );
  }

  Future<void> applyFileSelection({
    required int taskId,
    required List<int> selectedIndices,
  }) async {
    FlutterBackgroundService().invoke(
      'applyFileSelection',
      ApplyFileSelectionRequest(
        taskId: taskId,
        selectedIndices: selectedIndices,
      ).toJson(),
    );
  }

  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) service.invoke('stopService');
  }

  Future<bool> isServiceRunning() async {
    return await FlutterBackgroundService().isRunning();
  }

  Future<void> dispose() async {
    await _progressController.close();
    _isInitialized = false;
  }
}
