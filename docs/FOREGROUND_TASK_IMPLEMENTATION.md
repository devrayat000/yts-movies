# Flutter Foreground Task Implementation

This document details the proper implementation of `flutter_foreground_task` in the YTS Movies app for background torrent downloads.

## Key Changes Made

### 1. Main Entry Point (`lib/main.dart`)

**Critical Addition**: Initialize communication port before anything else

```dart
void main() {
  // Initialize port for communication between TaskHandler and UI.
  FlutterForegroundTask.initCommunicationPort();
  
  runZonedGuarded(_initializeApp, ...);
}
```

This **must** be called before `runApp()` to enable two-way communication between the background task handler and the UI.

### 2. Service Initialization (`lib/src/services/foreground_download_service.dart`)

#### Proper Initialization Flow

```dart
Future<void> initialize() async {
  if (_isInitialized) return;

  // 1. Request permissions first
  await _requestPermissions();

  // 2. Initialize foreground task with proper options
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'yts_torrent_downloads',
      channelName: 'YTS Torrent Downloads',
      channelDescription: 'Shows progress for active torrent downloads.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      onlyAlertOnce: true,  // Prevent notification sound on every update
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),  // Call onRepeatEvent every 5 seconds
      autoRunOnBoot: false,  // Don't auto-start on device boot
      autoRunOnMyPackageReplaced: false,
      allowWakeLock: true,  // Keep device awake during downloads
      allowWifiLock: true,  // Keep WiFi active
    ),
  );

  // 3. Add callback to receive data sent from the TaskHandler
  FlutterForegroundTask.addTaskDataCallback(_handleBackgroundData);

  _isInitialized = true;
}
```

#### Permission Requests (Following Official Documentation)

```dart
Future<void> _requestPermissions() async {
  // Android 13+: notification permission required for foreground service notification
  final notificationPermission =
      await FlutterForegroundTask.checkNotificationPermission();
  if (notificationPermission != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }

  // Android 12+: battery optimization exemption for reliable service restart
  if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  }
}
```

### 3. Task Handler (`lib/src/services/torrent_task_handler.dart`)

#### Entry Point Declaration

```dart
@pragma('vm:entry-point')  // Required for isolate entry point
void startTorrentCallback() {
  FlutterForegroundTask.setTaskHandler(TorrentTaskHandler());
}
```

#### TaskHandler Lifecycle

```dart
class TorrentTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Called when service starts
    log('TorrentTaskHandler: Service started');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Called periodically (every 5 seconds)
    // Update notification with current progress
    if (_tasks.isNotEmpty) {
      final totalProgress = ...;
      FlutterForegroundTask.updateService(
        notificationTitle: 'Torrent Downloads',
        notificationText: '$activeCount active download(s) • ${progress}%',
      );
    }
  }

  @override
  void onReceiveData(Object data) {
    // Receive commands from UI (start, pause, resume, stop)
    if (data is Map<String, dynamic>) {
      final action = data['action'];
      // Handle actions...
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool stopWithTask) async {
    // Clean up all resources
    for (var listener in _taskListeners.values) {
      listener?.clear();
    }
    // Stop all tasks...
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Handle notification button taps
    switch (id) {
      case 'pause_all':
        // Pause all downloads
        break;
      case 'stop_all':
        // Stop all downloads
        break;
    }
  }

  @override
  void onNotificationPressed() {
    // Launch app when notification is tapped
    FlutterForegroundTask.launchApp('/downloads');
  }

  @override
  void onNotificationDismissed() {
    log('Notification dismissed');
  }
}
```

### 4. Two-Way Communication

#### UI → TaskHandler

```dart
// Send command from UI to background task
FlutterForegroundTask.sendDataToTask({
  'action': 'startDownload',
  'taskId': taskId,
  'magnetUri': magnetUri,
  'savePath': savePath,
});
```

#### TaskHandler → UI

```dart
// Send progress update from background to UI
FlutterForegroundTask.sendDataToMain({
  'taskId': taskId,
  'status': 'downloading',
  'progress': 0.45,
  'downloadSpeed': 1234567,
});
```

### 5. Android Manifest Permissions

Required permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Required for foreground service -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

<!-- Required for Android 14+ (must match service type) -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC"/>

<!-- Required for Android 13+ to show notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Keeps device awake during downloads -->
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- Allows requesting battery optimization exemption -->
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
```

Service declaration:

```xml
<service
    android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
    android:foregroundServiceType="dataSync"
    android:exported="false"
    android:stopWithTask="false"/>
```

## Important Notes from Documentation

### Android 14+ Requirements

- **Must declare `foregroundServiceType`** in service declaration
- Available types: camera, connectedDevice, dataSync, health, location, mediaPlayback, mediaProjection, microphone, phoneCall, remoteMessaging, shortService, specialUse, systemExempted
- We use `dataSync` for torrent downloads
- Check [runtime requirements](https://developer.android.com/about/versions/14/changes/fgs-types-required#system-runtime-checks) before starting service

### Android 15+ Restrictions

- `dataSync` services have a **6-hour timeout in 24 hours**
- Timer resets when app comes to foreground
- `BOOT_COMPLETED` receivers **cannot launch** dataSync, camera, mediaPlayback, phoneCall, or microphone services
- See [Android 15 behavior changes](https://developer.android.com/about/versions/15/behavior-changes-15#fgs-hardening)

### Best Practices

1. Always call `FlutterForegroundTask.initCommunicationPort()` in `main()` **before** `runApp()`
2. Add task data callback using `addTaskDataCallback()` after initialization
3. Remove callback in `dispose()` using `removeTaskDataCallback()`
4. Use `@pragma('vm:entry-point')` for callback functions
5. Check if service is running before starting: `await FlutterForegroundTask.isRunningService`
6. Use `onlyAlertOnce: true` in notification options to prevent sound on every update
7. Clean up all listeners and resources in `onDestroy()`

## Testing

### Physical Device Required

- Foreground services have **limitations on emulators**
- Background execution may not work properly in emulators
- Test on **physical Android device** for accurate behavior

### Test Scenarios

1. Start download → minimize app → verify notification updates
2. Tap notification buttons → verify pause/stop actions
3. Tap notification → verify app opens to downloads page
4. Kill app from recent apps → verify service stops (since `stopWithTask="false"` but we don't use `autoRunOnBoot`)
5. Download for extended period → verify no timeout issues (< 6 hours)

## Migration from Previous Implementation

### Removed

- ❌ Direct `Timer.periodic` polling (inefficient)
- ❌ `permission_handler` for notification permissions (use `FlutterForegroundTask` methods)
- ❌ Deprecated `NotificationIconData` in notification options

### Added

- ✅ `FlutterForegroundTask.initCommunicationPort()` in main
- ✅ Proper permission request flow using framework methods
- ✅ Native event listeners for torrent progress
- ✅ Notification button handlers
- ✅ Notification press handlers with app launch

## References

- [flutter_foreground_task Documentation](https://pub.dev/packages/flutter_foreground_task)
- [Android Foreground Services Guide](https://developer.android.com/develop/background-work/services/foreground-services)
- [Android 14 FGS Changes](https://developer.android.com/about/versions/14/changes/fgs-types-required)
- [Android 15 Behavior Changes](https://developer.android.com/about/versions/15/behavior-changes-15#fgs-hardening)
