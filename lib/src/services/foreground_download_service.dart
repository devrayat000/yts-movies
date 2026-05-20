import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/foundation.dart';
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

const String _logTag = 'FDS';

void _d(String msg, {Object? error, StackTrace? stack}) {
  // ignore: avoid_print
  debugPrint('[$_logTag] $msg');
  dev.log(msg, name: _logTag, error: error, stackTrace: stack);
}

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
    _d('initialize: enter (alreadyInit=$_isInitialized)');
    if (_isInitialized) return;

    await _initDownloadPath();
    _d('initialize: downloadPath=$_downloadPath');
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
    _d('initialize: notification channel created');

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
    _d('initialize: FlutterBackgroundService configured');

    service.on('progressUpdate').listen((event) {
      if (event == null) {
        _d('progressUpdate: null event, ignoring');
        return;
      }
      try {
        final update = ProgressUpdate.fromJson(event);
        _d('progressUpdate<- task=${update.taskId}, status=${update.status}, '
            'progress=${(update.progress * 100).toStringAsFixed(1)}%, '
            'dl=${update.downloadSpeed}, ul=${update.uploadSpeed}, '
            'done=${update.downloadedBytes}/${update.totalBytes}, '
            'files=${update.files?.length}, err=${update.error}');
        _progressController.add(update);
      } catch (e, s) {
        _d('progressUpdate parse error: $e', error: e, stack: s);
      }
    });

    _isInitialized = true;
    _d('initialize: done');
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
      _d('_initDownloadPath failed: $e', error: e, stack: s);
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
    _d('updateDownloadPath: $_downloadPath');
  }

  Future<void> resetToDefaultPath() async {
    await _preferencesService.setCustomDownloadPath(null);
    _downloadPath = await _defaultPath();
    _d('resetToDefaultPath: $_downloadPath');
  }

  /// Only POST_NOTIFICATIONS is required at runtime — the foreground service
  /// notification channel needs it on Android 13+. Downloads write to
  /// app-scoped external storage (no storage perm) or to a SAF-granted
  /// directory chosen by the user (perm is the URI grant itself).
  Future<void> _requestPermissions() async {
    final status = await Permission.notification.request();
    _d('_requestPermissions: notification=$status');
  }

  Future<bool> checkPermissions() async {
    try {
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        _d('checkPermissions: notification re-request -> $status');
        if (!status.isGranted) return false;
      }
      return true;
    } catch (e, s) {
      _d('checkPermissions error: $e', error: e, stack: s);
      return false;
    }
  }

  Future<bool> startService() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      _d('startService: already running');
      return true;
    }
    if (!await checkPermissions()) {
      _d('startService: permission denied');
      return false;
    }
    _d('startService: starting…');
    final ok = await service.startService();
    _d('startService: startService() returned $ok');
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
    _d('startDownload: taskId=$taskId, savePath=$savePath, '
        'movieTitle="$movieTitle", magnet="${_truncMagnet(magnetUri)}", '
        'dl=$downloadLimit, ul=$uploadLimit, sel=$selectedIndices, '
        'preview=$previewMode');
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) {
      _d('startDownload: service not running, starting');
      final started = await startService();
      if (!started) {
        _d('startDownload: startService failed');
        throw Exception(
          'Failed to start foreground service. Please grant notification '
          'and storage permissions in app settings.',
        );
      }
      _d('startDownload: waiting 500ms for service spin-up');
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final req = StartDownloadRequest(
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
    );
    _d('startDownload-> invoke "startDownload" json keys=${req.toJson().keys.toList()}');
    service.invoke('startDownload', req.toJson());
  }

  Future<void> pauseDownload(int taskId) async {
    _d('pauseDownload-> taskId=$taskId');
    FlutterBackgroundService().invoke(
      'pauseDownload',
      DownloadControlRequest(taskId: taskId).toJson(),
    );
  }

  Future<void> resumeDownload(int taskId) async {
    _d('resumeDownload-> taskId=$taskId');
    FlutterBackgroundService().invoke(
      'resumeDownload',
      DownloadControlRequest(taskId: taskId).toJson(),
    );
  }

  Future<void> stopDownload(int taskId) async {
    _d('stopDownload-> taskId=$taskId');
    FlutterBackgroundService().invoke(
      'stopDownload',
      DownloadControlRequest(taskId: taskId).toJson(),
    );
  }

  /// Drop the torrent and let libtorrent wipe its on-disk files.
  Future<void> deleteDownload(int taskId) async {
    _d('deleteDownload-> taskId=$taskId');
    FlutterBackgroundService().invoke(
      'deleteDownload',
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
    _d('setSpeedLimit-> taskId=$taskId, dl=$downloadLimit, ul=$uploadLimit');
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
    _d('setFilePriority-> taskId=$taskId, file=$fileIndex, prio=$priority');
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
    _d('applyFileSelection-> taskId=$taskId, selected=$selectedIndices');
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
    if (await service.isRunning()) {
      _d('stopService-> invoking');
      service.invoke('stopService');
    } else {
      _d('stopService: not running');
    }
  }

  Future<bool> isServiceRunning() async {
    return await FlutterBackgroundService().isRunning();
  }

  Future<void> dispose() async {
    _d('dispose');
    await _progressController.close();
    _isInitialized = false;
  }

  String _truncMagnet(String m) =>
      m.length <= 80 ? m : '${m.substring(0, 80)}…(+${m.length - 80})';
}
