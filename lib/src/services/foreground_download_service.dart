import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

  /// Stream of download progress updates from background service
  Stream<ProgressUpdate> get progressStream => _progressController.stream;

  /// Get current download path
  /// Returns a safe default if not initialized yet
  String get downloadPath {
    if (_downloadPath != null) {
      return _downloadPath!;
    }
    // Return a temporary safe default while initializing
    // This will be replaced once initialization completes
    return '/storage/emulated/0/Download/Movies';
  }

  /// Initialize the foreground task service
  @postConstruct
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize download path first
    await _initDownloadPath();

    // Request permissions early
    await _requestPermissions();

    // Also request runtime permissions
    await checkPermissions();

    // Initialize notification plugin
    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Create notification channel
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

    // Initialize background service
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
        // foregroundServiceNotificationIcon: '@mipmap/ic_launcher',
      ),
    );

    // Listen for progress updates from background service
    service.on('progressUpdate').listen((event) {
      if (event != null) {
        try {
          final update = ProgressUpdate.fromJson(event);
          _progressController.add(update);
        } catch (e) {
          log('Error parsing progress update: $e');
        }
      }
    });

    _isInitialized = true;
    log('ForegroundDownloadService initialized');
  }

  /// iOS background handler
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    return true;
  }

  /// Initialize download path
  Future<void> _initDownloadPath() async {
    try {
      // Check if user has set a custom download path
      final customPath = _preferencesService.customDownloadPath;

      if (customPath != null && await Directory(customPath).exists()) {
        _downloadPath = customPath;
        log('Using custom download path: $_downloadPath');
      } else {
        // Use default downloads directory
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          _downloadPath = '${downloadsDir.path}/Movies';
          log('Using default download path: $_downloadPath');
        } else {
          // Fallback to app documents directory if downloads not available
          final appDir = await getApplicationDocumentsDirectory();
          _downloadPath = '${appDir.path}/downloads';
          log('Downloads directory not available, using fallback: $_downloadPath');
        }
      }

      // Create directory if it doesn't exist
      await Directory(_downloadPath!).create(recursive: true);

      log('Download path initialized: $_downloadPath');
    } catch (e, s) {
      log('Error initializing download path: $e', error: e, stackTrace: s);
      // Fallback to a safe default
      final appDir = await getApplicationDocumentsDirectory();
      _downloadPath = '${appDir.path}/downloads';
      await Directory(_downloadPath!).create(recursive: true);
    }
  }

  /// Update download path (called when user selects custom directory)
  Future<void> updateDownloadPath(String newPath) async {
    try {
      // Validate the path
      final dir = Directory(newPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Save to preferences
      await _preferencesService.setCustomDownloadPath(newPath);

      // Update current path
      _downloadPath = newPath;

      log('Download path updated to: $newPath');
    } catch (e, s) {
      log('Error updating download path: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Reset to default download path
  Future<void> resetToDefaultPath() async {
    try {
      // Use default downloads directory
      final downloadsDir = await getDownloadsDirectory();
      String defaultPath;

      if (downloadsDir != null) {
        defaultPath = '${downloadsDir.path}/Movies';
      } else {
        // Fallback to app documents directory if downloads not available
        final appDir = await getApplicationDocumentsDirectory();
        defaultPath = '${appDir.path}/downloads';
      }

      await _preferencesService.setCustomDownloadPath(null);
      _downloadPath = defaultPath;

      await Directory(_downloadPath!).create(recursive: true);

      log('Download path reset to default: $defaultPath');
    } catch (e, s) {
      log('Error resetting download path: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Request necessary permissions for foreground service
  Future<void> _requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();

    // Request storage permissions
    if (await Permission.videos.isDenied) {
      await Permission.videos.request();
    }
  }

  /// Check if we have necessary permissions to start the service
  Future<bool> checkPermissions() async {
    try {
      // Check notification permission
      if (await Permission.notification.isDenied) {
        log('Notification permission not granted, requesting...');
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          log('Notification permission denied by user');
          return false;
        }
      }

      // Check storage permissions based on Android version
      // Android 13+ uses granular media permissions
      if (await Permission.videos.isDenied) {
        log('Videos permission not granted, requesting...');
        final status = await Permission.videos.request();
        if (!status.isGranted) {
          log('Videos permission denied');
          // Try with manageExternalStorage for Android 11+
          if (await Permission.manageExternalStorage.isDenied) {
            log('Requesting MANAGE_EXTERNAL_STORAGE permission...');
            final manageStatus =
                await Permission.manageExternalStorage.request();
            if (!manageStatus.isGranted) {
              log('MANAGE_EXTERNAL_STORAGE permission denied');
              return false;
            }
          }
        }
      }

      log('All permissions granted');
      return true;
    } catch (e, s) {
      log('Error checking permissions: $e', error: e, stackTrace: s);
      return false;
    }
  }

  /// Start the foreground service if not already running
  Future<bool> startService() async {
    final service = FlutterBackgroundService();

    if (await service.isRunning()) {
      log('Foreground service already running');
      return true;
    }

    // Check permissions
    if (!await checkPermissions()) {
      log('Missing required permissions');
      return false;
    }

    await service.startService();

    log('Foreground service started');
    return true;
  }

  /// Send download command to background service
  Future<void> startDownload({
    required int taskId,
    required String magnetUri,
    required String savePath,
    required String movieTitle,
  }) async {
    log('=== ForegroundDownloadService.startDownload ===');
    log('TaskId: $taskId');
    log('MagnetUri: $magnetUri');
    log('SavePath: $savePath');
    log('MovieTitle: $movieTitle');

    final service = FlutterBackgroundService();

    // Ensure service is running
    if (!await service.isRunning()) {
      log('Service not running, starting it...');
      final started = await startService();
      if (!started) {
        throw Exception(
          'Failed to start foreground service. Please grant notification and storage permissions in app settings.',
        );
      }

      // Wait a bit for service to initialize
      await Future.delayed(const Duration(milliseconds: 500));
      log('Service started, waited 500ms for initialization');
    } else {
      log('Service already running');
    }

    log('Sending download command to background task...');

    // Send data to background service
    service.invoke(
      'startDownload',
      StartDownloadRequest(
        taskId: taskId,
        magnetUri: magnetUri,
        savePath: savePath,
        movieTitle: movieTitle,
      ).toJson(),
    );

    log('Download command sent successfully');
  }

  /// Pause a download
  Future<void> pauseDownload(int taskId) async {
    final service = FlutterBackgroundService();
    service.invoke(
      'pauseDownload',
      DownloadControlRequest(taskId: taskId).toJson(),
    );
  }

  /// Resume a download
  Future<void> resumeDownload(int taskId) async {
    final service = FlutterBackgroundService();
    service.invoke(
      'resumeDownload',
      DownloadControlRequest(taskId: taskId).toJson(),
    );
  }

  /// Stop a download
  Future<void> stopDownload(int taskId) async {
    final service = FlutterBackgroundService();
    service.invoke(
      'stopDownload',
      DownloadControlRequest(taskId: taskId).toJson(),
    );
  }

  /// Stop the foreground service
  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('stopService');
      log('Foreground service stopped');
    }
  }

  /// Check if service is running
  Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }

  /// Dispose the service
  Future<void> dispose() async {
    await _progressController.close();
    _isInitialized = false;
  }
}
