# Sequential Download Queue Implementation

This guide provides code to implement a simple sequential download queue where **only ONE download runs at a time**. When a download completes, pauses, or stops, the next one in the queue automatically starts.

## Overview

### Current Problem

- Multiple downloads are attempted simultaneously
- Only the first one actually downloads
- Subsequent downloads fail or hang

### Solution

- Implement a sequential queue
- Maximum 1 active download at a time
- Automatic progression to next download when current finishes
- Store pending download requests for later execution

---

## Implementation Steps

### Step 1: Create Sequential Queue Manager

Create a new file: `lib/src/services/sequential_download_queue.dart`

```dart
import 'dart:async';
import 'dart:collection';
import 'dart:developer';

/// Request to start a download with all necessary information
class QueuedDownloadRequest {
  final int taskId;
  final String magnetUri;
  final String savePath;
  final String movieTitle;

  QueuedDownloadRequest({
    required this.taskId,
    required this.magnetUri,
    required this.savePath,
    required this.movieTitle,
  });

  @override
  String toString() => 'QueuedDownloadRequest(taskId: $taskId, title: $movieTitle)';
}

/// Manages sequential download queue - only one download at a time
class SequentialDownloadQueue {
  // Queue of pending downloads
  final Queue<QueuedDownloadRequest> _pendingQueue = Queue();
  
  // Currently active download
  QueuedDownloadRequest? _activeDownload;
  
  // Callback to actually start the download
  final Future<void> Function(QueuedDownloadRequest) _startDownloadCallback;
  
  // Whether queue processing is active
  bool _isProcessing = false;

  SequentialDownloadQueue({
    required Future<void> Function(QueuedDownloadRequest) startDownloadCallback,
  }) : _startDownloadCallback = startDownloadCallback;

  /// Add a download request to the queue
  /// If nothing is downloading, starts immediately
  /// Otherwise, adds to queue and waits
  Future<void> enqueue(QueuedDownloadRequest request) async {
    log('=== Enqueuing download: ${request.taskId} ===');
    log('Title: ${request.movieTitle}');
    log('Current active: ${_activeDownload?.taskId}');
    log('Queue size before: ${_pendingQueue.length}');

    // Check if already active
    if (_activeDownload?.taskId == request.taskId) {
      log('Task ${request.taskId} is already active, ignoring');
      return;
    }

    // Check if already in queue
    if (_pendingQueue.any((r) => r.taskId == request.taskId)) {
      log('Task ${request.taskId} already in queue, ignoring');
      return;
    }

    // Add to queue
    _pendingQueue.add(request);
    log('Added to queue. New queue size: ${_pendingQueue.length}');

    // Start processing if not already
    if (!_isProcessing) {
      log('Queue not processing, starting now');
      _processNext();
    } else {
      log('Queue already processing, task will start when ready');
      log('Position in queue: ${_getQueuePosition(request.taskId)}');
    }
  }

  /// Process the next download in the queue
  void _processNext() {
    if (_isProcessing && _activeDownload != null) {
      log('Already processing, skipping _processNext');
      return;
    }

    if (_pendingQueue.isEmpty) {
      log('=== Queue empty, stopping processing ===');
      _isProcessing = false;
      _activeDownload = null;
      return;
    }

    _isProcessing = true;
    _activeDownload = _pendingQueue.removeFirst();

    log('=== Processing next download: ${_activeDownload!.taskId} ===');
    log('Title: ${_activeDownload!.movieTitle}');
    log('Remaining in queue: ${_pendingQueue.length}');

    // Start the download
    _startDownloadCallback(_activeDownload!).catchError((error) {
      log('Error starting download ${_activeDownload!.taskId}: $error');
      // Continue to next even on error
      _markCurrentComplete();
    });
  }

  /// Mark the current download as complete and process next
  /// Call this when download completes, stops, or fails
  void markCurrentComplete(int taskId) {
    log('=== markCurrentComplete called for task: $taskId ===');
    log('Current active task: ${_activeDownload?.taskId}');

    if (_activeDownload?.taskId != taskId) {
      log('WARNING: Completed taskId ($taskId) does not match active (${_activeDownload?.taskId})');
      // Still process next in case of mismatch
    }

    _markCurrentComplete();
  }

  void _markCurrentComplete() {
    log('=== Marking current download complete ===');
    log('Task: ${_activeDownload?.taskId}');
    log('Remaining in queue: ${_pendingQueue.length}');

    _activeDownload = null;
    _isProcessing = false;

    // Process next download
    if (_pendingQueue.isNotEmpty) {
      log('Starting next download in queue');
      Future.delayed(const Duration(milliseconds: 500), () {
        _processNext();
      });
    } else {
      log('No more downloads in queue');
    }
  }

  /// Remove a specific task from the queue
  /// If it's the active task, moves to next
  void removeTask(int taskId) {
    log('=== Removing task from queue: $taskId ===');

    // Remove from pending queue
    final removedFromQueue = _pendingQueue.removeWhere((r) => r.taskId == taskId);
    if (removedFromQueue > 0) {
      log('Removed task $taskId from pending queue');
    }

    // If it's the active download, mark complete to process next
    if (_activeDownload?.taskId == taskId) {
      log('Removed task $taskId was active, processing next');
      _markCurrentComplete();
    }
  }

  /// Get queue position for a task (0 = active, 1+ = waiting)
  int? getQueuePosition(int taskId) {
    // Check if active
    if (_activeDownload?.taskId == taskId) {
      return 0;
    }

    // Check position in pending queue
    final list = _pendingQueue.toList();
    for (int i = 0; i < list.length; i++) {
      if (list[i].taskId == taskId) {
        return i + 1; // +1 because position 0 is active
      }
    }

    return null;
  }

  int? _getQueuePosition(int taskId) => getQueuePosition(taskId);

  /// Check if a task is currently active
  bool isTaskActive(int taskId) => _activeDownload?.taskId == taskId;

  /// Check if a task is in the queue
  bool isTaskQueued(int taskId) {
    return _pendingQueue.any((r) => r.taskId == taskId);
  }

  /// Get current queue stats
  Map<String, dynamic> getStats() {
    return {
      'activeTaskId': _activeDownload?.taskId,
      'activeTaskTitle': _activeDownload?.movieTitle,
      'pendingCount': _pendingQueue.length,
      'isProcessing': _isProcessing,
      'nextTaskId': _pendingQueue.isNotEmpty ? _pendingQueue.first.taskId : null,
    };
  }

  /// Clear the entire queue and stop processing
  void clear() {
    log('=== Clearing download queue ===');
    _pendingQueue.clear();
    _activeDownload = null;
    _isProcessing = false;
  }

  /// Get list of pending task IDs
  List<int> getPendingTaskIds() {
    return _pendingQueue.map((r) => r.taskId).toList();
  }
}
```

---

### Step 2: Update TorrentTaskHandler

Modify `lib/src/services/torrent_task_handler.dart` to use the queue:

```dart
import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:events_emitter2/src/events_emitter.dart' show EventsListener;
import 'package:b_encode_decode/b_encode_decode.dart';
import 'package:dtorrent_parser/dtorrent_parser.dart';
import 'package:dtorrent_task_v2/dtorrent_task_v2.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/torrent_service_models.dart';
import 'package:ytsmovies/src/services/sequential_download_queue.dart';

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

  log('_TorrentTaskHandler: Service started with sequential queue');
}

class _TorrentTaskHandler {
  final ServiceInstance service;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  // Map to manage downloads
  final Map<int, TorrentTask> _tasks = {};
  final Map<int, MetadataDownloader> _metadataDownloaders = {};
  final Map<int, EventsListener<TaskEvent>> _taskListeners = {};
  final Map<int, String> _taskTitles = {}; // Store movie titles

  // Sequential queue manager
  late final SequentialDownloadQueue _downloadQueue;

  _TorrentTaskHandler(this.service, this.notificationsPlugin) {
    // Initialize queue with callback to actually start downloads
    _downloadQueue = SequentialDownloadQueue(
      startDownloadCallback: _actuallyStartDownload,
    );
  }

  /// Public method that adds to queue instead of starting immediately
  Future<void> startDownload(StartDownloadRequest request) async {
    final taskId = request.taskId;
    final magnetUri = request.magnetUri;
    final savePath = request.savePath;
    final movieTitle = request.movieTitle;

    log('=== startDownload called for task $taskId ===');
    log('Movie: $movieTitle');

    // Store movie title for later
    _taskTitles[taskId] = movieTitle;

    // Check if already running
    if (_tasks.containsKey(taskId)) {
      log('Task $taskId already running, ignoring');
      return;
    }

    // Create queued request
    final queuedRequest = QueuedDownloadRequest(
      taskId: taskId,
      magnetUri: magnetUri,
      savePath: savePath,
      movieTitle: movieTitle,
    );

    // Enqueue the download
    await _downloadQueue.enqueue(queuedRequest);

    // Send initial queued status
    final position = _downloadQueue.getQueuePosition(taskId);
    if (position != null && position > 0) {
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.queued,
        ),
      );

      // Show notification about queue position
      _showNotification(
        taskId,
        movieTitle,
        'Queued - ${position - 1} download(s) ahead',
      );
      
      log('Task $taskId queued at position $position');
    }
  }

  /// Actually start the download (called by queue manager)
  Future<void> _actuallyStartDownload(QueuedDownloadRequest request) async {
    final taskId = request.taskId;
    final magnetUri = request.magnetUri;
    final savePath = request.savePath;
    final movieTitle = request.movieTitle;

    try {
      log('=== _actuallyStartDownload for task $taskId ===');
      log('Magnet URI: $magnetUri');
      log('Save path: $savePath');

      // Check if already running (shouldn't happen, but safety check)
      if (_tasks.containsKey(taskId)) {
        log('Task $taskId already running');
        return;
      }

      // Parse magnet link
      final magnet = MagnetParser.parse(magnetUri);
      if (magnet == null) {
        log('Invalid magnet URI for task $taskId');
        _sendProgressUpdate(
          ProgressUpdate(
            taskId: taskId,
            status: DownloadStatus.failed,
            error: 'Invalid magnet URI',
          ),
        );
        // Mark as complete so queue moves to next
        _downloadQueue.markCurrentComplete(taskId);
        return;
      }

      log('Magnet parsed successfully. Info hash: ${magnet.infoHashString}');

      // Update notification
      _showNotification(
        taskId,
        'Downloading Metadata',
        movieTitle,
      );

      log('Starting metadata download...');

      // Download metadata
      final metadata = MetadataDownloader.fromMagnet(magnetUri);
      _metadataDownloaders[taskId] = metadata;
      final metadataListener = metadata.createListener();

      metadataListener
        ..on<MetaDataDownloadProgress>((event) {
          log('Metadata progress for $taskId: ${event.progress}%');
          _sendProgressUpdate(
            ProgressUpdate(
              taskId: taskId,
              status: DownloadStatus.downloadingMetadata,
              progress: event.progress.toDouble(),
            ),
          );
        })
        ..on<MetaDataDownloadComplete>((event) async {
          log('Metadata complete for $taskId. Data size: ${event.data.length} bytes');

          try {
            // Parse torrent from metadata
            final msg = decode(Uint8List.fromList(event.data));
            final torrentMap = <String, dynamic>{'info': msg};
            final torrentModel = parseTorrentFileContent(torrentMap);

            if (torrentModel == null) {
              throw Exception('Failed to parse torrent metadata');
            }

            // Create torrent task
            final torrentTask = TorrentTask.newTask(
              torrentModel,
              savePath,
              false,
              magnet.webSeeds.isNotEmpty ? magnet.webSeeds : null,
              magnet.acceptableSources.isNotEmpty
                  ? magnet.acceptableSources
                  : null,
            );

            // Apply selected files if specified
            if (magnet.selectedFileIndices != null &&
                magnet.selectedFileIndices!.isNotEmpty) {
              torrentTask.applySelectedFiles(magnet.selectedFileIndices!);
            }

            await torrentTask.start();

            // Transfer peers from metadata downloader
            final metadataPeers = metadata.activePeers;
            for (var peer in metadataPeers) {
              torrentTask.addPeer(peer.address, PeerSource.manual,
                  type: peer.type);
            }

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
            _metadataDownloaders.remove(taskId);

            // Get total size from torrent
            final totalBytes = torrentModel.length;
            log('Total torrent size: $totalBytes bytes');

            // Send initial progress update
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
            _startProgressMonitoring(
                taskId, torrentTask, movieTitle, totalBytes);

            log('Download started successfully for task $taskId');
          } catch (e, s) {
            log('Error processing metadata for $taskId: $e',
                error: e, stackTrace: s);
            _metadataDownloaders.remove(taskId);
            _sendProgressUpdate(
              ProgressUpdate(
                taskId: taskId,
                status: DownloadStatus.failed,
                error: e.toString(),
              ),
            );
            // Mark as complete so queue moves to next
            _downloadQueue.markCurrentComplete(taskId);
          }
        })
        ..on<MetaDataDownloadFailed>((event) {
          log('Metadata download failed for $taskId: ${event.error}');
          _metadataDownloaders.remove(taskId);
          _sendProgressUpdate(
            ProgressUpdate(
              taskId: taskId,
              status: DownloadStatus.failed,
              error: event.error,
            ),
          );
          // Mark as complete so queue moves to next
          _downloadQueue.markCurrentComplete(taskId);
        });

      metadata.startDownload();
    } catch (e, s) {
      log('Error starting download for $taskId: $e', error: e, stackTrace: s);
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.failed,
          error: e.toString(),
        ),
      );
      // Mark as complete so queue moves to next
      _downloadQueue.markCurrentComplete(taskId);
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

        log('Progress update for $taskId: ${(progress * 100).toStringAsFixed(1)}% - Speed: ${_formatSpeed(downloadSpeed)}');

        // Update notification with progress bar
        _showNotification(
          taskId,
          movieTitle,
          '${(progress * 100).toStringAsFixed(1)}% • ${_formatSpeed(downloadSpeed)} ↓ ${_formatSpeed(uploadSpeed)} ↑',
          progress: (progress * 100).toInt(),
          maxProgress: 100,
        );

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
        log('Download completed for $taskId');

        final downloaded = task.downloaded ?? 0;

        // Update notification
        _showNotification(
          taskId,
          movieTitle,
          'Download completed!',
          progress: 100,
          maxProgress: 100,
        );

        // Send completion update
        _sendProgressUpdate(
          ProgressUpdate(
            taskId: taskId,
            status: DownloadStatus.completed,
            progress: 1.0,
            downloadedBytes: downloaded.toInt(),
            totalBytes: totalBytes,
          ),
        );

        // Clean up
        _cleanupTask(taskId);
        
        // Mark as complete in queue to start next download
        _downloadQueue.markCurrentComplete(taskId);
      })
      ..on<TaskFileCompleted>((event) {
        log('File completed for $taskId: ${event.file.originalFileName}');
      })
      ..on<TaskStopped>((event) {
        log('Task stopped: $taskId');

        // Clean up
        _cleanupTask(taskId);

        _sendProgressUpdate(
          ProgressUpdate(
            taskId: taskId,
            status: DownloadStatus.stopped,
          ),
        );

        // Mark as complete in queue to start next download
        _downloadQueue.markCurrentComplete(taskId);
      });
  }

  void pauseDownload(DownloadControlRequest request) {
    final taskId = request.taskId;
    final task = _tasks[taskId];
    if (task != null) {
      task.pause();
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.paused,
        ),
      );
      log('Download paused: $taskId');
      
      // When paused, move to next in queue
      _downloadQueue.markCurrentComplete(taskId);
    }
  }

  void resumeDownload(DownloadControlRequest request) {
    final taskId = request.taskId;
    log('=== Resuming download for $taskId ===');
    
    final task = _tasks[taskId];
    if (task != null) {
      // Task already exists, just resume it
      task.start();
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.downloading,
        ),
      );
      log('Download resumed: $taskId');
    } else {
      // Task doesn't exist, need to re-add to queue
      log('Task $taskId not found, cannot resume directly');
      // Note: To properly resume, you'd need to store the original request
      // For now, the UI should handle re-adding to queue
    }
  }

  Future<void> stopDownload(DownloadControlRequest request) async {
    final taskId = request.taskId;
    
    // Remove from queue if it's waiting
    _downloadQueue.removeTask(taskId);
    
    // Stop metadata download if in progress
    final metadata = _metadataDownloaders.remove(taskId);
    if (metadata != null) {
      metadata.stop();
      log('Stopped metadata download for $taskId');
    }
    
    // Stop torrent task if exists
    final task = _tasks.remove(taskId);
    if (task != null) {
      await task.stop();
      _cleanupTask(taskId);
      log('Download stopped: $taskId');
    }
    
    _sendProgressUpdate(
      ProgressUpdate(
        taskId: taskId,
        status: DownloadStatus.stopped,
      ),
    );
  }

  void _cleanupTask(int taskId) {
    _taskListeners[taskId]?.dispose();
    _taskListeners.remove(taskId);
    _tasks.remove(taskId);
    _taskTitles.remove(taskId);
  }

  void _sendProgressUpdate(ProgressUpdate update) {
    service.invoke(
      'progressUpdate',
      update.toJson(),
    );
  }

  Future<void> _showNotification(
    int id,
    String title,
    String body, {
    int? progress,
    int? maxProgress,
  }) async {
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
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
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
    // Clean up all running tasks
    for (var listener in _taskListeners.values) {
      listener.dispose();
    }

    for (var metadata in _metadataDownloaders.values) {
      metadata.stop();
    }

    for (var task in _tasks.values) {
      task.stop();
    }

    _taskListeners.clear();
    _metadataDownloaders.clear();
    _tasks.clear();
    _taskTitles.clear();
    _downloadQueue.clear();
  }
}
```

---

### Step 3: Update DownloadStatus enum (if needed)

Make sure your `DownloadStatus` enum includes a `queued` state in `lib/src/models/download_task.dart`:

```dart
enum DownloadStatus {
  queued,              // Waiting in queue
  downloadingMetadata, // Downloading torrent metadata
  downloading,         // Actively downloading
  paused,              // Paused by user
  stopped,             // Stopped by user
  completed,           // Download complete
  failed,              // Download failed
}
```

---

## How It Works

### Flow Diagram

```
User adds Download 1
    ↓
Queue: [Download 1]
Active: Download 1 starts
    ↓
User adds Download 2
    ↓
Queue: [Download 2]
Active: Download 1 (still running)
    ↓
Download 1 completes
    ↓
Queue: []
Active: Download 2 starts automatically
    ↓
User adds Download 3
    ↓
Queue: [Download 3]
Active: Download 2 (still running)
    ↓
User pauses Download 2
    ↓
Queue: []
Active: Download 3 starts automatically
    ↓
Download 3 completes
    ↓
Queue: []
Active: None (all done)
```

### Key Points

1. **Only ONE active download** at any time
2. **Automatic progression** when current download:
   - Completes
   - Stops
   - Pauses
   - Fails
3. **Queue position tracking** for UI display
4. **Simple and reliable** - no complex concurrency issues

---

## Testing

### Test Scenario 1: Sequential Downloads

```dart
// Add three downloads in quick succession
await downloadService.startDownload(taskId: 1, ...); // Starts immediately
await downloadService.startDownload(taskId: 2, ...); // Goes to queue position 1
await downloadService.startDownload(taskId: 3, ...); // Goes to queue position 2

// Expected behavior:
// 1. Task 1 downloads
// 2. When Task 1 completes → Task 2 starts automatically
// 3. When Task 2 completes → Task 3 starts automatically
```

### Test Scenario 2: Pause Moves to Next

```dart
// Task 1 is downloading, Task 2 is in queue
await downloadService.pauseDownload(taskId: 1);

// Expected behavior:
// 1. Task 1 pauses
// 2. Task 2 immediately starts downloading
```

### Test Scenario 3: Stop While Queued

```dart
// Task 1 is downloading, Task 2 and 3 are in queue
await downloadService.stopDownload(taskId: 2);

// Expected behavior:
// 1. Task 2 is removed from queue
// 2. Task 1 continues downloading
// 3. When Task 1 completes → Task 3 starts (Task 2 was removed)
```

---

## Monitoring Queue Status

Add logging to see queue status:

```dart
// In your UI or service, periodically log queue stats
Timer.periodic(const Duration(seconds: 10), (timer) {
  final stats = handler._downloadQueue.getStats();
  log('Queue Stats: ${stats}');
  // Output: {activeTaskId: 1, activeTaskTitle: "Movie Title", pendingCount: 2, ...}
});
```

---

## UI Updates

Update your UI to show queue status:

```dart
// In your download list widget
Widget build(BuildContext context) {
  return BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
    builder: (context, state) {
      final task = state.downloads[taskId];
      
      if (task?.status == DownloadStatus.queued) {
        // Show queue position
        return Text('Queued - Position: ${queuePosition}');
      } else if (task?.status == DownloadStatus.downloading) {
        return Text('Downloading: ${task.progress * 100}%');
      }
      
      // ... other statuses
    },
  );
}
```

---

## Benefits of This Approach

✅ **Simple**: One class handles all queuing logic  
✅ **Reliable**: Only one download at a time eliminates conflicts  
✅ **Automatic**: Next download starts without user intervention  
✅ **Flexible**: Easy to pause/resume and move through queue  
✅ **Debuggable**: Clear logs show exactly what's happening  
✅ **No resource conflicts**: Single download = no port/bandwidth issues  

---

## Troubleshooting

### Issue: Next download doesn't start

**Check:**

- Is `markCurrentComplete()` being called when download finishes?
- Check logs for "=== Marking current download complete ==="
- Verify `_processNext()` is being called

### Issue: Downloads start simultaneously

**Check:**

- Is queue manager initialized correctly?
- Is `_actuallyStartDownload` being used instead of direct start?
- Check logs for "Already processing, skipping _processNext"

### Issue: Queue gets stuck

**Check:**

- Is there an error preventing completion?
- Check logs for exceptions in `_actuallyStartDownload`
- Verify cleanup is happening in all code paths (success, error, stop)

---

## Future Enhancements (Optional)

Once basic sequential queue works, you can add:

1. **Priority queue**: Let users prioritize certain downloads
2. **Concurrent limit**: Change from 1 to N downloads (e.g., 2-3)
3. **Retry logic**: Automatically retry failed downloads
4. **Persistence**: Save queue to disk so it survives app restart
5. **Reordering**: Let users reorder queued downloads

---

## Summary

This implementation provides a **simple, reliable sequential download queue** where:

- 📥 Only **ONE** download runs at a time
- ⏭️ Next download **starts automatically** when current finishes
- 🎯 **No conflicts** or resource issues
- 📊 **Queue position** visible to users
- 🔄 **Pause/stop** moves to next download immediately

The key is using the `SequentialDownloadQueue` class to manage when downloads actually start, ensuring only one is ever active at a time.
