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
import 'package:ytsmovies/src/services/desktop_torrent_handler.dart';
import 'package:ytsmovies/src/services/desktop_window_service.dart';
import 'package:ytsmovies/src/services/torrent_task_handler.dart';
import 'package:ytsmovies/src/services/preferences_service.dart';
import 'package:ytsmovies/src/utils/storage_permission.dart';

const _logTag = 'FDS';

/// Service to manage foreground torrent downloads
@singleton
class ForegroundDownloadService {
  final PreferencesService _preferencesService;

  ForegroundDownloadService(this._preferencesService);

  bool _isInitialized = false;
  String? _downloadPath;
  final StreamController<ProgressUpdate> _progressController =
      StreamController<ProgressUpdate>.broadcast();
  DesktopTorrentHandler? _desktopHandler;

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

  bool get _supportsBackgroundService => isAndroid || isIOS;

  @postConstruct
  Future<void> initialize() async {
    log('initialize: enter (alreadyInit=$_isInitialized)', name: _logTag);
    if (_isInitialized) return;

    await _initDownloadPath();
    log('initialize: downloadPath=$_downloadPath', name: _logTag);
    await _requestPermissions();

    if (isDesktop) {
      // flutter_background_service has no Windows/Linux/macOS backing, so
      // libtorrent runs directly in the main isolate. Progress flows through
      // the same _progressController the mobile path uses, keeping the bloc
      // unaware of which backend is active.
      final handler = DesktopTorrentHandler(onProgress: _progressController.add);
      await handler.initialize(defaultSavePath: _downloadPath ?? '.');
      _desktopHandler = handler;
      _isInitialized = true;
      log('initialize: desktop handler ready', name: _logTag);
      return;
    }

    if (!_supportsBackgroundService) {
      log('initialize: skipping FlutterBackgroundService (unsupported platform)',
          name: _logTag);
      _isInitialized = true;
      return;
    }

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
    log('initialize: notification channel created', name: _logTag);

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
        initialNotificationTitle: 'Brokeflix',
        initialNotificationContent: 'Torrent download service running',
        foregroundServiceNotificationId: notificationId,
      ),
    );
    log('initialize: FlutterBackgroundService configured', name: _logTag);

    service.on('progressUpdate').listen((event) {
      if (event == null) {
        log('progressUpdate: null event, ignoring', name: _logTag);
        return;
      }
      try {
        final update = ProgressUpdate.fromJson(event);
        log('progressUpdate<- task=${update.taskId}, status=${update.status}, '
            'progress=${(update.progress * 100).toStringAsFixed(1)}%, '
            'dl=${update.downloadSpeed}, ul=${update.uploadSpeed}, '
            'done=${update.downloadedBytes}/${update.totalBytes}, '
            'files=${update.files?.length}, err=${update.error}');
        _progressController.add(update);
      } catch (e, s) {
        log('progressUpdate parse error: $e',
            error: e, stackTrace: s, name: _logTag);
      }
    });

    _isInitialized = true;
    log('initialize: done', name: _logTag);
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
      log('_initDownloadPath failed: $e',
          error: e, stackTrace: s, name: _logTag);
      final appDir = await getApplicationDocumentsDirectory();
      _downloadPath = '${appDir.path}/downloads';
      await Directory(_downloadPath!).create(recursive: true);
    }
  }

  Future<String> _defaultPath() async {
    if (isAndroid) {
      return '$kAndroidPublicDownloadsRoot${Platform.pathSeparator}$kDefaultDownloadSubdir';
    }
    if (isDesktop) {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        return '${downloadsDir.path}${Platform.pathSeparator}$kDefaultDownloadSubdir';
      }
    }
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}${Platform.pathSeparator}Downloads${Platform.pathSeparator}$kDefaultDownloadSubdir';
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
    log('updateDownloadPath: $_downloadPath', name: _logTag);
  }

  Future<void> resetToDefaultPath() async {
    await _preferencesService.setCustomDownloadPath(null);
    _downloadPath = await _defaultPath();
    log('resetToDefaultPath: $_downloadPath', name: _logTag);
  }

  /// Only POST_NOTIFICATIONS is required at runtime — the foreground service
  /// notification channel needs it on Android 13+. Downloads write to
  /// app-scoped external storage (no storage perm) or to a SAF-granted
  /// directory chosen by the user (perm is the URI grant itself).
  Future<void> _requestPermissions() async {
    final status = await Permission.notification.request();
    log('_requestPermissions: notification=$status', name: _logTag);
  }

  Future<bool> checkPermissions() async {
    try {
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        log('checkPermissions: notification re-request -> $status',
            name: _logTag);
        if (!status.isGranted) return false;
      }
      return true;
    } catch (e, s) {
      log('checkPermissions error: $e', error: e, stackTrace: s, name: _logTag);
      return false;
    }
  }

  Future<bool> startService() async {
    if (!_supportsBackgroundService) {
      log('startService: unsupported platform, no-op', name: _logTag);
      return false;
    }
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      log('startService: already running', name: _logTag);
      return true;
    }
    if (!await checkPermissions()) {
      log('startService: permission denied', name: _logTag);
      return false;
    }
    log('startService: starting…', name: _logTag);
    final ok = await service.startService();
    log('startService: startService() returned $ok', name: _logTag);
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
    log('startDownload: taskId=$taskId, savePath=$savePath, '
        'movieTitle="$movieTitle", magnet="${_truncMagnet(magnetUri)}", '
        'dl=$downloadLimit, ul=$uploadLimit, sel=$selectedIndices, '
        'preview=$previewMode');

    final req = StartDownloadRequest(
      taskId: taskId,
      magnetUri: magnetUri,
      savePath: savePath,
      movieTitle: movieTitle,
      initialDownloadLimit:
          downloadLimit ?? _preferencesService.globalDownloadLimit,
      initialUploadLimit: uploadLimit ?? _preferencesService.globalUploadLimit,
      selectedIndices: selectedIndices,
      previewMode: previewMode,
    );

    if (_desktopHandler != null) {
      await _desktopHandler!.startDownload(req);
      return;
    }

    if (!_supportsBackgroundService) {
      log('startDownload: unsupported platform, no-op', name: _logTag);
      return;
    }
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) {
      log('startDownload: service not running, starting', name: _logTag);
      final started = await startService();
      if (!started) {
        log('startDownload: startService failed', name: _logTag);
        throw Exception(
          'Failed to start foreground service. Please grant notification '
          'and storage permissions in app settings.',
        );
      }
      log('startDownload: waiting 500ms for service spin-up', name: _logTag);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    log('startDownload-> invoke "startDownload" json keys=${req.toJson().keys.toList()}',
        name: _logTag);
    service.invoke('startDownload', req.toJson());
  }

  Future<void> pauseDownload(int taskId) async {
    log('pauseDownload-> taskId=$taskId', name: _logTag);
    final req = DownloadControlRequest(taskId: taskId);
    if (_desktopHandler != null) {
      _desktopHandler!.pauseDownload(req);
      return;
    }
    if (!_supportsBackgroundService) return;
    FlutterBackgroundService().invoke('pauseDownload', req.toJson());
  }

  Future<void> resumeDownload(int taskId) async {
    log('resumeDownload-> taskId=$taskId', name: _logTag);
    final req = DownloadControlRequest(taskId: taskId);
    if (_desktopHandler != null) {
      _desktopHandler!.resumeDownload(req);
      return;
    }
    if (!_supportsBackgroundService) return;
    FlutterBackgroundService().invoke('resumeDownload', req.toJson());
  }

  Future<void> stopDownload(int taskId) async {
    log('stopDownload-> taskId=$taskId', name: _logTag);
    final req = DownloadControlRequest(taskId: taskId);
    if (_desktopHandler != null) {
      _desktopHandler!.stopDownload(req);
      return;
    }
    if (!_supportsBackgroundService) return;
    FlutterBackgroundService().invoke('stopDownload', req.toJson());
  }

  /// Drop the torrent and let libtorrent wipe its on-disk files.
  Future<void> deleteDownload(int taskId) async {
    log('deleteDownload-> taskId=$taskId', name: _logTag);
    final req = DownloadControlRequest(taskId: taskId);
    if (_desktopHandler != null) {
      _desktopHandler!.deleteDownload(req);
      return;
    }
    if (!_supportsBackgroundService) return;
    FlutterBackgroundService().invoke('deleteDownload', req.toJson());
  }

  /// libtorrent_flutter exposes only session-wide limits. The handler applies
  /// the most-recent request across all tasks; the per-task field is kept for
  /// UI display but the cap is effectively global.
  Future<void> setSpeedLimit({
    required int taskId,
    int? downloadLimit,
    int? uploadLimit,
  }) async {
    log('setSpeedLimit-> taskId=$taskId, dl=$downloadLimit, ul=$uploadLimit',
        name: _logTag);
    final req = SetSpeedLimitRequest(
      taskId: taskId,
      downloadLimit: downloadLimit,
      uploadLimit: uploadLimit,
    );
    if (_desktopHandler != null) {
      _desktopHandler!.setSpeedLimit(req);
      return;
    }
    if (!_supportsBackgroundService) return;
    FlutterBackgroundService().invoke('setSpeedLimit', req.toJson());
  }

  Future<void> setFilePriority({
    required int taskId,
    required int fileIndex,
    required FilePriorityLevel priority,
  }) async {
    log('setFilePriority-> taskId=$taskId, file=$fileIndex, prio=$priority',
        name: _logTag);
    final req = SetFilePriorityRequest(
      taskId: taskId,
      fileIndex: fileIndex,
      priority: priority,
    );
    if (_desktopHandler != null) {
      _desktopHandler!.setFilePriority(req);
      return;
    }
    if (!_supportsBackgroundService) return;
    FlutterBackgroundService().invoke('setFilePriority', req.toJson());
  }

  Future<void> applyFileSelection({
    required int taskId,
    required List<int> selectedIndices,
  }) async {
    log('applyFileSelection-> taskId=$taskId, selected=$selectedIndices',
        name: _logTag);
    final req = ApplyFileSelectionRequest(
      taskId: taskId,
      selectedIndices: selectedIndices,
    );
    if (_desktopHandler != null) {
      _desktopHandler!.applyFileSelection(req);
      return;
    }
    if (!_supportsBackgroundService) return;
    FlutterBackgroundService().invoke('applyFileSelection', req.toJson());
  }

  Future<void> stopService() async {
    if (_desktopHandler != null) {
      await _desktopHandler!.dispose();
      _desktopHandler = null;
      return;
    }
    if (!_supportsBackgroundService) return;
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      log('stopService-> invoking', name: _logTag);
      service.invoke('stopService');
    } else {
      log('stopService: not running', name: _logTag);
    }
  }

  Future<bool> isServiceRunning() async {
    if (_desktopHandler != null) return true;
    if (!_supportsBackgroundService) return false;
    return await FlutterBackgroundService().isRunning();
  }

  @disposeMethod
  Future<void> dispose() async {
    log('dispose', name: _logTag);
    await _desktopHandler?.dispose();
    _desktopHandler = null;
    await _progressController.close();
    _isInitialized = false;
  }

  String _truncMagnet(String m) =>
      m.length <= 80 ? m : '${m.substring(0, 80)}…(+${m.length - 80})';
}
