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

/// Notification channel ID for torrent downloads
const String notificationChannelId = 'torrent_downloads';
const int notificationId = 888;

/// Entry point for the background isolate
@pragma('vm:entry-point')
void onStartBackgroundService(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  final handler = _TorrentTaskHandler(service, notificationsPlugin);

  service.on('startDownload').listen((event) {
    if (event == null) return;
    try {
      handler.startDownload(StartDownloadRequest.fromJson(event));
    } catch (e) {
      log('Error parsing startDownload event: $e');
    }
  });

  service.on('pauseDownload').listen((event) {
    if (event == null) return;
    try {
      handler.pauseDownload(DownloadControlRequest.fromJson(event));
    } catch (e) {
      log('Error parsing pauseDownload event: $e');
    }
  });

  service.on('resumeDownload').listen((event) {
    if (event == null) return;
    try {
      handler.resumeDownload(DownloadControlRequest.fromJson(event));
    } catch (e) {
      log('Error parsing resumeDownload event: $e');
    }
  });

  service.on('stopDownload').listen((event) {
    if (event == null) return;
    try {
      handler.stopDownload(DownloadControlRequest.fromJson(event));
    } catch (e) {
      log('Error parsing stopDownload event: $e');
    }
  });

  service.on('setSpeedLimit').listen((event) {
    if (event == null) return;
    try {
      handler.setSpeedLimit(SetSpeedLimitRequest.fromJson(event));
    } catch (e) {
      log('Error parsing setSpeedLimit event: $e');
    }
  });

  service.on('setFilePriority').listen((event) {
    if (event == null) return;
    try {
      handler.setFilePriority(SetFilePriorityRequest.fromJson(event));
    } catch (e) {
      log('Error parsing setFilePriority event: $e');
    }
  });

  service.on('applyFileSelection').listen((event) {
    if (event == null) return;
    try {
      handler.applyFileSelection(ApplyFileSelectionRequest.fromJson(event));
    } catch (e) {
      log('Error parsing applyFileSelection event: $e');
    }
  });

  service.on('addTracker').listen((event) {
    if (event == null) return;
    try {
      handler.addTracker(AddTrackerRequest.fromJson(event));
    } catch (e) {
      log('Error parsing addTracker event: $e');
    }
  });

  service.on('removeTracker').listen((event) {
    if (event == null) return;
    try {
      handler.removeTracker(RemoveTrackerRequest.fromJson(event));
    } catch (e) {
      log('Error parsing removeTracker event: $e');
    }
  });

  service.on('setMaxConcurrent').listen((event) {
    if (event == null) return;
    final v = event['value'];
    if (v is int) handler.setMaxConcurrent(v);
  });

  service.on('stopService').listen((event) {
    handler.cleanup();
    service.stopSelf();
  });

  log('_TorrentTaskHandler: Service started');
}

/// Per-task bookkeeping kept in the background isolate
class _TaskRecord {
  final int taskId;
  final String movieTitle;
  final String savePath;
  StartDownloadRequest request;

  TorrentTask? task;
  MetadataDownloader? metadata;
  EventsListener<TaskEvent>? listener;

  Uint8List? infoHashBuffer;
  Torrent? torrentModel;
  int totalBytes = 0;

  /// Track user-added trackers separately so we can persist/expose them
  final Set<String> userTrackers = <String>{};

  /// Track all trackers we know about (magnet + user-added)
  final Map<String, TrackerInfo> trackers = <String, TrackerInfo>{};

  /// File priorities (index -> level). Persisted so we can re-apply on resume.
  final Map<int, FilePriorityLevel> filePriorities = <int, FilePriorityLevel>{};

  int? downloadSpeedLimit;
  int? uploadSpeedLimit;

  bool isPaused = false;

  _TaskRecord({
    required this.taskId,
    required this.movieTitle,
    required this.savePath,
    required this.request,
  });

  List<TorrentFileInfo> buildFileInfos() {
    final t = torrentModel;
    if (t == null) return const [];
    final dynamic files = (t as dynamic).files;
    if (files == null) return const [];
    final List<TorrentFileInfo> out = [];
    for (var i = 0; i < (files as List).length; i++) {
      final dynamic f = files[i];
      String name;
      int size = 0;
      try {
        final dynamic p = f.path;
        if (p is List) {
          name = p.join('/');
        } else if (p is String && p.isNotEmpty) {
          name = p;
        } else {
          name = (f.name ?? 'file_$i').toString();
        }
      } catch (_) {
        name = 'file_$i';
      }
      try {
        size = (f.length as int?) ?? 0;
      } catch (_) {
        try {
          size = (f.size as int?) ?? 0;
        } catch (_) {}
      }
      out.add(TorrentFileInfo(
        index: i,
        name: name,
        size: size,
        priority: filePriorities[i] ?? FilePriorityLevel.normal,
      ));
    }
    return out;
  }
}

class _TorrentTaskHandler {
  final ServiceInstance service;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  final Map<int, _TaskRecord> _records = {};
  final SequentialDownloadQueue _queue = SequentialDownloadQueue();

  Timer? _periodicTimer;

  _TorrentTaskHandler(this.service, this.notificationsPlugin) {
    _queue.setStartCallback(_actuallyStartDownload);

    // Periodic emit of progress/stats for currently active tasks
    _periodicTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _emitPeriodicUpdates();
    });
  }

  void setMaxConcurrent(int value) {
    _queue.maxConcurrent = value;
  }

  Future<void> startDownload(StartDownloadRequest request) async {
    final taskId = request.taskId;
    final movieTitle = request.movieTitle;

    try {
      if (_records.containsKey(taskId)) {
        log('Task $taskId already known');
        return;
      }

      _records[taskId] = _TaskRecord(
        taskId: taskId,
        movieTitle: movieTitle,
        savePath: request.savePath,
        request: request,
      )
        ..downloadSpeedLimit = request.initialDownloadLimit
        ..uploadSpeedLimit = request.initialUploadLimit;

      final queued = _queue.addTask(taskId, movieTitle);
      if (queued) {
        _sendProgressUpdate(
          ProgressUpdate(taskId: taskId, status: DownloadStatus.queued),
        );
      }
    } catch (e, s) {
      log('Error adding download to queue: $e', error: e, stackTrace: s);
      _sendProgressUpdate(
        ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.failed,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _actuallyStartDownload(int taskId) async {
    final rec = _records[taskId];
    if (rec == null) {
      log('ERROR: no record for task $taskId');
      _queue.markCurrentComplete(taskId);
      return;
    }

    try {
      final magnet = MagnetParser.parse(rec.request.magnetUri);
      if (magnet == null) {
        _sendProgressUpdate(ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.failed,
          error: 'Invalid magnet URI',
        ));
        _queue.markCurrentComplete(taskId);
        return;
      }

      rec.infoHashBuffer = _hexToBytes(magnet.infoHashString);

      // Initialize tracker map from magnet trackers (List<Uri> -> String keys)
      for (final uri in magnet.trackers) {
        final url = uri.toString();
        rec.trackers[url] = TrackerInfo(
          url: url,
          status: TrackerStatus.connecting,
        );
      }
      // Plus any extras supplied with the request (default trackers)
      for (final url in rec.request.extraTrackers) {
        rec.trackers.putIfAbsent(
          url,
          () => TrackerInfo(
            url: url,
            status: TrackerStatus.connecting,
            userAdded: true,
          ),
        );
      }

      _showNotification(taskId, 'Downloading Metadata', rec.movieTitle);
      _sendProgressUpdate(ProgressUpdate(
        taskId: taskId,
        status: DownloadStatus.downloadingMetadata,
        trackers: rec.trackers.values.toList(),
      ));

      final metadata = MetadataDownloader.fromMagnet(rec.request.magnetUri);
      rec.metadata = metadata;
      final metaListener = metadata.createListener();

      metaListener
        ..on<MetaDataDownloadProgress>((event) {
          _sendProgressUpdate(ProgressUpdate(
            taskId: taskId,
            status: DownloadStatus.downloadingMetadata,
            progress: event.progress.toDouble(),
          ));
        })
        ..on<MetaDataDownloadComplete>((event) async {
          await _onMetadataReady(rec, magnet, event.data);
        })
        ..on<MetaDataDownloadFailed>((event) {
          log('Metadata failed for $taskId: ${event.error}');
          rec.metadata = null;
          _sendProgressUpdate(ProgressUpdate(
            taskId: taskId,
            status: DownloadStatus.failed,
            error: event.error,
          ));
          _queue.markCurrentComplete(taskId);
        });

      metadata.startDownload();
    } catch (e, s) {
      log('Error starting download $taskId: $e', error: e, stackTrace: s);
      _sendProgressUpdate(ProgressUpdate(
        taskId: taskId,
        status: DownloadStatus.failed,
        error: e.toString(),
      ));
      _queue.markCurrentComplete(taskId);
    }
  }

  Future<void> _onMetadataReady(
    _TaskRecord rec,
    dynamic magnet,
    List<int> data,
  ) async {
    final taskId = rec.taskId;
    try {
      final msg = decode(Uint8List.fromList(data));
      final torrentMap = <String, dynamic>{'info': msg};
      final torrentModel = parseTorrentFileContent(torrentMap);
      if (torrentModel == null) {
        throw Exception('Failed to parse torrent metadata');
      }
      rec.torrentModel = torrentModel;
      rec.totalBytes = torrentModel.length;

      final torrentTask = TorrentTask.newTask(
        torrentModel,
        rec.savePath,
        false,
        magnet.webSeeds.isNotEmpty ? magnet.webSeeds : null,
        magnet.acceptableSources.isNotEmpty ? magnet.acceptableSources : null,
      );

      if (magnet.selectedFileIndices != null &&
          magnet.selectedFileIndices!.isNotEmpty) {
        torrentTask.applySelectedFiles(magnet.selectedFileIndices!);
      }

      await torrentTask.start();
      rec.task = torrentTask;
      rec.metadata = null;

      // Re-apply any previously-set file selection (e.g. on resume)
      if (rec.filePriorities.isNotEmpty) {
        _reapplySelection(rec);
      }

      // Apply pending speed limits
      _applySpeedLimits(rec);

      // Hand peers over from metadata downloader
      final activePeers = rec.metadata?.activePeers ?? const [];
      for (final peer in activePeers) {
        torrentTask.addPeer(peer.address, PeerSource.manual, type: peer.type);
      }

      // Re-add trackers (magnet + extras + user-added previously)
      final infoHash = rec.infoHashBuffer!;
      for (final url in rec.trackers.keys.toList()) {
        try {
          torrentTask.startAnnounceUrl(Uri.parse(url), infoHash);
        } catch (e) {
          log('addTracker failed for $url: $e');
          rec.trackers[url] = rec.trackers[url]!.copyWith(
            status: TrackerStatus.failed,
            errorMessage: e.toString(),
          );
        }
      }

      _attachTaskListener(rec);

      _sendProgressUpdate(ProgressUpdate(
        taskId: taskId,
        status: DownloadStatus.downloading,
        progress: 0.0,
        totalBytes: rec.totalBytes,
        files: rec.buildFileInfos(),
        trackers: rec.trackers.values.toList(),
        downloadSpeedLimit: rec.downloadSpeedLimit,
        uploadSpeedLimit: rec.uploadSpeedLimit,
        savedFilePath: rec.savePath,
      ));
    } catch (e, s) {
      log('Error processing metadata $taskId: $e', error: e, stackTrace: s);
      rec.metadata = null;
      _sendProgressUpdate(ProgressUpdate(
        taskId: taskId,
        status: DownloadStatus.failed,
        error: e.toString(),
      ));
      _queue.markCurrentComplete(taskId);
    }
  }

  void _attachTaskListener(_TaskRecord rec) {
    final task = rec.task!;
    final taskId = rec.taskId;
    final listener = task.createListener();
    rec.listener = listener;

    listener
      ..on<StateFileUpdated>((event) {
        _emitFromTask(rec);
      })
      ..on<TaskCompleted>((event) {
        _showNotification(
          taskId,
          rec.movieTitle,
          'Download completed!',
          progress: 100,
          maxProgress: 100,
        );
        _sendProgressUpdate(ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.completed,
          progress: 1.0,
          downloadedBytes: rec.totalBytes,
          totalBytes: rec.totalBytes,
        ));
        _cleanupTask(taskId);
        _queue.markCurrentComplete(taskId);
      })
      ..on<TaskFileCompleted>((event) {
        log('File completed for $taskId: ${event.file.originalFileName}');
        // Re-emit so UI updates per-file progress
        _emitFromTask(rec);
      })
      ..on<TaskStopped>((event) {
        log('Task stopped: $taskId');
        _sendProgressUpdate(ProgressUpdate(
          taskId: taskId,
          status: DownloadStatus.stopped,
        ));
        _cleanupTask(taskId);
        _queue.markCurrentComplete(taskId);
      });
  }

  void _emitFromTask(_TaskRecord rec) {
    final task = rec.task;
    if (task == null) return;
    final progress = task.progress;
    final dlSpeed = task.currentDownloadSpeed.toInt();
    final ulSpeed = task.uploadSpeed.toInt();
    final peers = task.connectedPeersNumber;
    final seeders = task.seederNumber;
    final downloaded = (task.downloaded ?? 0).toInt();

    _showNotification(
      rec.taskId,
      rec.movieTitle,
      '${(progress * 100).toStringAsFixed(1)}% • '
      '${_formatSpeed(dlSpeed)} ↓ ${_formatSpeed(ulSpeed)} ↑',
      progress: (progress * 100).toInt(),
      maxProgress: 100,
    );

    _sendProgressUpdate(ProgressUpdate(
      taskId: rec.taskId,
      status: rec.isPaused ? DownloadStatus.paused : DownloadStatus.downloading,
      progress: progress,
      downloadSpeed: dlSpeed,
      uploadSpeed: ulSpeed,
      peers: peers,
      seeders: seeders,
      downloadedBytes: downloaded,
      totalBytes: rec.totalBytes,
      files: rec.buildFileInfos(),
      trackers: rec.trackers.values.toList(),
      downloadSpeedLimit: rec.downloadSpeedLimit,
      uploadSpeedLimit: rec.uploadSpeedLimit,
    ));
  }

  void _emitPeriodicUpdates() {
    for (final rec in _records.values) {
      if (rec.task != null && !rec.isPaused) {
        try {
          _emitFromTask(rec);
        } catch (e) {
          log('periodic emit failed for ${rec.taskId}: $e');
        }
      }
    }
  }

  // ---- Control ops ----

  void pauseDownload(DownloadControlRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    final task = rec.task;
    if (task != null) {
      try {
        task.pause();
      } catch (e) {
        log('task.pause threw: $e — falling back to stop');
      }
    } else {
      // Pause during metadata download — stop metadata, keep slot for resume
      rec.metadata?.stop();
    }
    rec.isPaused = true;
    _sendProgressUpdate(ProgressUpdate(
      taskId: request.taskId,
      status: DownloadStatus.paused,
    ));
  }

  void resumeDownload(DownloadControlRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) {
      log('resume: unknown task ${request.taskId}');
      return;
    }
    rec.isPaused = false;

    final task = rec.task;
    if (task != null) {
      try {
        task.resume();
      } catch (_) {
        try {
          task.start();
        } catch (e) {
          log('resume failed: $e');
        }
      }
      _sendProgressUpdate(ProgressUpdate(
        taskId: request.taskId,
        status: DownloadStatus.downloading,
      ));
    } else if (rec.metadata != null) {
      rec.metadata!.startDownload();
      _sendProgressUpdate(ProgressUpdate(
        taskId: request.taskId,
        status: DownloadStatus.downloadingMetadata,
      ));
    } else {
      // No live task — restart from scratch
      _actuallyStartDownload(request.taskId);
    }
  }

  Future<void> stopDownload(DownloadControlRequest request) async {
    final taskId = request.taskId;
    _queue.removeTask(taskId);

    final rec = _records.remove(taskId);
    if (rec != null) {
      rec.metadata?.stop();
      try {
        await rec.task?.stop();
      } catch (e) {
        log('task.stop threw: $e');
      }
      rec.listener?.dispose();
    }
    _sendProgressUpdate(ProgressUpdate(
      taskId: taskId,
      status: DownloadStatus.stopped,
    ));
    _queue.markCurrentComplete(taskId);
  }

  // ---- Advanced ops ----

  void setSpeedLimit(SetSpeedLimitRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    rec.downloadSpeedLimit = request.downloadLimit;
    rec.uploadSpeedLimit = request.uploadLimit;
    _applySpeedLimits(rec);
    _sendProgressUpdate(ProgressUpdate(
      taskId: request.taskId,
      status: rec.isPaused
          ? DownloadStatus.paused
          : (rec.task != null
              ? DownloadStatus.downloading
              : DownloadStatus.downloadingMetadata),
      downloadSpeedLimit: rec.downloadSpeedLimit,
      uploadSpeedLimit: rec.uploadSpeedLimit,
    ));
  }

  /// dtorrent_task_v2 0.4.4 does not expose speed-limit setters. We persist
  /// the user's intent on the record so the UI shows what was requested;
  /// once the library gains setters, wire them in here.
  void _applySpeedLimits(_TaskRecord rec) {
    if (rec.task == null) return;
    if (rec.downloadSpeedLimit != null || rec.uploadSpeedLimit != null) {
      log('speed limits requested but not supported by dtorrent_task_v2 0.4.4');
    }
  }

  /// File priority in v0.4.4 collapses to "selected" or "skip". We keep the
  /// 4-level enum on the model so the UI is futureproof, but anything that
  /// isn't `skip` is treated as selected when re-applying.
  void setFilePriority(SetFilePriorityRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    rec.filePriorities[request.fileIndex] = request.priority;
    _reapplySelection(rec);
    _sendProgressUpdate(ProgressUpdate(
      taskId: request.taskId,
      status: rec.isPaused ? DownloadStatus.paused : DownloadStatus.downloading,
      files: rec.buildFileInfos(),
    ));
  }

  void applyFileSelection(ApplyFileSelectionRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    final total = rec.torrentModel == null
        ? 0
        : ((rec.torrentModel as dynamic).files as List).length;
    for (var i = 0; i < total; i++) {
      rec.filePriorities[i] = request.selectedIndices.contains(i)
          ? FilePriorityLevel.normal
          : FilePriorityLevel.skip;
    }
    _reapplySelection(rec);
    _sendProgressUpdate(ProgressUpdate(
      taskId: request.taskId,
      status: rec.isPaused ? DownloadStatus.paused : DownloadStatus.downloading,
      files: rec.buildFileInfos(),
    ));
  }

  void _reapplySelection(_TaskRecord rec) {
    final task = rec.task;
    if (task == null) return;
    final total = rec.torrentModel == null
        ? 0
        : ((rec.torrentModel as dynamic).files as List).length;
    if (total == 0) return;
    final indices = <int>[];
    for (var i = 0; i < total; i++) {
      final p = rec.filePriorities[i] ?? FilePriorityLevel.normal;
      if (p != FilePriorityLevel.skip) indices.add(i);
    }
    try {
      task.applySelectedFiles(indices);
    } catch (e) {
      log('applySelectedFiles failed: $e');
    }
  }

  void addTracker(AddTrackerRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    final url = request.trackerUrl.trim();
    if (url.isEmpty) return;

    rec.userTrackers.add(url);
    rec.trackers.putIfAbsent(
      url,
      () => TrackerInfo(
        url: url,
        status: TrackerStatus.connecting,
        userAdded: true,
      ),
    );

    final task = rec.task;
    final infoHash = rec.infoHashBuffer;
    if (task != null && infoHash != null) {
      try {
        task.startAnnounceUrl(Uri.parse(url), infoHash);
        rec.trackers[url] = rec.trackers[url]!.copyWith(
          status: TrackerStatus.working,
        );
      } catch (e) {
        log('startAnnounceUrl failed for $url: $e');
        rec.trackers[url] = rec.trackers[url]!.copyWith(
          status: TrackerStatus.failed,
          errorMessage: e.toString(),
        );
      }
    }
    _sendProgressUpdate(ProgressUpdate(
      taskId: request.taskId,
      status: rec.isPaused ? DownloadStatus.paused : DownloadStatus.downloading,
      trackers: rec.trackers.values.toList(),
    ));
  }

  /// dtorrent_task_v2 0.4.4 has no stopAnnounceUrl. We drop the tracker from
  /// our bookkeeping so the UI reflects the change; the live tracker will
  /// remain attached until the task is stopped and restarted.
  void removeTracker(RemoveTrackerRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    rec.userTrackers.remove(request.trackerUrl);
    rec.trackers.remove(request.trackerUrl);
    _sendProgressUpdate(ProgressUpdate(
      taskId: request.taskId,
      status: rec.isPaused ? DownloadStatus.paused : DownloadStatus.downloading,
      trackers: rec.trackers.values.toList(),
    ));
  }

  // ---- Helpers ----

  void _cleanupTask(int taskId) {
    final rec = _records.remove(taskId);
    rec?.listener?.dispose();
  }

  void _sendProgressUpdate(ProgressUpdate update) {
    service.invoke('progressUpdate', update.toJson());
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

    await notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: id.toString(),
    );
  }

  String _formatSpeed(int bytes) {
    if (bytes < 1024) return '$bytes B/s';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB/s';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB/s';
  }

  Uint8List _hexToBytes(String hex) {
    final clean = hex.length.isOdd ? '0$hex' : hex;
    return Uint8List.fromList(List.generate(
      clean.length ~/ 2,
      (i) => int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16),
    ));
  }

  void cleanup() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    for (final rec in _records.values) {
      rec.listener?.dispose();
      rec.metadata?.stop();
      try {
        rec.task?.stop();
      } catch (_) {}
    }
    _records.clear();
    _queue.clear();
  }
}
