Here is a full, self-contained code example using **only `flutter_foreground_task`** for all notifications.

This example is broken into the 4 files you will need to create or edit.

### How This Architecture Works

1. **`main.dart` (The UI):** This is your app. It has buttons and a text field. Its only job is to send "commands" (like a magnet link) to the background service and *listen* for progress updates *from* the service.
2. **`torrent_task_handler.dart` (The Background Service):** This is the *real* worker. It runs in a separate Dart isolate (a background thread). It receives commands from the UI, starts the `dtorrent_task_v2` download, and uses `FlutterForegroundTask.updateService` to show the **persistent progress notification**.
3. **`pubspec.yaml`:** Defines all the libraries we need.
4. **`AndroidManifest.xml`:** Gives Android permission to run a foreground service and access the internet.

-----

### 1\. `pubspec.yaml`

First, add all the necessary dependencies to your `pubspec.yaml` file.

```yaml
dependencies:
  flutter:
    sdk: flutter

  # For the torrent engine
  dtorrent_task_v2: ^0.4.4
  dtorrent_parser: ^1.0.8
  b_encode_decode: ^1.0.3

  # The background service
  flutter_foreground_task: ^6.1.0
  
  # For getting a valid download path
  path_provider: ^2.1.3
  
  # For permissions
  permission_handler: ^11.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

-----

### 2\. `android/app/src/main/AndroidManifest.xml`

You **must** add these permissions and the `<service>` tag.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />


    <application ...>
        <activity ...>
            ...
        </activity>

        <service
            android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
            android:enabled="true"
            android:exported="false"
            android:stopWithTask="false"
            android:foregroundServiceType="dataSync"/>
        
    </application>
</manifest>
```

-----

### 3\. `lib/torrent_task_handler.dart`

Create this new file. This is the heart of your background downloader.

```dart
import 'dart:async';
import 'dart:isolate';
import 'package:b_encode_decode/b_encode_decode.dart';
import 'package:dtorrent_parser/dtorrent_parser.dart';
import 'package:dtorrent_task_v2/dtorrent_task_v2.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// --- This is the entry point for the background isolate ---
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle tasks logic.
  FlutterForegroundTask.setTaskHandler(TorrentTaskHandler());
}

class TorrentTaskHandler extends TaskHandler {
  // We use a map to manage multiple, simultaneous downloads
  // Key: infoHash, Value: TorrentTask
  final Map<String, TorrentTask> _tasks = {};
  // Key: infoHash, Value: StreamSubscription
  final Map<String, StreamSubscription> _listeners = {};

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // This is called when the service is started.
  }

  @override
  Future<void> onEvent(DateTime timestamp, dynamic data) async {
    // This is called when the UI sends data to the service.
    if (data is Map<String, dynamic>) {
      String action = data['action'];
      String? infoHash = data['infoHash'];

      if (action == 'startDownload') {
        String magnetLink = data['magnetLink'];
        String savePath = data['savePath'];
        await _startDownloadTask(magnetLink, savePath);
      } else if (action == 'stopDownload' && infoHash != null) {
        await _stopDownloadTask(infoHash);
      } else if (action == 'pauseDownload' && infoHash != null) {
        _tasks[infoHash]?.pause();
      } else if (action == 'resumeDownload' && infoHash != null) {
        _tasks[infoHash]?.resume();
      }
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // This is called when the service is stopped.
    // Clean up all running tasks
    for (var listener in _listeners.values) {
      listener.cancel();
    }
    for (var task in _tasks.values) {
      await task.stop();
    }
    _tasks.clear();
    _listeners.clear();
  }

  Future<void> _startDownloadTask(String magnetLink, String savePath) async {
    try {
      final magnet = MagnetParser.parse(magnetLink);
      if (magnet == null) {
        print('Invalid magnet link');
        return;
      }

      final infoHash = magnet.infoHashString;
      if (_tasks.containsKey(infoHash)) {
        print('Task already running');
        return;
      }

      // 1. Update notification to "Downloading Metadata"
      FlutterForegroundTask.updateService(
        notificationTitle: 'Torrent Download',
        notificationText: 'Downloading metadata for ${magnet.displayName}',
      );

      // 2. Download metadata
      final metadata = MetadataDownloader.fromMagnet(magnetLink);
      final metadataListener = metadata.createListener();

      metadataListener.on<MetaDataDownloadComplete>((event) async {
        final msg = decode(event.data);
        final torrentMap = <String, dynamic>{'info': msg};
        final torrentModel = parseTorrentFileContent(torrentMap);

        if (torrentModel != null) {
          // 3. Create and start the main file download task
          final task = TorrentTask.newTask(torrentModel, savePath);
          _tasks[infoHash] = task;

          // 4. Listen for events to update notification & UI
          final taskListener = task.createListener()
            ..on<TaskProgress>((event) {
              // --- THIS IS THE PROGRESS NOTIFICATION ---
              // This updates the persistent foreground service notification
              String speed = (event.speed * 1000 / 1024).toStringAsFixed(2);
              FlutterForegroundTask.updateService(
                notificationTitle: 'Downloading ${torrentModel.name}',
                notificationText:
                    '${event.progress.toStringAsFixed(2)}% - $speed KB/s',
              );

              // This sends data back to your Flutter UI (if it's open)
              FlutterForegroundTask.sendDataToMain({
                'id': infoHash,
                'progress': event.progress,
                'speed': '$speed KB/s',
              });
            })
            ..on<TaskCompleted>((event) {
              // --- THIS IS THE "COMPLETE" NOTIFICATION ---
              FlutterForegroundTask.updateService(
                notificationTitle: 'Seeding ${torrentModel.name}',
                notificationText: 'Download complete. Now seeding.',
              );
              // Send completion to UI
              FlutterForegroundTask.sendDataToMain({
                'id': infoHash,
                'status': 'complete',
              });
            });

          _listeners[infoHash] = taskListener;
          await task.start();
        }
      });

      metadata.startDownload();
    } catch (e) {
      print('Error starting download: $e');
    }
  }

  Future<void> _stopDownloadTask(String infoHash) async {
    final task = _tasks.remove(infoHash);
    if (task != null) {
      await task.stop();
    }
    _listeners.remove(infoHash)?.cancel();
  }
}
```

-----

### 4\. `lib/main.dart`

Finally, this is your UI file that controls the service.

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// Import the background task handler
import 'torrent_task_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the package
  _initForegroundTask();
  runApp(const MyApp());
}

// --- Configuration for the foreground service ---
void _initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'torrentDownloadChannel',
      channelName: 'Torrent Downloads',
      channelDescription: 'Shows progress for active torrent downloads.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        name: 'ic_launcher',
      ),
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 5000, // Update interval (ms)
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WithForegroundTask(
        // This wrapper is required
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _magnetController = TextEditingController();
  String _taskProgress = 'No active task';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _listenToService();
  }

  Future<void> _requestPermissions() async {
    // Request notification permission (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    // Request storage permission
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
  }

  void _listenToService() {
    // Listen for data coming FROM the service
    FlutterForegroundTask.receiveDataFromService.listen((data) {
      if (data is Map<String, dynamic>) {
        if (data['status'] == 'complete') {
          setState(() {
            _taskProgress = 'Download Complete!';
          });
        } else {
          double progress = data['progress'] ?? 0.0;
          String speed = data['speed'] ?? '0 B/s';
          setState(() {
            _taskProgress =
                'Progress: ${(progress * 100).toStringAsFixed(2)}% - $speed';
          });
        }
      }
    });
  }

  Future<void> _startForegroundService() async {
    if (await FlutterForegroundTask.isRunningService) {
      // Service is already running
      return;
    }

    // This starts the service and calls onStart in your TaskHandler
    await FlutterForegroundTask.startService(
      notificationTitle: 'Torrent Service Started',
      notificationText: 'Waiting for download...',
      callback: startCallback, // This is the entrypoint from torrent_task_handler.dart
    );
  }

  Future<void> _sendDownloadCommand() async {
    if (_magnetController.text.isEmpty) return;

    // Get a valid directory to save files
    // This is safer than hardcoding a path
    final Directory dir = await getApplicationDocumentsDirectory();
    final String savePath = dir.path;

    // Send an 'onEvent' to your TaskHandler
    FlutterForegroundTask.sendDataToService({
      'action': 'startDownload',
      'magnetLink': _magnetController.text,
      'savePath': savePath,
    });
    _magnetController.clear();
  }

  Future<void> _stopService() async {
    // This stops the service and calls onDestroy
    await FlutterForegroundTask.stopService();
    setState(() {
      _taskProgress = 'Service stopped';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Torrent Downloader')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _magnetController,
              decoration: const InputDecoration(labelText: 'Magnet Link'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _startForegroundService,
                  child: const Text('Start Service'),
                ),
                ElevatedButton(
                  onPressed: _sendDownloadCommand,
                  child: const Text('Download'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(_taskProgress, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopService,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Stop Service'),
            ),
          ],
        ),
      ),
    );
  }
}
```
