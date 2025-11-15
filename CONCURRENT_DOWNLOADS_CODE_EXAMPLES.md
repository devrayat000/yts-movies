# Concurrent Downloads - Code Examples

This file contains practical code examples for implementing concurrent torrent downloads based on the analysis in `MULTIPLE_TORRENT_DOWNLOADS_FIX.md`.

## Table of Contents

1. [Enhanced Notification System](#1-enhanced-notification-system)
2. [Task Queue Manager](#2-task-queue-manager)
3. [Resource Isolation](#3-resource-isolation)
4. [Comprehensive Logging](#4-comprehensive-logging)
5. [Metadata Queue Manager](#5-metadata-queue-manager)
6. [Task State Machine](#6-task-state-machine)
7. [Updated TorrentTaskHandler](#7-updated-torrenttaskhandler)
8. [PreferencesService Extensions](#8-preferencesservice-extensions)

---

## 1. Enhanced Notification System

### Create separate notification managers for service and tasks

```dart
// lib/src/services/notification_manager.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Manages notifications for torrent downloads
class TorrentNotificationManager {
  final FlutterLocalNotificationsPlugin _plugin;
  
  // Constants
  static const int serviceNotificationId = 888;
  static const int taskNotificationIdBase = 1000;
  static const String channelId = 'torrent_downloads';
  
  TorrentNotificationManager(this._plugin);
  
  /// Update the main foreground service notification
  /// This notification keeps the service alive
  Future<void> updateServiceNotification({
    required int activeDownloads,
    required double averageProgress,
    String? statusText,
  }) async {
    final body = statusText ?? 
        '$activeDownloads active download(s) • ${(averageProgress * 100).toStringAsFixed(1)}% average';
    
    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Torrent Downloads',
      channelDescription: 'Shows progress for active torrent downloads',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
      // Don't show progress bar for service notification
      showProgress: false,
    );

    await _plugin.show(
      serviceNotificationId,
      'YTS Movies',
      body,
      NotificationDetails(android: androidDetails),
    );
  }
  
  /// Update a task-specific notification
  /// These notifications show individual download progress
  Future<void> updateTaskNotification({
    required int taskId,
    required String title,
    required String body,
    int? progress,
    int? maxProgress,
  }) async {
    // Use offset to avoid collision with service notification
    final notificationId = taskNotificationIdBase + taskId;
    
    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Torrent Downloads',
      channelDescription: 'Shows progress for active torrent downloads',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: progress != null && maxProgress != null,
      maxProgress: maxProgress ?? 0,
      progress: progress ?? 0,
      ongoing: progress != null && progress < 100,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }
  
  /// Cancel a task notification when download completes or is removed
  Future<void> cancelTaskNotification(int taskId) async {
    final notificationId = taskNotificationIdBase + taskId;
    await _plugin.cancel(notificationId);
  }
  
  /// Cancel all task notifications
  Future<void> cancelAllTaskNotifications() async {
    await _plugin.cancelAll();
  }
}
```

---

## 2. Task Queue Manager

### Manage concurrent download limits with a queue system

```dart
// lib/src/services/task_queue_manager.dart

import 'dart:collection';
import 'dart:developer';

/// Manages task queuing and concurrency limits
class TaskQueueManager {
  final int maxConcurrentTasks;
  final int maxConcurrentMetadata;
  
  // Active tasks currently downloading
  final Set<int> _activeTasks = {};
  
  // Tasks waiting to start
  final Queue<int> _pendingTasks = Queue();
  
  // Tasks currently downloading metadata
  final Set<int> _activeMetadataTasks = {};
  
  // Tasks waiting for metadata download
  final Queue<int> _pendingMetadataTasks = Queue();
  
  TaskQueueManager({
    this.maxConcurrentTasks = 2,
    this.maxConcurrentMetadata = 1,
  });
  
  /// Check if we can start a new task
  bool canStartTask() {
    return _activeTasks.length < maxConcurrentTasks;
  }
  
  /// Check if we can start metadata download
  bool canStartMetadata() {
    return _activeMetadataTasks.length < maxConcurrentMetadata;
  }
  
  /// Add a task to the queue
  void enqueueTask(int taskId) {
    if (!_pendingTasks.contains(taskId) && !_activeTasks.contains(taskId)) {
      _pendingTasks.add(taskId);
      log('Task $taskId added to queue. Queue size: ${_pendingTasks.length}');
    }
  }
  
  /// Start a task (move from pending to active)
  bool startTask(int taskId) {
    if (canStartTask()) {
      _pendingTasks.remove(taskId);
      _activeTasks.add(taskId);
      log('Task $taskId started. Active: ${_activeTasks.length}, Pending: ${_pendingTasks.length}');
      return true;
    }
    return false;
  }
  
  /// Complete a task (remove from active)
  /// Returns the next task ID to start, if any
  int? completeTask(int taskId) {
    _activeTasks.remove(taskId);
    log('Task $taskId completed. Active: ${_activeTasks.length}, Pending: ${_pendingTasks.length}');
    
    // Start next task from queue if available
    if (_pendingTasks.isNotEmpty && canStartTask()) {
      return _pendingTasks.first;
    }
    return null;
  }
  
  /// Add metadata task to queue
  void enqueueMetadata(int taskId) {
    if (!_pendingMetadataTasks.contains(taskId) && 
        !_activeMetadataTasks.contains(taskId)) {
      _pendingMetadataTasks.add(taskId);
      log('Metadata task $taskId added to queue. Queue size: ${_pendingMetadataTasks.length}');
    }
  }
  
  /// Start metadata download
  bool startMetadata(int taskId) {
    if (canStartMetadata()) {
      _pendingMetadataTasks.remove(taskId);
      _activeMetadataTasks.add(taskId);
      log('Metadata task $taskId started. Active: ${_activeMetadataTasks.length}');
      return true;
    }
    return false;
  }
  
  /// Complete metadata download
  /// Returns the next metadata task ID to start, if any
  int? completeMetadata(int taskId) {
    _activeMetadataTasks.remove(taskId);
    log('Metadata task $taskId completed. Active: ${_activeMetadataTasks.length}');
    
    // Start next metadata task from queue if available
    if (_pendingMetadataTasks.isNotEmpty && canStartMetadata()) {
      return _pendingMetadataTasks.first;
    }
    return null;
  }
  
  /// Get queue position for a task (0-based)
  int? getQueuePosition(int taskId) {
    final list = _pendingTasks.toList();
    final index = list.indexOf(taskId);
    return index >= 0 ? index : null;
  }
  
  /// Get current statistics
  Map<String, dynamic> getStats() {
    return {
      'activeTasks': _activeTasks.length,
      'pendingTasks': _pendingTasks.length,
      'activeMetadata': _activeMetadataTasks.length,
      'pendingMetadata': _pendingMetadataTasks.length,
      'maxConcurrentTasks': maxConcurrentTasks,
      'maxConcurrentMetadata': maxConcurrentMetadata,
    };
  }
  
  /// Check if task is active
  bool isTaskActive(int taskId) => _activeTasks.contains(taskId);
  
  /// Check if task is pending
  bool isTaskPending(int taskId) => _pendingTasks.contains(taskId);
  
  /// Remove a task completely
  void removeTask(int taskId) {
    _activeTasks.remove(taskId);
    _pendingTasks.remove(taskId);
    _activeMetadataTasks.remove(taskId);
    _pendingMetadataTasks.remove(taskId);
  }
  
  /// Clear all queues
  void clear() {
    _activeTasks.clear();
    _pendingTasks.clear();
    _activeMetadataTasks.clear();
    _pendingMetadataTasks.clear();
  }
}
```

---

## 3. Resource Isolation

### Ensure each task uses unique ports and resources

```dart
// lib/src/services/torrent_resource_manager.dart

import 'dart:developer';

/// Manages resource allocation for torrent tasks
class TorrentResourceManager {
  static const int basePort = 6881;
  static const int maxPort = 6980; // Allow 100 tasks max
  
  final Set<int> _usedPorts = {};
  
  /// Allocate a unique port for a task
  int allocatePort(int taskId) {
    // Try to use predictable port based on taskId
    int preferredPort = basePort + (taskId % (maxPort - basePort));
    
    // If preferred port is taken, find next available
    if (_usedPorts.contains(preferredPort)) {
      for (int port = basePort; port <= maxPort; port++) {
        if (!_usedPorts.contains(port)) {
          preferredPort = port;
          break;
        }
      }
    }
    
    _usedPorts.add(preferredPort);
    log('Allocated port $preferredPort for task $taskId');
    return preferredPort;
  }
  
  /// Release a port when task completes
  void releasePort(int port) {
    _usedPorts.remove(port);
    log('Released port $port');
  }
  
  /// Get connection limits per task based on active tasks
  int getConnectionLimit(int activeTasks) {
    // Distribute connections fairly
    const maxTotalConnections = 200;
    return (maxTotalConnections / activeTasks).floor().clamp(20, 100);
  }
  
  /// Get bandwidth limit per task (bytes per second)
  /// null means no limit
  int? getBandwidthLimit(int activeTasks, {int? totalBandwidthLimit}) {
    if (totalBandwidthLimit == null) return null;
    return (totalBandwidthLimit / activeTasks).floor();
  }
  
  /// Clear all allocations
  void clear() {
    _usedPorts.clear();
  }
}
```

### Apply resource configuration when creating TorrentTask

```dart
// In torrent_task_handler.dart - modification to startDownload method

// Add these fields to _TorrentTaskHandler class:
final _resourceManager = TorrentResourceManager();
final Map<int, int> _taskPorts = {}; // Track which port each task uses

// When creating TorrentTask (in MetaDataDownloadComplete handler):
final port = _resourceManager.allocatePort(taskId);
_taskPorts[taskId] = port;

final connectionLimit = _resourceManager.getConnectionLimit(_tasks.length + 1);

// Create torrent task with resource configuration
// NOTE: Check dtorrent_task_v2 documentation for actual parameter names
final torrentTask = TorrentTask.newTask(
  torrentModel,
  savePath,
  false,
  magnet.webSeeds.isNotEmpty ? magnet.webSeeds : null,
  magnet.acceptableSources.isNotEmpty ? magnet.acceptableSources : null,
  // Add these configurations if supported by the library:
  // port: port,
  // maxConnections: connectionLimit,
);

// In cleanup/stop methods:
final port = _taskPorts.remove(taskId);
if (port != null) {
  _resourceManager.releasePort(port);
}
```

---

## 4. Comprehensive Logging

### Add detailed logging throughout the download process

```dart
// lib/src/services/download_logger.dart

import 'dart:developer' as developer;
import 'dart:io';

/// Centralized logging for torrent downloads
class DownloadLogger {
  final bool debugMode;
  final File? logFile;
  
  DownloadLogger({
    this.debugMode = false,
    this.logFile,
  });
  
  void log(String message, {String? prefix}) {
    final timestamp = DateTime.now().toIso8601String();
    final formattedMessage = '[$timestamp]${prefix != null ? ' [$prefix]' : ''} $message';
    
    // Always log to console in debug mode
    if (debugMode) {
      developer.log(formattedMessage);
    }
    
    // Write to file if configured
    logFile?.writeAsStringSync(
      '$formattedMessage\n',
      mode: FileMode.append,
    );
  }
  
  void logTaskReceived(int taskId, String magnetUri, String savePath) {
    log(
      '=== TASK RECEIVED ===\n'
      'Task ID: $taskId\n'
      'Magnet URI: $magnetUri\n'
      'Save Path: $savePath',
      prefix: 'TASK',
    );
  }
  
  void logTaskStateChange(int taskId, String fromState, String toState) {
    log(
      'Task $taskId: $fromState → $toState',
      prefix: 'STATE',
    );
  }
  
  void logQueueStats(Map<String, dynamic> stats) {
    log(
      'Queue Stats: Active=${stats['activeTasks']}, '
      'Pending=${stats['pendingTasks']}, '
      'Max=${stats['maxConcurrentTasks']}',
      prefix: 'QUEUE',
    );
  }
  
  void logMetadataProgress(int taskId, double progress) {
    log(
      'Task $taskId metadata: ${progress.toStringAsFixed(1)}%',
      prefix: 'METADATA',
    );
  }
  
  void logDownloadProgress(
    int taskId,
    double progress,
    int downloadSpeed,
    int uploadSpeed,
    int peers,
  ) {
    log(
      'Task $taskId: ${(progress * 100).toStringAsFixed(1)}% | '
      '↓${_formatSpeed(downloadSpeed)} ↑${_formatSpeed(uploadSpeed)} | '
      'Peers: $peers',
      prefix: 'PROGRESS',
    );
  }
  
  void logError(int taskId, String error, {StackTrace? stackTrace}) {
    log(
      'Task $taskId ERROR: $error${stackTrace != null ? '\n$stackTrace' : ''}',
      prefix: 'ERROR',
    );
  }
  
  void logTaskCompleted(int taskId, int totalBytes) {
    log(
      'Task $taskId COMPLETED: ${_formatBytes(totalBytes)}',
      prefix: 'COMPLETE',
    );
  }
  
  void logResourceAllocation(int taskId, int port, int connectionLimit) {
    log(
      'Task $taskId: Port=$port, MaxConnections=$connectionLimit',
      prefix: 'RESOURCE',
    );
  }
  
  String _formatSpeed(int bytesPerSecond) {
    final bytes = bytesPerSecond * 1000;
    if (bytes < 1024) return '$bytes B/s';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB/s';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB/s';
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
```

---

## 5. Metadata Queue Manager

### Handle metadata downloads sequentially

```dart
// lib/src/services/metadata_queue_manager.dart

import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:typed_data';
import 'package:dtorrent_parser/dtorrent_parser.dart';
import 'package:dtorrent_task_v2/dtorrent_task_v2.dart';

/// Manages sequential metadata downloads
class MetadataQueueManager {
  final Queue<_MetadataRequest> _queue = Queue();
  _MetadataRequest? _current;
  bool _isProcessing = false;
  
  /// Add a metadata download request to the queue
  Future<Uint8List> requestMetadata(
    int taskId,
    String magnetUri,
    void Function(double progress) onProgress,
  ) async {
    final completer = Completer<Uint8List>();
    
    final request = _MetadataRequest(
      taskId: taskId,
      magnetUri: magnetUri,
      completer: completer,
      onProgress: onProgress,
    );
    
    _queue.add(request);
    log('Metadata request added for task $taskId. Queue size: ${_queue.length}');
    
    // Start processing if not already
    if (!_isProcessing) {
      _processNext();
    }
    
    return completer.future;
  }
  
  /// Process the next metadata request in queue
  void _processNext() {
    if (_queue.isEmpty) {
      _isProcessing = false;
      _current = null;
      log('Metadata queue empty');
      return;
    }
    
    _isProcessing = true;
    _current = _queue.removeFirst();
    
    log('Processing metadata for task ${_current!.taskId}. Remaining in queue: ${_queue.length}');
    
    final metadata = MetadataDownloader.fromMagnet(_current!.magnetUri);
    final listener = metadata.createListener();
    
    listener
      ..on<MetaDataDownloadProgress>((event) {
        _current?.onProgress(event.progress.toDouble());
      })
      ..on<MetaDataDownloadComplete>((event) {
        log('Metadata complete for task ${_current!.taskId}');
        _current?.completer.complete(Uint8List.fromList(event.data));
        listener.dispose();
        
        // Process next in queue
        _processNext();
      })
      ..on<MetaDataDownloadFailed>((event) {
        log('Metadata failed for task ${_current!.taskId}: ${event.error}');
        _current?.completer.completeError(event.error);
        listener.dispose();
        
        // Process next in queue
        _processNext();
      });
    
    metadata.startDownload();
    
    // Set timeout (5 minutes)
    Timer(const Duration(minutes: 5), () {
      if (_current?.taskId == _current?.taskId) {
        log('Metadata timeout for task ${_current!.taskId}');
        metadata.stop();
        _current?.completer.completeError('Metadata download timeout');
        listener.dispose();
        _processNext();
      }
    });
  }
  
  /// Cancel a specific metadata request
  void cancel(int taskId) {
    _queue.removeWhere((req) => req.taskId == taskId);
    if (_current?.taskId == taskId) {
      _current?.completer.completeError('Cancelled by user');
      _processNext();
    }
  }
  
  /// Clear all pending requests
  void clear() {
    for (var request in _queue) {
      request.completer.completeError('Queue cleared');
    }
    _queue.clear();
    
    if (_current != null) {
      _current?.completer.completeError('Queue cleared');
      _current = null;
    }
    
    _isProcessing = false;
  }
  
  /// Get queue position for a task
  int? getQueuePosition(int taskId) {
    if (_current?.taskId == taskId) return 0;
    
    final list = _queue.toList();
    final index = list.indexWhere((req) => req.taskId == taskId);
    return index >= 0 ? index + 1 : null;
  }
}

class _MetadataRequest {
  final int taskId;
  final String magnetUri;
  final Completer<Uint8List> completer;
  final void Function(double progress) onProgress;
  
  _MetadataRequest({
    required this.taskId,
    required this.magnetUri,
    required this.completer,
    required this.onProgress,
  });
}
```

---

## 6. Task State Machine

### Track task states and validate transitions

```dart
// lib/src/models/task_state.dart

enum TaskState {
  /// Task received, preparing to start
  initializing,
  
  /// Waiting in queue for slot
  queued,
  
  /// Downloading torrent metadata
  downloadingMetadata,
  
  /// Creating TorrentTask instance
  starting,
  
  /// Actively downloading files
  downloading,
  
  /// Temporarily paused by user
  paused,
  
  /// Permanently stopped by user
  stopped,
  
  /// Download completed successfully
  completed,
  
  /// Error occurred
  failed,
}

/// Manages task state transitions
class TaskStateManager {
  final Map<int, TaskState> _states = {};
  
  /// Get current state for a task
  TaskState? getState(int taskId) => _states[taskId];
  
  /// Set state for a task
  void setState(int taskId, TaskState state) {
    final oldState = _states[taskId];
    _states[taskId] = state;
    
    if (oldState != null) {
      print('Task $taskId: ${oldState.name} → ${state.name}');
    } else {
      print('Task $taskId: initialized as ${state.name}');
    }
  }
  
  /// Validate if transition is allowed
  bool canTransition(int taskId, TaskState newState) {
    final currentState = _states[taskId];
    if (currentState == null) return true;
    
    // Define allowed transitions
    switch (currentState) {
      case TaskState.initializing:
        return newState == TaskState.queued ||
               newState == TaskState.downloadingMetadata ||
               newState == TaskState.failed;
               
      case TaskState.queued:
        return newState == TaskState.downloadingMetadata ||
               newState == TaskState.stopped ||
               newState == TaskState.failed;
               
      case TaskState.downloadingMetadata:
        return newState == TaskState.starting ||
               newState == TaskState.stopped ||
               newState == TaskState.failed;
               
      case TaskState.starting:
        return newState == TaskState.downloading ||
               newState == TaskState.stopped ||
               newState == TaskState.failed;
               
      case TaskState.downloading:
        return newState == TaskState.paused ||
               newState == TaskState.stopped ||
               newState == TaskState.completed ||
               newState == TaskState.failed;
               
      case TaskState.paused:
        return newState == TaskState.downloading ||
               newState == TaskState.stopped ||
               newState == TaskState.failed;
               
      case TaskState.stopped:
      case TaskState.completed:
      case TaskState.failed:
        return false; // Terminal states
    }
  }
  
  /// Remove task from tracking
  void removeTask(int taskId) {
    _states.remove(taskId);
  }
  
  /// Clear all states
  void clear() {
    _states.clear();
  }
  
  /// Get all tasks in a specific state
  List<int> getTasksInState(TaskState state) {
    return _states.entries
        .where((entry) => entry.value == state)
        .map((entry) => entry.key)
        .toList();
  }
}
```

---

## 7. Updated TorrentTaskHandler

### Integrate all the components together

```dart
// lib/src/services/torrent_task_handler.dart
// This is a MODIFIED version showing key changes

import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:b_encode_decode/b_encode_decode.dart';
import 'package:dtorrent_parser/dtorrent_parser.dart';
import 'package:dtorrent_task_v2/dtorrent_task_v2.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/torrent_service_models.dart';

// Import new helpers
import 'notification_manager.dart';
import 'task_queue_manager.dart';
import 'torrent_resource_manager.dart';
import 'download_logger.dart';
import 'metadata_queue_manager.dart';
import 'task_state.dart';

const String notificationChannelId = 'torrent_downloads';
const int notificationId = 888;

@pragma('vm:entry-point')
void onStartBackgroundService(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final handler = _TorrentTaskHandler(service, notificationsPlugin);

  service.on('startDownload').listen((event) {
    if (event != null) {
      try {
        final request = StartDownloadRequest.fromJson(event);
        handler.startDownload(request);
      } catch (e) {
        log('Error parsing startDownload event: $e');
      }
    }
  });

  service.on('pauseDownload').listen((event) {
    if (event != null) {
      try {
        final request = DownloadControlRequest.fromJson(event);
        handler.pauseDownload(request);
      } catch (e) {
        log('Error parsing pauseDownload event: $e');
      }
    }
  });

  service.on('resumeDownload').listen((event) {
    if (event != null) {
      try {
        final request = DownloadControlRequest.fromJson(event);
        handler.resumeDownload(request);
      } catch (e) {
        log('Error parsing resumeDownload event: $e');
      }
    }
  });

  service.on('stopDownload').listen((event) {
    if (event != null) {
      try {
        final request = DownloadControlRequest.fromJson(event);
        handler.stopDownload(request);
      } catch (e) {
        log('Error parsing stopDownload event: $e');
      }
    }
  });
  
  service.on('stopService').listen((event) {
    handler.cleanup();
    service.stopSelf();
  });

  // Periodic update for service notification
  Timer.periodic(const Duration(seconds: 5), (timer) {
    handler.updateServiceNotification();
  });

  log('_TorrentTaskHandler: Service started with enhanced concurrency support');
}

class _TorrentTaskHandler {
  final ServiceInstance service;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  // Core task management
  final Map<int, TorrentTask> _tasks = {};
  final Map<int, EventsListener<TaskEvent>> _taskListeners = {};
  final Map<int, String> _taskTitles = {}; // Store movie titles
  
  // Enhanced managers
  late final TorrentNotificationManager _notificationManager;
  late final TaskQueueManager _queueManager;
  late final TorrentResourceManager _resourceManager;
  late final DownloadLogger _logger;
  late final MetadataQueueManager _metadataQueue;
  late final TaskStateManager _stateManager;
  
  // Resource tracking
  final Map<int, int> _taskPorts = {};
  
  // Progress tracking for throttling
  final Map<int, double> _lastReportedProgress = {};
  final Map<int, DateTime> _lastNotificationUpdate = {};

  _TorrentTaskHandler(this.service, this.notificationsPlugin) {
    _notificationManager = TorrentNotificationManager(notificationsPlugin);
    _queueManager = TaskQueueManager(
      maxConcurrentTasks: 2, // TODO: Make configurable
      maxConcurrentMetadata: 1,
    );
    _resourceManager = TorrentResourceManager();
    _logger = DownloadLogger(debugMode: true); // TODO: Make configurable
    _metadataQueue = MetadataQueueManager();
    _stateManager = TaskStateManager();
  }

  /// Update the main service notification with aggregate stats
  void updateServiceNotification() {
    if (_tasks.isEmpty) return;

    final totalProgress = _tasks.values
        .map((task) => task.progress)
        .reduce((a, b) => a + b) / _tasks.length;

    _notificationManager.updateServiceNotification(
      activeDownloads: _tasks.length,
      averageProgress: totalProgress,
    );
  }

  Future<void> startDownload(StartDownloadRequest request) async {
    final taskId = request.taskId;
    final magnetUri = request.magnetUri;
    final savePath = request.savePath;
    final movieTitle = request.movieTitle;

    try {
      _logger.logTaskReceived(taskId, magnetUri, savePath);
      _stateManager.setState(taskId, TaskState.initializing);
      _taskTitles[taskId] = movieTitle;

      // Check if task already exists
      if (_tasks.containsKey(taskId)) {
        _logger.log('Task $taskId already running', prefix: 'WARNING');
        return;
      }

      // Parse magnet link
      final magnet = MagnetParser.parse(magnetUri);
      if (magnet == null) {
        throw Exception('Invalid magnet URI');
      }

      // Check if we can start immediately or need to queue
      if (!_queueManager.canStartTask()) {
        _queueManager.enqueueTask(taskId);
        _stateManager.setState(taskId, TaskState.queued);
        
        final position = _queueManager.getQueuePosition(taskId);
        _notificationManager.updateTaskNotification(
          taskId: taskId,
          title: movieTitle,
          body: 'Queued${position != null ? " ($position ahead)" : ""}',
        );
        
        _sendProgressUpdate(ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.queued,
        ));
        
        _logger.logQueueStats(_queueManager.getStats());
        return;
      }

      // Mark as started in queue
      _queueManager.startTask(taskId);
      
      // Start metadata download
      await _downloadMetadataAndStart(taskId, magnet, savePath, movieTitle);
      
    } catch (e, s) {
      _logger.logError(taskId, e.toString(), stackTrace: s);
      _stateManager.setState(taskId, TaskState.failed);
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.failed,
          error: e.toString(),
        ),
      );
      
      // Try to start next queued task
      _startNextQueuedTask();
    }
  }

  Future<void> _downloadMetadataAndStart(
    int taskId,
    MagnetModel magnet,
    String savePath,
    String movieTitle,
  ) async {
    try {
      _stateManager.setState(taskId, TaskState.downloadingMetadata);
      
      _notificationManager.updateTaskNotification(
        taskId: taskId,
        title: movieTitle,
        body: 'Downloading metadata...',
      );

      // Request metadata through queue manager
      final metadataBytes = await _metadataQueue.requestMetadata(
        taskId,
        magnet.toString(),
        (progress) {
          _logger.logMetadataProgress(taskId, progress);
          _sendProgressUpdate(
            ProgressUpdate(
              taskId: taskId,
              status: DownloadStatus.downloadingMetadata,
              progress: progress,
            ),
          );
        },
      );

      // Parse torrent metadata
      final msg = decode(metadataBytes);
      final torrentMap = <String, dynamic>{'info': msg};
      final torrentModel = parseTorrentFileContent(torrentMap);

      if (torrentModel == null) {
        throw Exception('Failed to parse torrent metadata');
      }

      _stateManager.setState(taskId, TaskState.starting);

      // Allocate resources
      final port = _resourceManager.allocatePort(taskId);
      _taskPorts[taskId] = port;
      final connectionLimit = _resourceManager.getConnectionLimit(_tasks.length + 1);
      
      _logger.logResourceAllocation(taskId, port, connectionLimit);

      // Create torrent task
      // NOTE: Modify based on actual dtorrent_task_v2 API
      final torrentTask = TorrentTask.newTask(
        torrentModel,
        savePath,
        false,
        magnet.webSeeds.isNotEmpty ? magnet.webSeeds : null,
        magnet.acceptableSources.isNotEmpty ? magnet.acceptableSources : null,
      );

      // Apply selected files if specified
      if (magnet.selectedFileIndices != null &&
          magnet.selectedFileIndices!.isNotEmpty) {
        torrentTask.applySelectedFiles(magnet.selectedFileIndices!);
      }

      await torrentTask.start();

      // Add trackers
      if (magnet.trackers.isNotEmpty) {
        final infoHashBuffer = Uint8List.fromList(
          List.generate(magnet.infoHashString.length ~/ 2, (i) {
            final s = magnet.infoHashString.substring(i * 2, i * 2 + 2);
            return int.parse(s, radix: 16);
          }),
        );
        for (var trackerUrl in magnet.trackers) {
          torrentTask.startAnnounceUrl(trackerUrl, infoHashBuffer);
        }
      }

      // Store task
      _tasks[taskId] = torrentTask;
      _stateManager.setState(taskId, TaskState.downloading);

      final totalBytes = torrentModel.length;

      // Send initial progress
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.downloading,
          progress: 0.0,
          downloadSpeed: 0,
          uploadSpeed: 0,
          peers: 0,
          seeders: 0,
          downloadedBytes: 0,
          totalBytes: totalBytes,
        ),
      );

      // Start progress monitoring
      _startProgressMonitoring(taskId, torrentTask, movieTitle, totalBytes);
      
      _logger.log('Task $taskId started successfully', prefix: 'SUCCESS');
      _logger.logQueueStats(_queueManager.getStats());

    } catch (e, s) {
      _logger.logError(taskId, e.toString(), stackTrace: s);
      _stateManager.setState(taskId, TaskState.failed);
      _queueManager.removeTask(taskId);
      
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.failed,
          error: e.toString(),
        ),
      );
      
      _startNextQueuedTask();
    }
  }

  void _startProgressMonitoring(
    int taskId,
    TorrentTask task,
    String movieTitle,
    int totalBytes,
  ) {
    final listener = task.createListener();
    _taskListeners[taskId] = listener;

    listener
      ..on<StateFileUpdated>((event) {
        if (!_tasks.containsKey(taskId)) return;

        final progress = task.progress;
        final downloadSpeed = task.currentDownloadSpeed.toInt();
        final uploadSpeed = task.uploadSpeed.toInt();
        final peers = task.connectedPeersNumber;
        final seeders = task.seederNumber;
        final downloaded = task.downloaded ?? 0;

        // Throttle logging
        final lastProgress = _lastReportedProgress[taskId] ?? 0.0;
        if ((progress - lastProgress).abs() > 0.01) { // Log every 1% change
          _logger.logDownloadProgress(
            taskId,
            progress,
            downloadSpeed,
            uploadSpeed,
            peers,
          );
          _lastReportedProgress[taskId] = progress;
        }

        // Throttle notification updates (max once per 3 seconds)
        final now = DateTime.now();
        final lastUpdate = _lastNotificationUpdate[taskId];
        if (lastUpdate == null || now.difference(lastUpdate).inSeconds >= 3) {
          _notificationManager.updateTaskNotification(
            taskId: taskId,
            title: movieTitle,
            body: '${(progress * 100).toStringAsFixed(1)}% • '
                  '${_formatSpeed(downloadSpeed)} ↓ ${_formatSpeed(uploadSpeed)} ↑',
            progress: (progress * 100).toInt(),
            maxProgress: 100,
          );
          _lastNotificationUpdate[taskId] = now;
        }

        // Send progress update to UI
        _sendProgressUpdate(
          ProgressUpdate(
            taskId: taskId,
            status: DownloadStatus.downloading,
            progress: progress,
            downloadSpeed: downloadSpeed,
            uploadSpeed: uploadSpeed,
            peers: peers,
            seeders: seeders,
            downloadedBytes: downloaded.toInt(),
            totalBytes: totalBytes,
          ),
        );
      })
      ..on<TaskCompleted>((event) {
        _logger.logTaskCompleted(taskId, totalBytes);
        _stateManager.setState(taskId, TaskState.completed);

        final downloaded = task.downloaded ?? 0;

        _notificationManager.updateTaskNotification(
          taskId: taskId,
          title: movieTitle,
          body: 'Download completed!',
          progress: 100,
          maxProgress: 100,
        );

        _sendProgressUpdate(
          ProgressUpdate(
            taskId: taskId,
            status: DownloadStatus.completed,
            progress: 1.0,
            downloadedBytes: downloaded.toInt(),
            totalBytes: totalBytes,
          ),
        );

        // Clean up this task
        _cleanupTask(taskId);
        
        // Start next queued task
        _startNextQueuedTask();
      })
      ..on<TaskStopped>((event) {
        _logger.log('Task stopped: $taskId', prefix: 'STOP');
        _stateManager.setState(taskId, TaskState.stopped);
        
        _cleanupTask(taskId);

        _sendProgressUpdate(
          ProgressUpdate(
            taskId: taskId,
            status: DownloadStatus.stopped,
          ),
        );
        
        // Start next queued task
        _startNextQueuedTask();
      });
  }

  void pauseDownload(DownloadControlRequest request) {
    final taskId = request.taskId;
    final task = _tasks[taskId];
    if (task != null && _stateManager.canTransition(taskId, TaskState.paused)) {
      task.pause();
      _stateManager.setState(taskId, TaskState.paused);
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.paused,
        ),
      );
      _logger.log('Download paused: $taskId', prefix: 'PAUSE');
    }
  }

  void resumeDownload(DownloadControlRequest request) {
    final taskId = request.taskId;
    final task = _tasks[taskId];
    if (task != null && _stateManager.canTransition(taskId, TaskState.downloading)) {
      task.start();
      _stateManager.setState(taskId, TaskState.downloading);
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.downloading,
        ),
      );
      _logger.log('Download resumed: $taskId', prefix: 'RESUME');
    }
  }

  Future<void> stopDownload(DownloadControlRequest request) async {
    final taskId = request.taskId;
    
    // Remove from queue if pending
    _queueManager.removeTask(taskId);
    _metadataQueue.cancel(taskId);
    
    final task = _tasks.remove(taskId);
    if (task != null) {
      await task.stop();
      _cleanupTask(taskId);
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.stopped,
        ),
      );
      _logger.log('Download stopped: $taskId', prefix: 'STOP');
      
      // Start next queued task
      _startNextQueuedTask();
    }
  }

  void _cleanupTask(int taskId) {
    _taskListeners[taskId]?.dispose();
    _taskListeners.remove(taskId);
    _tasks.remove(taskId);
    _taskTitles.remove(taskId);
    _lastReportedProgress.remove(taskId);
    _lastNotificationUpdate.remove(taskId);
    _queueManager.completeTask(taskId);
    
    final port = _taskPorts.remove(taskId);
    if (port != null) {
      _resourceManager.releasePort(port);
    }
    
    _notificationManager.cancelTaskNotification(taskId);
  }

  void _startNextQueuedTask() {
    // Check if we can start another task
    if (_queueManager.canStartTask()) {
      // Get next task from queue
      final nextTaskId = _queueManager.completeTask(-1); // Get without completing
      if (nextTaskId != null) {
        // Reconstruct the request - you'll need to store this info
        _logger.log('Starting next queued task: $nextTaskId', prefix: 'QUEUE');
        // TODO: Store StartDownloadRequest for queued tasks and restart here
      }
    }
  }

  void _sendProgressUpdate(ProgressUpdate update) {
    service.invoke('progressUpdate', update.toJson());
  }

  String _formatSpeed(int bytes) {
    bytes = bytes * 1000;
    if (bytes < 1024) return '$bytes B/s';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB/s';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB/s';
  }

  void cleanup() {
    for (var listener in _taskListeners.values) {
      listener.dispose();
    }

    for (var task in _tasks.values) {
      task.stop();
    }

    _metadataQueue.clear();
    _taskListeners.clear();
    _tasks.clear();
    _taskTitles.clear();
    _queueManager.clear();
    _resourceManager.clear();
    _stateManager.clear();
    _notificationManager.cancelAllTaskNotifications();
  }
}
```

---

## 8. PreferencesService Extensions

### Add configuration options for concurrent downloads

```dart
// lib/src/services/preferences_service.dart
// Add these methods to existing PreferencesService class

// Maximum concurrent downloads
Future<void> setMaxConcurrentDownloads(int value) async {
  await _prefs.setInt('max_concurrent_downloads', value.clamp(1, 5));
}

int get maxConcurrentDownloads {
  return _prefs.getInt('max_concurrent_downloads') ?? 2;
}

// Maximum concurrent metadata downloads
Future<void> setMaxConcurrentMetadata(int value) async {
  await _prefs.setInt('max_concurrent_metadata', value.clamp(1, 3));
}

int get maxConcurrentMetadata {
  return _prefs.getInt('max_concurrent_metadata') ?? 1;
}

// Debug logging
Future<void> setDebugLogging(bool value) async {
  await _prefs.setBool('debug_logging', value);
}

bool get debugLogging {
  return _prefs.getBool('debug_logging') ?? false;
}

// Notification update interval (seconds)
Future<void> setNotificationUpdateInterval(int value) async {
  await _prefs.setInt('notification_update_interval', value.clamp(1, 10));
}

int get notificationUpdateInterval {
  return _prefs.getInt('notification_update_interval') ?? 3;
}

// Base torrent port
Future<void> setBaseTorrentPort(int value) async {
  await _prefs.setInt('base_torrent_port', value.clamp(6881, 6980));
}

int get baseTorrentPort {
  return _prefs.getInt('base_torrent_port') ?? 6881;
}
```

---

## Implementation Checklist

- [ ] Create `notification_manager.dart` with separate service and task notifications
- [ ] Create `task_queue_manager.dart` for managing concurrent download limits
- [ ] Create `torrent_resource_manager.dart` for port and resource allocation
- [ ] Create `download_logger.dart` for comprehensive logging
- [ ] Create `metadata_queue_manager.dart` for sequential metadata downloads
- [ ] Create `task_state.dart` for state machine management
- [ ] Update `torrent_task_handler.dart` to integrate all managers
- [ ] Add configuration options to `preferences_service.dart`
- [ ] Test with 2 concurrent downloads
- [ ] Test with 3+ concurrent downloads
- [ ] Monitor logs for issues
- [ ] Adjust concurrent limits based on performance
- [ ] Add UI for user configuration

---

## Testing Commands

```bash
# Build and install in release mode
flutter build apk --release
flutter install --release

# Or for debugging with logs
flutter run --release

# Monitor logs (use filter for clarity)
adb logcat | grep -E "TASK|QUEUE|METADATA|PROGRESS|RESOURCE"
```

---

## Expected Results

After implementing these changes:

1. ✅ Multiple tasks can download simultaneously (up to configured limit)
2. ✅ Tasks beyond limit wait in queue and start automatically
3. ✅ Each task has independent progress tracking
4. ✅ Proper resource isolation (unique ports per task)
5. ✅ Clean notification management (one service + individual task notifications)
6. ✅ Comprehensive logging for debugging
7. ✅ Sequential metadata downloads to avoid conflicts
8. ✅ State machine prevents invalid transitions
9. ✅ Proper cleanup when tasks complete/stop
10. ✅ Next queued task starts automatically

## Notes

- The `dtorrent_task_v2` library documentation should be checked for actual API parameters
- Port configuration might need adjustment based on library capabilities
- Performance testing needed to determine optimal concurrent download limit
- Consider adding bandwidth throttling for better resource distribution
