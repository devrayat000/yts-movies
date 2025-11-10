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

/// Notification channel ID for torrent downloads
const String notificationChannelId = 'torrent_downloads';
const int notificationId = 888;

/// Entry point for the background isolate
@pragma('vm:entry-point')
void onStartBackgroundService(ServiceInstance service) async {
  // Initialize the notification plugin
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the handler
  final handler = _TorrentTaskHandler(service, notificationsPlugin);

  // Listen for commands from UI
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

  // Periodic update for notification
  // Timer.periodic(const Duration(seconds: 5), (timer) {
  //   handler.updateOverallNotification();
  // });

  log('_TorrentTaskHandler: Service started');
}

/// Background task handler for torrent downloads
class _TorrentTaskHandler {
  final ServiceInstance service;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  // Map to manage multiple simultaneous downloads
  // Key: taskId, Value: TorrentTask
  final Map<int, TorrentTask> _tasks = {};
  final Map<int, MetadataDownloader> _metadataDownloaders = {};
  final Map<int, EventsListener<TaskEvent>> _taskListeners = {};

  _TorrentTaskHandler(this.service, this.notificationsPlugin);

  // void updateOverallNotification() {
  //   if (_tasks.isEmpty) return;

  //   final totalProgress =
  //       _tasks.values.map((task) => task.progress).reduce((a, b) => a + b) /
  //           _tasks.length;

  //   final activeCount = _tasks.length;

  //   _showNotification(
  //     notificationId,
  //     'Torrent Downloads',
  //     '$activeCount active download(s) • ${(totalProgress * 100).toStringAsFixed(1)}% complete',
  //     progress: (totalProgress * 100).toInt(),
  //     maxProgress: 100,
  //   );
  // }

  // int _urlToUniqueInt(String url) {
  //   var bytes = utf8.encode(url); // Convert URL string to bytes
  //   var digest = sha256.convert(bytes); // Hash the bytes using SHA-256
  //   // Take a portion of the hash and convert it to an integer
  //   // This approach ensures a fixed-size integer representation.
  //   return int.parse(digest.toString().substring(0, 8), radix: 16);
  // }

  Future<void> startDownload(StartDownloadRequest request) async {
    final taskId = request.taskId;
    final magnetUri = request.magnetUri;
    final savePath = request.savePath;
    final movieTitle = request.movieTitle;

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
        _sendProgressUpdate(
          ProgressUpdate(
            taskId: taskId,
            status: DownloadStatus.failed,
            error: 'Invalid magnet URI',
          ),
        );
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
        });

      metadata.startDownload();

      // Set timeout for metadata download (5 minutes should be enough)
      // Timer(const Duration(minutes: 5), () {
      //   if (_metadataDownloaders.containsKey(taskId)) {
      //     log('Metadata download timeout for $taskId');
      //     metadata.stop();
      //     _metadataDownloaders.remove(taskId);
      //     _sendProgressUpdate(
      //       ProgressUpdate(
      //         taskId: taskId,
      //         status: DownloadStatus.failed,
      //         error: 'Metadata download timeout',
      //       ),
      //     );
      //   }
      // });
    } catch (e, s) {
      log('Error starting download for $taskId: $e', error: e, stackTrace: s);
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.failed,
          error: e.toString(),
        ),
      );
    }
  }

  void _startProgressMonitoring(
    int taskId,
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

        _sendProgressUpdate(
          ProgressUpdate(
            taskId: taskId,
            status: DownloadStatus.stopped,
          ),
        );
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
    }
  }

  void resumeDownload(DownloadControlRequest request) {
    final taskId = request.taskId;
    print('=== Resuming download for $taskId ===');
    final task = _tasks[taskId];
    if (task != null) {
      task.start();
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.downloading,
        ),
      );
      log('Download resumed: $taskId');
    }
  }

  Future<void> stopDownload(DownloadControlRequest request) async {
    final taskId = request.taskId;
    final task = _tasks.remove(taskId);
    if (task != null) {
      await task.stop();
      _taskListeners[taskId]?.dispose();
      _taskListeners.remove(taskId);
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.stopped,
        ),
      );
      log('Download stopped: $taskId');
    }
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
  }
}
