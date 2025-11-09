import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ytsmovies/src/services/torrent_task_handler.dart';
import 'package:ytsmovies/src/services/preferences_service.dart';

/// Service to manage foreground torrent downloads
class ForegroundDownloadService {
  static ForegroundDownloadService? _instance;
  static ForegroundDownloadService get instance =>
      _instance ?? (_instance = ForegroundDownloadService._());

  ForegroundDownloadService._();

  bool _isInitialized = false;
  String? _downloadPath;
  final StreamController<Map<String, dynamic>> _progressController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of download progress updates from background service
  Stream<Map<String, dynamic>> get progressStream => _progressController.stream;

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
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize download path first
    await _initDownloadPath();

    // Request permissions early
    await _requestPermissions();

    // Also request runtime permissions
    await checkPermissions();

    // Initialize foreground task
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'yts_torrent_downloads',
        channelName: 'YTS Torrent Downloads',
        channelDescription: 'Shows progress for active torrent downloads.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    // Add callback to receive data sent from the TaskHandler
    FlutterForegroundTask.addTaskDataCallback(_handleBackgroundData);

    _isInitialized = true;
    log('ForegroundDownloadService initialized');
  }

  /// Initialize download path
  Future<void> _initDownloadPath() async {
    try {
      // Check if user has set a custom download path
      final customPath = PreferencesService.instance.customDownloadPath;

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
      await PreferencesService.instance.setCustomDownloadPath(newPath);

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

      await PreferencesService.instance.setCustomDownloadPath(null);
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
    // Android 13+, you need to allow notification permission to display foreground service notification.
    final notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    // Android 12+, there are restrictions on starting a foreground service.
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
  }

  void _handleBackgroundData(Object data) {
    if (data is Map<String, dynamic>) {
      log('Received data from background: $data');
      _progressController.add(data);
    }
  }

  /// Check if we have necessary permissions to start the service
  Future<bool> checkPermissions() async {
    try {
      // Check notification permission (required for foreground service)
      final notificationPermission =
          await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermission != NotificationPermission.granted) {
        log('Notification permission not granted, requesting...');
        await FlutterForegroundTask.requestNotificationPermission();

        // Check again after request
        final notificationPermissionAfter =
            await FlutterForegroundTask.checkNotificationPermission();
        if (notificationPermissionAfter != NotificationPermission.granted) {
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
    if (await FlutterForegroundTask.isRunningService) {
      log('Foreground service already running');
      return true;
    }

    // Check permissions
    if (!await checkPermissions()) {
      log('Missing required permissions');
      return false;
    }

    await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'YTS Movies',
      notificationText: 'Torrent download service running',
      notificationButtons: [
        const NotificationButton(id: 'pause_all', text: 'Pause All'),
        const NotificationButton(id: 'stop_all', text: 'Stop All'),
      ],
      callback: startTorrentCallback,
    );

    log('Foreground service started with serviceId: 256');
    return true;
  }

  /// Send download command to background service
  Future<void> startDownload({
    required String taskId,
    required String magnetUri,
    required String savePath,
    required String movieTitle,
  }) async {
    log('=== ForegroundDownloadService.startDownload ===');
    log('TaskId: $taskId');
    log('MagnetUri: $magnetUri');
    log('SavePath: $savePath');
    log('MovieTitle: $movieTitle');

    // Ensure service is running
    if (!await FlutterForegroundTask.isRunningService) {
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
    FlutterForegroundTask.sendDataToTask({
      'action': 'startDownload',
      'taskId': taskId,
      'magnetUri': magnetUri,
      'savePath': savePath,
      'movieTitle': movieTitle,
    });

    log('Download command sent successfully');
  }

  /// Pause a download
  Future<void> pauseDownload(String taskId) async {
    FlutterForegroundTask.sendDataToTask({
      'action': 'pauseDownload',
      'taskId': taskId,
    });
  }

  /// Resume a download
  Future<void> resumeDownload(String taskId) async {
    FlutterForegroundTask.sendDataToTask({
      'action': 'resumeDownload',
      'taskId': taskId,
    });
  }

  /// Stop a download
  Future<void> stopDownload(String taskId) async {
    FlutterForegroundTask.sendDataToTask({
      'action': 'stopDownload',
      'taskId': taskId,
    });
  }

  /// Stop the foreground service
  Future<void> stopService() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
      log('Foreground service stopped');
    }
  }

  /// Check if service is running
  Future<bool> isServiceRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }

  /// Dispose the service
  Future<void> dispose() async {
    FlutterForegroundTask.removeTaskDataCallback(_handleBackgroundData);
    await _progressController.close();
    _isInitialized = false;
  }
}

/// Widget wrapper for foreground task requirements
class WithForegroundTask extends StatelessWidget {
  final Widget child;

  const WithForegroundTask({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(child: child);
  }
}
