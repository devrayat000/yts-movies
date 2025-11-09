import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ytsmovies/src/services/torrent_task_handler.dart';

/// Service to manage foreground torrent downloads
class ForegroundDownloadService {
  static ForegroundDownloadService? _instance;
  static ForegroundDownloadService get instance =>
      _instance ?? (_instance = ForegroundDownloadService._());

  ForegroundDownloadService._();

  bool _isInitialized = false;
  final StreamController<Map<String, dynamic>> _progressController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of download progress updates from background service
  Stream<Map<String, dynamic>> get progressStream => _progressController.stream;

  /// Initialize the foreground task service
  Future<void> initialize() async {
    if (_isInitialized) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'yts_torrent_downloads',
        channelName: 'YTS Torrent Downloads',
        channelDescription: 'Shows progress for active torrent downloads.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
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

    // Listen for data from background service
    FlutterForegroundTask.addTaskDataCallback(_handleBackgroundData);

    _isInitialized = true;
    log('ForegroundDownloadService initialized');
  }

  void _handleBackgroundData(Object data) {
    if (data is Map<String, dynamic>) {
      log('Received data from background: $data');
      _progressController.add(data);
    }
  }

  /// Request necessary permissions
  Future<bool> requestPermissions() async {
    // Request notification permission (Android 13+)
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        log('Notification permission denied');
        return false;
      }
    }

    // Request storage permissions
    if (await Permission.storage.isDenied) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        log('Storage permission denied');
        return false;
      }
    }

    return true;
  }

  /// Start the foreground service if not already running
  Future<bool> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      log('Foreground service already running');
      return true;
    }

    // Request permissions first
    if (!await requestPermissions()) {
      return false;
    }

    final serviceId = await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'YTS Movies',
      notificationText: 'Torrent download service running',
      notificationButtons: [
        const NotificationButton(id: 'pause_all', text: 'Pause All'),
        const NotificationButton(id: 'stop_all', text: 'Stop All'),
      ],
      callback: startTorrentCallback,
    );

    log('Foreground service started: $serviceId');
    return true;
  }

  /// Send download command to background service
  Future<void> startDownload({
    required String taskId,
    required String magnetUri,
    required String savePath,
    required String movieTitle,
  }) async {
    // Ensure service is running
    if (!await FlutterForegroundTask.isRunningService) {
      final started = await startService();
      if (!started) {
        throw Exception('Failed to start foreground service');
      }

      // Wait a bit for service to initialize
      await Future.delayed(const Duration(milliseconds: 500));
    }

    log('Sending download command for $taskId');

    // Send data to background service
    FlutterForegroundTask.sendDataToTask({
      'action': 'startDownload',
      'taskId': taskId,
      'magnetUri': magnetUri,
      'savePath': savePath,
      'movieTitle': movieTitle,
    });
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
