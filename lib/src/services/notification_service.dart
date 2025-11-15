import 'dart:async';
import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

/// Service to handle notification interactions
@singleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<int> _notificationTapController =
      StreamController<int>.broadcast();

  /// Stream of taskIds from notification taps
  Stream<int> get notificationTapStream => _notificationTapController.stream;

  /// Initialize notification handling
  @postConstruct
  Future<void> initialize() async {
    // Initialize notification settings
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    log('NotificationService initialized');
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload != null) {
        final taskId = int.tryParse(payload);
        if (taskId != null) {
          log('Notification tapped for task: $taskId');
          _notificationTapController.add(taskId);
        }
      }
    } catch (e) {
      log('Error handling notification tap: $e');
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    await _notificationTapController.close();
  }
}
