import 'dart:async';
import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

/// Service to handle notification interactions
@singleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<NotificationResponse> _notificationTapController =
      StreamController<NotificationResponse>.broadcast();

  /// Stream of notification tap responses
  Stream<NotificationResponse> get notificationTapStream =>
      _notificationTapController.stream;

  /// Initialize notification handling
  @postConstruct
  Future<void> initialize() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final initializationSettingsWindows = WindowsInitializationSettings(
      appName: 'Brokeflix',
      appUserModelId: 'dev.rayat.brokeflix',
      guid: 'b07a4d8b-7c2f-4a13-9c4a-e3b9f3a4d8c2',
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      windows: initializationSettingsWindows,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    log('NotificationService initialized');
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    try {
      log('Notification response received: actionId=${response.actionId}, payload=${response.payload}');
      _notificationTapController.add(response);
    } catch (e) {
      log('Error handling notification tap: $e');
    }
  }

  /// Dispose the service
  @disposeMethod
  Future<void> dispose() async {
    await _notificationTapController.close();
  }
}
