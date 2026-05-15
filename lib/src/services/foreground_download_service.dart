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

  String get downloadPath {
    if (_downloadPath != null) return _downloadPath!;
    return '/storage/emulated/0/Download/Movies';
  }

  @postConstruct
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initDownloadPath();
    await _requestPermissions();
    await checkPermissions();

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

  Future<void> _initDownloadPath() async {
    try {
      final customPath = _preferencesService.customDownloadPath;
      if (customPath != null && await Directory(customPath).exists()) {
        _downloadPath = customPath;
      } else {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          _downloadPath = '${downloadsDir.path}/Movies';
        } else {
          final appDir = await getApplicationDocumentsDirectory();
          _downloadPath = '${appDir.path}/downloads';
        }
      }
      await Directory(_downloadPath!).create(recursive: true);
    } catch (e, s) {
      log('Error initializing download path: $e', error: e, stackTrace: s);
      final appDir = await getApplicationDocumentsDirectory();
      _downloadPath = '${appDir.path}/downloads';
      await Directory(_downloadPath!).create(recursive: true);
    }
  }

  Future<void> updateDownloadPath(String newPath) async {
    final dir = Directory(newPath);
    if (!await dir.exists()) await dir.create(recursive: true);
    await _preferencesService.setCustomDownloadPath(newPath);
    _downloadPath = newPath;
  }

  Future<void> resetToDefaultPath() async {
    final downloadsDir = await getDownloadsDirectory();
    String defaultPath;
    if (downloadsDir != null) {
      defaultPath = '${downloadsDir.path}/Movies';
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      defaultPath = '${appDir.path}/downloads';
    }
    await _preferencesService.setCustomDownloadPath(null);
    _downloadPath = defaultPath;
    await Directory(_downloadPath!).create(recursive: true);
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    if (await Permission.videos.isDenied) {
      await Permission.videos.request();
    }
  }

  Future<bool> checkPermissions() async {
    try {
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        if (!status.isGranted) return false;
      }
      if (await Permission.videos.isDenied) {
        final status = await Permission.videos.request();
        if (!status.isGranted) {
          if (await Permission.manageExternalStorage.isDenied) {
            final manageStatus =
                await Permission.manageExternalStorage.request();
            if (!manageStatus.isGranted) return false;
          }
        }
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

    // Apply global limits + default trackers from preferences
    service.invoke('setMaxConcurrent', {
      'value': _preferencesService.maxConcurrentDownloads,
    });

    service.invoke(
      'startDownload',
      StartDownloadRequest(
        taskId: taskId,
        magnetUri: magnetUri,
        savePath: savePath,
        movieTitle: movieTitle,
        extraTrackers: _preferencesService.defaultTrackers,
        initialDownloadLimit: _preferencesService.globalDownloadLimit,
        initialUploadLimit: _preferencesService.globalUploadLimit,
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

  Future<void> addTracker({
    required int taskId,
    required String trackerUrl,
  }) async {
    FlutterBackgroundService().invoke(
      'addTracker',
      AddTrackerRequest(taskId: taskId, trackerUrl: trackerUrl).toJson(),
    );
  }

  Future<void> removeTracker({
    required int taskId,
    required String trackerUrl,
  }) async {
    FlutterBackgroundService().invoke(
      'removeTracker',
      RemoveTrackerRequest(taskId: taskId, trackerUrl: trackerUrl).toJson(),
    );
  }

  Future<void> setMaxConcurrent(int value) async {
    await _preferencesService.setMaxConcurrentDownloads(value);
    FlutterBackgroundService().invoke('setMaxConcurrent', {'value': value});
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
