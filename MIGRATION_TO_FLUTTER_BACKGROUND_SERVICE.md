# Migration from flutter_foreground_task to flutter_background_service

## Overview

This document describes the migration from `flutter_foreground_task` to `flutter_background_service` with `flutter_local_notifications` for displaying download progress notifications in the YTS Movies app.

## Changes Made

### 1. Dependencies

- Kept: `flutter_background_service: ^5.1.0` (already added)
- Kept: `flutter_local_notifications: ^19.5.0` (already added)
- Can be removed: `flutter_foreground_task: ^9.1.0` (no longer used)

### 2. Core Files Modified

#### `lib/src/services/torrent_task_handler.dart`

**Before:** Extended `TaskHandler` class with override methods
**After:** Standalone entry point function with `@pragma('vm:entry-point')` annotation

**Key Changes:**

- Changed from class-based to function-based entry point: `onStartBackgroundService(ServiceInstance service)`
- Replaced `FlutterForegroundTask.updateService()` with `_showNotification()` using `flutter_local_notifications`
- Replaced `FlutterForegroundTask.sendDataToMain()` with `service.invoke('progressUpdate', data)`
- Communication now uses `service.on('eventName').listen()` pattern instead of `onReceiveData()`
- Added custom notification method with progress bar support:

  ```dart
  Future<void> _showNotification(
    int id,
    String title,
    String body, {
    int? progress,
    int? maxProgress,
  })
  ```

#### `lib/src/services/foreground_download_service.dart`

**Before:** Used `FlutterForegroundTask` APIs
**After:** Uses `FlutterBackgroundService` with custom notification channel

**Key Changes:**

- Replaced `FlutterForegroundTask.init()` with `service.configure()`
- Created notification channel using `flutter_local_notifications`:

  ```dart
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'Torrent Downloads',
    description: 'Shows progress for active torrent downloads',
    importance: Importance.low,
  );
  ```

- Changed communication pattern:
  - Before: `FlutterForegroundTask.sendDataToTask()`
  - After: `service.invoke('eventName', data)`
- Replaced `FlutterForegroundTask.addTaskDataCallback()` with `service.on('progressUpdate').listen()`
- Removed `WithForegroundTask` widget (no longer needed)
- Simplified permission checking using `Permission` APIs directly

#### `lib/main.dart`

**Before:** Called `FlutterForegroundTask.initCommunicationPort()`
**After:** Removed the initialization call (not needed for `flutter_background_service`)

**Key Changes:**

- Removed import of `flutter_foreground_task`
- Removed `FlutterForegroundTask.initCommunicationPort()` call

### 3. Notification System

#### Progress Notifications

The new implementation uses `flutter_local_notifications` to show notifications with progress bars:

```dart
final androidDetails = AndroidNotificationDetails(
  notificationChannelId,
  'Torrent Downloads',
  channelDescription: 'Shows progress for active torrent downloads',
  importance: Importance.low,
  priority: Priority.low,
  showProgress: progress != null && maxProgress != null,
  maxProgress: maxProgress ?? 0,
  progress: progress ?? 0,
  ongoing: true,
  autoCancel: false,
  playSound: false,
  enableVibration: false,
);
```

#### Notification Updates

Progress updates are sent periodically (every 5 seconds) showing:

- Download percentage
- Download/upload speeds
- Number of active downloads

### 4. Service Communication Pattern

#### Old Pattern (flutter_foreground_task)

```dart
// Send to service
FlutterForegroundTask.sendDataToTask({
  'action': 'startDownload',
  'taskId': taskId,
  ...
});

// Receive from service
FlutterForegroundTask.addTaskDataCallback((data) {
  // Handle data
});
```

#### New Pattern (flutter_background_service)

```dart
// Send to service
service.invoke('startDownload', {
  'taskId': taskId,
  ...
});

// Receive from service
service.on('progressUpdate').listen((event) {
  // Handle event
});
```

### 5. Background Service Configuration

The service is configured with:

- **iOS Configuration:** Basic setup with foreground/background handlers
- **Android Configuration:**
  - `isForegroundMode: true` - Runs as foreground service
  - Custom notification channel ID
  - Initial notification content
  - Service ID for notifications

```dart
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
```

## Android Manifest

The `AndroidManifest.xml` already contains the required service declaration:

```xml
<service
    android:name="id.flutter.flutter_background_service.BackgroundService"
    android:exported="false"
    android:stopWithTask="false"
    android:foregroundServiceType="dataSync"/>
```

Required permissions are also already configured:

- `FOREGROUND_SERVICE`
- `FOREGROUND_SERVICE_DATA_SYNC`
- `POST_NOTIFICATIONS`
- `WAKE_LOCK`

## Benefits of Migration

1. **Better Progress Display:** Custom notifications with actual progress bars instead of just text
2. **More Flexible:** `flutter_background_service` provides better control over service lifecycle
3. **Cleaner Architecture:** Event-based communication is more intuitive than callback-based
4. **Better Maintained:** `flutter_background_service` has more active development and community support
5. **Notification Customization:** Direct access to `flutter_local_notifications` allows for rich notification features

## Testing Checklist

- [ ] Service starts correctly when downloading begins
- [ ] Progress notifications display correctly with progress bars
- [ ] Download speeds are shown in notifications
- [ ] Pause/Resume/Stop commands work correctly
- [ ] Multiple simultaneous downloads are handled properly
- [ ] Service stops cleanly when all downloads complete
- [ ] Permissions are requested correctly
- [ ] App works correctly after being closed (service continues)

## Notes

- The service runs in foreground mode (`isForegroundMode: true`) to comply with Android restrictions
- Notification importance is set to LOW to minimize user interruption
- Progress updates are sent every 5 seconds to balance responsiveness and performance
- The implementation maintains backward compatibility with existing download state management
