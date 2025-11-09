import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:b_encode_decode/b_encode_decode.dart';
import 'package:dtorrent_parser/dtorrent_parser.dart';
import 'package:dtorrent_task_v2/dtorrent_task_v2.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Entry point for the background isolate
@pragma('vm:entry-point')
void startTorrentCallback() {
  FlutterForegroundTask.setTaskHandler(TorrentTaskHandler());
}

/// Background task handler for torrent downloads
class TorrentTaskHandler extends TaskHandler {
  // Map to manage multiple simultaneous downloads
  // Key: taskId, Value: TorrentTask
  final Map<String, TorrentTask> _tasks = {};
  final Map<String, MetadataDownloader> _metadataDownloaders = {};
  final Map<String, dynamic> _taskListeners = {};

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log('TorrentTaskHandler: Service started');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This is called periodically (every 5 seconds by default)
    // Update notification with overall progress
    if (_tasks.isNotEmpty) {
      final totalProgress =
          _tasks.values.map((task) => task.progress).reduce((a, b) => a + b) /
              _tasks.length;

      final activeCount = _tasks.length;

      FlutterForegroundTask.updateService(
        notificationTitle: 'Torrent Downloads',
        notificationText:
            '$activeCount active download(s) • ${(totalProgress * 100).toStringAsFixed(1)}% complete',
      );
    }
  }

  @override
  void onReceiveData(Object data) {
    // Receive data from UI
    if (data is! Map<String, dynamic>) return;

    final action = data['action'] as String?;
    final taskId = data['taskId'] as String?;

    switch (action) {
      case 'startDownload':
        final magnetUri = data['magnetUri'] as String?;
        final savePath = data['savePath'] as String?;
        final movieTitle = data['movieTitle'] as String?;

        if (magnetUri != null && savePath != null && taskId != null) {
          _startDownload(taskId, magnetUri, savePath, movieTitle ?? 'Unknown');
        }
        break;

      case 'pauseDownload':
        if (taskId != null) {
          _pauseDownload(taskId);
        }
        break;

      case 'resumeDownload':
        if (taskId != null) {
          _resumeDownload(taskId);
        }
        break;

      case 'stopDownload':
        if (taskId != null) {
          _stopDownload(taskId);
        }
        break;
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool stopWithTask) async {
    log('TorrentTaskHandler: Service destroyed');

    // Clean up all running tasks
    for (var listener in _taskListeners.values) {
      if (listener != null) {
        listener.clear();
      }
    }

    for (var metadata in _metadataDownloaders.values) {
      metadata.stop();
    }

    for (var task in _tasks.values) {
      await task.stop();
    }

    _taskListeners.clear();
    _metadataDownloaders.clear();
    _tasks.clear();
  }

  @override
  void onNotificationButtonPressed(String id) {
    log('Notification button pressed: $id');

    switch (id) {
      case 'pause_all':
        for (var taskId in _tasks.keys.toList()) {
          _pauseDownload(taskId);
        }
        break;
      case 'stop_all':
        for (var taskId in _tasks.keys.toList()) {
          _stopDownload(taskId);
        }
        break;
    }
  }

  @override
  void onNotificationPressed() {
    // Bring app to foreground when notification is pressed
    FlutterForegroundTask.launchApp('/downloads');
  }

  @override
  void onNotificationDismissed() {
    log('Notification dismissed');
  }

  Future<void> _startDownload(
    String taskId,
    String magnetUri,
    String savePath,
    String movieTitle,
  ) async {
    try {
      log('=== Starting download for $taskId ===');
      log('Magnet URI: $magnetUri');
      log('Save path: $savePath');
      log('Movie title: $movieTitle');

      if (_tasks.containsKey(taskId)) {
        log('Task $taskId already running');
        return;
      }

      // Parse magnet link
      final magnet = MagnetParser.parse(magnetUri);
      if (magnet == null) {
        log('Invalid magnet URI for task $taskId');
        _sendProgressUpdate(taskId, {
          'status': 'failed',
          'error': 'Invalid magnet URI',
        });
        return;
      }

      log('Magnet parsed successfully. Info hash: ${magnet.infoHashString}');

      // Update notification
      FlutterForegroundTask.updateService(
        notificationTitle: 'Downloading Metadata',
        notificationText: movieTitle,
      );

      log('Starting metadata download...');

      // Download metadata
      final metadata = MetadataDownloader.fromMagnet(magnetUri);
      _metadataDownloaders[taskId] = metadata;
      final metadataListener = metadata.createListener();

      metadataListener
        ..on<MetaDataDownloadProgress>((event) {
          log('Metadata progress for $taskId: ${(event.progress * 100).toInt()}%');
          _sendProgressUpdate(taskId, {
            'status': 'downloading_metadata',
            'progress': event.progress * 0.05,
          });
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
            _sendProgressUpdate(taskId, {
              'status': 'downloading',
              'progress': 0.0,
              'downloadSpeed': 0,
              'uploadSpeed': 0,
              'peers': 0,
              'seeders': 0,
              'downloadedBytes': 0,
              'totalBytes': totalBytes,
            });

            // Start progress monitoring
            _startProgressMonitoring(
                taskId, torrentTask, movieTitle, totalBytes);

            log('Download started successfully for task $taskId');
          } catch (e, s) {
            log('Error processing metadata for $taskId: $e',
                error: e, stackTrace: s);
            _metadataDownloaders.remove(taskId);
            _sendProgressUpdate(taskId, {
              'status': 'failed',
              'error': e.toString(),
            });
          }
        });

      metadata.startDownload();

      // Set timeout for metadata download (5 minutes should be enough)
      Timer(const Duration(minutes: 5), () {
        if (_metadataDownloaders.containsKey(taskId)) {
          log('Metadata download timeout for $taskId');
          metadata.stop();
          _metadataDownloaders.remove(taskId);
          _sendProgressUpdate(taskId, {
            'status': 'failed',
            'error': 'Metadata download timeout',
          });
        }
      });
    } catch (e, s) {
      log('Error starting download for $taskId: $e', error: e, stackTrace: s);
      _sendProgressUpdate(taskId, {
        'status': 'failed',
        'error': e.toString(),
      });
    }
  }

  void _startProgressMonitoring(
    String taskId,
    TorrentTask task,
    String movieTitle,
    int totalBytes,
  ) {
    // Create listener for task events
    final listener = task.createListener();
    _taskListeners[taskId] = listener;

    // Listen for state file updates (progress, speed, etc.)
    listener
      ..on<StateFileUpdated>((event) {
        print('=== StateFileUpdated for $taskId ===');
        print('Progress: ${task.progress}');
        print('Download Speed: ${task.currentDownloadSpeed}');
        print('Upload Speed: ${task.uploadSpeed}');
        print('Peers: ${task.connectedPeersNumber}');
        print('Seeders: ${task.seederNumber}');
        print('Downloaded: ${task.downloaded}');
        if (!_tasks.containsKey(taskId)) return;

        final progress = task.progress;
        final downloadSpeed = task.currentDownloadSpeed.toInt();
        final uploadSpeed = task.uploadSpeed.toInt();
        final peers = task.connectedPeersNumber;
        final seeders = task.seederNumber;
        final downloaded = task.downloaded ?? 0;

        log('Progress update for $taskId: ${(progress * 100).toStringAsFixed(1)}% - Speed: ${_formatSpeed(downloadSpeed)}');

        // Update notification
        FlutterForegroundTask.updateService(
          notificationTitle: movieTitle,
          notificationText:
              '${(progress * 100).toStringAsFixed(1)}% • ${_formatSpeed(downloadSpeed)} ↓ ${_formatSpeed(uploadSpeed)} ↑',
        );

        // Send progress update to UI
        _sendProgressUpdate(taskId, {
          'status': 'downloading',
          'progress': progress,
          'downloadSpeed': downloadSpeed,
          'uploadSpeed': uploadSpeed,
          'peers': peers,
          'seeders': seeders,
          'downloadedBytes': downloaded.toInt(),
          'totalBytes': totalBytes,
        });
      })
      ..on<TaskCompleted>((event) {
        log('Download completed for $taskId');

        final downloaded = task.downloaded ?? 0;

        // Update notification
        FlutterForegroundTask.updateService(
          notificationTitle: movieTitle,
          notificationText: 'Download completed!',
        );

        // Send completion update
        _sendProgressUpdate(taskId, {
          'status': 'completed',
          'progress': 1.0,
          'downloadedBytes': downloaded.toInt(),
          'totalBytes': totalBytes,
        });

        // Clean up
        _taskListeners[taskId]?.dispose();
        _taskListeners.remove(taskId);
        _tasks.remove(taskId);
      })
      ..on<TaskFileCompleted>((event) {
        log('File completed for $taskId: ${event.file.originalFileName}');
      })
      ..on<TaskStopped>((event) {
        log('Task stopped: $taskId');

        // Clean up
        _taskListeners[taskId]?.dispose();
        _taskListeners.remove(taskId);
        _tasks.remove(taskId);

        _sendProgressUpdate(taskId, {'status': 'stopped'});
      });
  }

  void _pauseDownload(String taskId) {
    final task = _tasks[taskId];
    if (task != null) {
      task.pause();
      _sendProgressUpdate(taskId, {'status': 'paused'});
      log('Download paused: $taskId');
    }
  }

  void _resumeDownload(String taskId) {
    print('=== Resuming download for $taskId ===');
    final task = _tasks[taskId];
    if (task != null) {
      task.start();
      _sendProgressUpdate(taskId, {'status': 'downloading'});
      log('Download resumed: $taskId');
    }
  }

  Future<void> _stopDownload(String taskId) async {
    final task = _tasks.remove(taskId);
    if (task != null) {
      await task.stop();
      _taskListeners[taskId]?.dispose();
      _taskListeners.remove(taskId);
      _sendProgressUpdate(taskId, {'status': 'stopped'});
      log('Download stopped: $taskId');
    }
  }

  void _sendProgressUpdate(String taskId, Map<String, dynamic> data) {
    FlutterForegroundTask.sendDataToMain({
      'taskId': taskId,
      ...data,
    });
  }

  String _formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond}B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)}KB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)}MB/s';
    }
  }
}
