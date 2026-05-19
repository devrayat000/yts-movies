import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:b_encode_decode/b_encode_decode.dart';
import 'package:events_emitter2/src/events_emitter.dart' show EventsListener;
import 'package:dtorrent_task_v2/dtorrent_task_v2.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/torrent_service_models.dart';

const String notificationChannelId = 'torrent_downloads';
const int notificationId = 888;

/// Entry point for the background isolate.
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
      log('startDownload parse error: $e');
    }
  });
  service.on('pauseDownload').listen((event) {
    if (event == null) return;
    handler.pauseDownload(DownloadControlRequest.fromJson(event));
  });
  service.on('resumeDownload').listen((event) {
    if (event == null) return;
    handler.resumeDownload(DownloadControlRequest.fromJson(event));
  });
  service.on('stopDownload').listen((event) {
    if (event == null) return;
    handler.stopDownload(DownloadControlRequest.fromJson(event));
  });
  service.on('setSpeedLimit').listen((event) {
    if (event == null) return;
    handler.setSpeedLimit(SetSpeedLimitRequest.fromJson(event));
  });
  service.on('setFilePriority').listen((event) {
    if (event == null) return;
    handler.setFilePriority(SetFilePriorityRequest.fromJson(event));
  });
  service.on('applyFileSelection').listen((event) {
    if (event == null) return;
    handler.applyFileSelection(ApplyFileSelectionRequest.fromJson(event));
  });
  service.on('addTracker').listen((event) {
    if (event == null) return;
    handler.addTracker(AddTrackerRequest.fromJson(event));
  });
  service.on('removeTracker').listen((event) {
    if (event == null) return;
    handler.removeTracker(RemoveTrackerRequest.fromJson(event));
  });
  service.on('setMaxConcurrent').listen((event) {
    if (event == null) return;
    final v = event['value'];
    if (v is int) handler.setMaxConcurrent(v);
  });
  service.on('setSequentialDownload').listen((event) {
    if (event == null) return;
    handler.setSequentialDownload(SetSequentialDownloadRequest.fromJson(event));
  });
  service.on('moveDownloadTask').listen((event) {
    if (event == null) return;
    unawaited(
        handler.moveDownloadTask(MoveDownloadTaskRequest.fromJson(event)));
  });
  service.on('autoPrioritize').listen((event) {
    if (event == null) return;
    final v = event['taskId'];
    if (v is int) handler.autoPrioritize(v);
  });
  service.on('stopService').listen((event) async {
    await handler.cleanup();
    service.stopSelf();
  });
  log('TorrentTaskHandler: service started');
}

/// Internal per-task bookkeeping. Lives only in the background isolate.
class _Record {
  final int taskId;
  final String movieTitle;
  String savePath;
  StartDownloadRequest request;

  /// Set once metadata is in hand and we've called QueueManager.addToQueue.
  String? queueItemId;

  /// Live task — populated once QueueItemStarted fires.
  TorrentTask? task;
  EventsListener<TaskEvent>? taskListener;

  /// Active during the metadata-download phase only.
  MetadataDownloader? metadata;

  /// Trackers from the magnet (canonicalized strings).
  final List<String> magnetTrackers = [];

  /// User-added trackers (the originals so we can re-inject after re-start).
  final Set<String> userTrackers = <String>{};

  /// All trackers we know about (magnet + user-added) with status.
  final Map<String, TrackerInfo> trackers = <String, TrackerInfo>{};

  /// User-set per-file priorities. Re-applied on (re)start.
  final Map<int, FilePriorityLevel> filePriorities = {};

  /// Per-file download progress snapshots (bytes).
  final Map<int, int> fileDownloaded = {};

  /// Completed file indices.
  final Set<int> completedFiles = {};

  /// Webseeds + acceptable sources captured from the magnet.
  List<Uri> webSeeds = const [];
  List<Uri> acceptableSources = const [];

  /// Hex (lowercase) infoHash, set as soon as metadata is parsed.
  String? infoHashHex;

  /// 20-byte raw infoHash (for `startAnnounceUrl` calls).
  Uint8List? infoHashBuffer;

  /// Parsed model. Stored so we can read file count/size for UI.
  TorrentModel? model;
  int totalBytes = 0;

  int? downloadSpeedLimit;
  int? uploadSpeedLimit;

  bool sequentialDownload = false;
  List<int>? selectedIndices;

  bool pausedByUser = false;
  DownloadStatus lastStatus = DownloadStatus.queued;

  _Record({
    required this.taskId,
    required this.movieTitle,
    required this.savePath,
    required this.request,
  });

  String get scheduleWindowId => 'user_limit_$taskId';

  List<TorrentFileInfo> buildFileInfos() {
    final m = model;
    if (m == null) return const [];
    final out = <TorrentFileInfo>[];
    for (var i = 0; i < m.files.length; i++) {
      final f = m.files[i];
      final p = filePriorities[i] ?? FilePriorityLevel.normal;
      final downloaded = fileDownloaded[i] ?? 0;
      final completed = completedFiles.contains(i) || downloaded >= f.length;
      out.add(TorrentFileInfo(
        index: i,
        name: f.path.isEmpty ? f.name : f.path,
        size: f.length,
        downloaded: downloaded,
        completed: completed,
        priority: p,
      ));
    }
    return out;
  }
}

FilePriority _toNativePriority(FilePriorityLevel level) {
  switch (level) {
    case FilePriorityLevel.skip:
      return FilePriority.skip;
    case FilePriorityLevel.low:
      return FilePriority.low;
    case FilePriorityLevel.normal:
      return FilePriority.normal;
    case FilePriorityLevel.high:
      return FilePriority.high;
  }
}

FilePriorityLevel _fromNativePriority(FilePriority p) {
  switch (p) {
    case FilePriority.skip:
      return FilePriorityLevel.skip;
    case FilePriority.low:
      return FilePriorityLevel.low;
    case FilePriority.normal:
      return FilePriorityLevel.normal;
    case FilePriority.high:
      return FilePriorityLevel.high;
  }
}

class _TorrentTaskHandler {
  final ServiceInstance service;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  /// The single QueueManager that owns task lifecycle.
  final QueueManager _qm = QueueManager(maxConcurrentDownloads: 3);

  final Map<int, _Record> _records = {};
  final Map<String, int> _byQueueId = {}; // queueItemId -> taskId

  Timer? _periodicTimer;
  Timer? _scrapeTimer;
  final Map<int, Timer> _emitDebounce = {};

  _TorrentTaskHandler(this.service, this.notificationsPlugin) {
    _wireQueueEvents();
    // Coarse periodic snapshot tick (UI heartbeat).
    _periodicTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      for (final rec in _records.values) {
        if (rec.task != null && !rec.pausedByUser) {
          _emitFromTask(rec);
        }
      }
    });
    // BEP 48 scrape on a slow interval.
    _scrapeTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      unawaited(_scrapeAllTrackers());
    });
  }

  void _wireQueueEvents() {
    _qm.events.listen((event) {
      if (event is QueueItemAdded) {
        final rec = _recordForQueueId(event.item.id);
        if (rec != null) {
          _send(ProgressUpdate(
            taskId: rec.taskId,
            status: DownloadStatus.queued,
          ));
        }
      } else if (event is QueueItemStarted) {
        final rec = _recordForQueueId(event.queueItemId);
        if (rec == null) return;
        rec.task = event.task;
        _onTaskReady(rec);
      } else if (event is QueueItemCompleted) {
        final rec = _recordForQueueId(event.queueItemId);
        if (rec == null) return;
        _showNotification(rec.taskId, rec.movieTitle, 'Download completed!',
            progress: 100, maxProgress: 100);
        rec.lastStatus = DownloadStatus.completed;
        _send(ProgressUpdate(
          taskId: rec.taskId,
          status: DownloadStatus.completed,
          progress: 1.0,
          downloadedBytes: rec.totalBytes,
          totalBytes: rec.totalBytes,
        ));
        // Keep the record to allow post-completion file moves.
      } else if (event is QueueItemStopped) {
        final rec = _recordForQueueId(event.queueItemId);
        if (rec == null) return;
        _send(ProgressUpdate(
          taskId: rec.taskId,
          status: DownloadStatus.stopped,
        ));
        _disposeRecord(rec, removeFromMap: true);
      } else if (event is QueueItemPaused) {
        final rec = _recordForQueueId(event.queueItemId);
        if (rec == null) return;
        rec.pausedByUser = true;
        _send(ProgressUpdate(
          taskId: rec.taskId,
          status: DownloadStatus.paused,
        ));
      } else if (event is QueueItemResumed) {
        final rec = _recordForQueueId(event.queueItemId);
        if (rec == null) return;
        rec.pausedByUser = false;
        _send(ProgressUpdate(
          taskId: rec.taskId,
          status: DownloadStatus.downloading,
        ));
      } else if (event is QueueItemFailed) {
        final rec = _recordForQueueId(event.queueItemId);
        if (rec == null) return;
        _send(ProgressUpdate(
          taskId: rec.taskId,
          status: DownloadStatus.failed,
          error: event.error,
        ));
        _disposeRecord(rec, removeFromMap: true);
      }
    });
  }

  _Record? _recordForQueueId(String qid) {
    final taskId = _byQueueId[qid];
    if (taskId == null) return null;
    return _records[taskId];
  }

  // ---- public commands ----

  void setMaxConcurrent(int value) {
    try {
      _qm.maxConcurrentDownloads = value;
    } catch (e) {
      log('setMaxConcurrent failed: $e');
    }
  }

  void setSequentialDownload(SetSequentialDownloadRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    rec.sequentialDownload = request.sequentialDownload;
    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: rec.lastStatus,
      sequentialDownload: rec.sequentialDownload,
    ));
  }

  Future<void> startDownload(StartDownloadRequest request) async {
    final taskId = request.taskId;
    if (_records.containsKey(taskId)) {
      log('startDownload: task $taskId already known');
      return;
    }
    final rec = _Record(
      taskId: taskId,
      movieTitle: request.movieTitle,
      savePath: request.savePath,
      request: request,
    )
      ..downloadSpeedLimit = request.initialDownloadLimit
      ..uploadSpeedLimit = request.initialUploadLimit
      ..sequentialDownload = request.sequentialDownload
      ..selectedIndices = request.selectedIndices;
    _records[taskId] = rec;
    await _beginMetadataPhase(rec);
  }

  /// Phase 1: download metadata from the magnet so we can build a TorrentModel.
  /// Phase 2 (`_enqueue`) hands the model to the package's QueueManager.
  Future<void> _beginMetadataPhase(_Record rec) async {
    try {
      final magnet = MagnetParser.parse(rec.request.magnetUri);
      if (magnet == null) {
        _fail(rec, 'Invalid magnet URI');
        return;
      }
      rec.infoHashBuffer = _hexToBytes(magnet.infoHashString);
      rec.infoHashHex = magnet.infoHashString.toLowerCase();
      rec.webSeeds = List.of(magnet.webSeeds);
      rec.acceptableSources = List.of(magnet.acceptableSources);

      for (final uri in magnet.trackers) {
        final url = uri.toString();
        rec.magnetTrackers.add(url);
        rec.trackers[url] =
            TrackerInfo(url: url, status: TrackerStatus.connecting);
      }
      for (final url in rec.request.extraTrackers) {
        rec.trackers.putIfAbsent(
          url,
          () => TrackerInfo(
            url: url,
            status: TrackerStatus.connecting,
            userAdded: true,
          ),
        );
        rec.userTrackers.add(url);
      }

      _showNotification(rec.taskId, 'Downloading Metadata', rec.movieTitle);
      _send(ProgressUpdate(
        taskId: rec.taskId,
        status: DownloadStatus.downloadingMetadata,
        trackers: rec.trackers.values.toList(),
      ));

      final md = MetadataDownloader.fromMagnet(rec.request.magnetUri);
      rec.metadata = md;
      final mdL = md.createListener();
      mdL
        ..on<MetaDataDownloadProgress>((event) {
          _send(ProgressUpdate(
            taskId: rec.taskId,
            status: DownloadStatus.downloadingMetadata,
            progress: event.progress.toDouble(),
          ));
        })
        ..on<MetaDataDownloadComplete>((event) async {
          await _enqueue(rec, event.data);
        })
        ..on<MetaDataDownloadFailed>((event) {
          _fail(rec, event.error);
        });
      md.startDownload();
    } catch (e, s) {
      log('beginMetadataPhase failed: $e', error: e, stackTrace: s);
      _fail(rec, e.toString());
    }
  }

  Future<void> _enqueue(_Record rec, List<int> metadataBytes) async {
    try {
      final decoded = decode(Uint8List.fromList(metadataBytes));
      final torrentMap = <String, dynamic>{'info': decoded};
      final model = TorrentParser.parseFromMap(torrentMap);
      rec.model = model;
      rec.totalBytes =
          model.length ?? model.files.fold<int>(0, (s, f) => s + f.length);

      final selected = rec.selectedIndices;
      if (selected != null) {
        final total = model.files.length;
        final selectedSet = selected.toSet();
        for (var i = 0; i < total; i++) {
          rec.filePriorities[i] = selectedSet.contains(i)
              ? FilePriorityLevel.normal
              : FilePriorityLevel.skip;
        }
      }

      final item = TorrentQueueItem(
        metaInfo: model,
        savePath: rec.savePath,
        priority: QueuePriority.normal,
        stream: rec.sequentialDownload,
        webSeeds: rec.webSeeds.isEmpty ? null : rec.webSeeds,
        acceptableSources:
            rec.acceptableSources.isEmpty ? null : rec.acceptableSources,
      );
      rec.queueItemId = item.id;
      _byQueueId[item.id] = rec.taskId;

      _qm.addToQueue(item);
      // QueueItemStarted will fire (sync or near-sync) and we'll wire the task.
      _send(ProgressUpdate(
        taskId: rec.taskId,
        status: DownloadStatus.queued,
        totalBytes: rec.totalBytes,
        files: rec.buildFileInfos(),
        trackers: rec.trackers.values.toList(),
        downloadSpeedLimit: rec.downloadSpeedLimit,
        uploadSpeedLimit: rec.uploadSpeedLimit,
        savedFilePath: rec.savePath,
        sequentialDownload: rec.sequentialDownload,
      ));
    } catch (e, s) {
      log('enqueue failed: $e', error: e, stackTrace: s);
      _fail(rec, e.toString());
    }
  }

  /// Called from QueueItemStarted — wire listeners, hand over peers and
  /// trackers from the metadata phase, apply pending priorities/limits.
  void _onTaskReady(_Record rec) {
    final task = rec.task;
    if (task == null) return;

    rec.taskListener = task.createListener();
    rec.taskListener!
      ..on<StateFileUpdated>((event) {
        _emitDebounced(rec);
      })
      ..on<TaskFileCompleted>((event) {
        _markFileCompleted(rec, event);
        _emitDebounced(rec);
      })
      ..on<TaskCompleted>((event) {
        // QueueManager will fire QueueItemCompleted too; nothing extra here.
      })
      ..on<TaskStopped>((event) {
        // Same.
      });

    // Transfer peers from the metadata downloader to avoid cold reconnect.
    final md = rec.metadata;
    if (md != null) {
      for (final peer in md.activePeers) {
        try {
          task.addPeer(peer.address, PeerSource.manual, type: peer.type);
        } catch (_) {}
      }
      md.stop();
      rec.metadata = null;
    }

    // Magnet + user-added trackers (the model's own announces are wired by
    // the task itself; this adds the extras).
    final infoHash = rec.infoHashBuffer;
    if (infoHash != null) {
      for (final url in rec.trackers.keys) {
        try {
          task.startAnnounceUrl(Uri.parse(url), infoHash);
          rec.trackers[url] =
              rec.trackers[url]!.copyWith(status: TrackerStatus.working);
        } catch (e) {
          rec.trackers[url] = rec.trackers[url]!.copyWith(
            status: TrackerStatus.failed,
            errorMessage: e.toString(),
          );
        }
      }
    }

    if (rec.filePriorities.isNotEmpty) _applyAllPriorities(rec);
    _applySpeedLimits(rec);

    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: DownloadStatus.downloading,
      totalBytes: rec.totalBytes,
      files: rec.buildFileInfos(),
      trackers: rec.trackers.values.toList(),
      downloadSpeedLimit: rec.downloadSpeedLimit,
      uploadSpeedLimit: rec.uploadSpeedLimit,
      savedFilePath: rec.savePath,
      sequentialDownload: rec.sequentialDownload,
    ));
  }

  void pauseDownload(DownloadControlRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    final qid = rec.queueItemId;
    if (qid != null) {
      // Active or queued — let QueueManager handle the state transition.
      _qm.pauseDownload(qid);
      rec.pausedByUser = true;
    } else {
      // Still in metadata phase.
      rec.metadata?.stop();
      rec.pausedByUser = true;
    }
    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: DownloadStatus.paused,
    ));
  }

  void resumeDownload(DownloadControlRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    rec.pausedByUser = false;
    final qid = rec.queueItemId;
    if (qid != null && rec.task != null) {
      _qm.resumeDownload(qid);
      _send(ProgressUpdate(
        taskId: rec.taskId,
        status: DownloadStatus.downloading,
      ));
    } else {
      // Metadata phase pause → restart metadata.
      unawaited(_beginMetadataPhase(rec));
    }
  }

  Future<void> stopDownload(DownloadControlRequest request) async {
    final rec = _records[request.taskId];
    if (rec == null) return;
    final qid = rec.queueItemId;
    if (qid != null) {
      await _qm.stopDownload(qid);
      await _qm.removeFromQueue(qid);
    }
    rec.metadata?.stop();
    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: DownloadStatus.stopped,
    ));
    _disposeRecord(rec, removeFromMap: true);
  }

  // ---- speed limits via ScheduleWindow ----

  void setSpeedLimit(SetSpeedLimitRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    rec.downloadSpeedLimit = request.downloadLimit;
    rec.uploadSpeedLimit = request.uploadLimit;
    _applySpeedLimits(rec);
    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: rec.lastStatus,
      downloadSpeedLimit: rec.downloadSpeedLimit,
      uploadSpeedLimit: rec.uploadSpeedLimit,
    ));
  }

  /// Register a 24/7 ScheduleWindow that never auto-pauses the task. This is
  /// how dtorrent_task_v2 exposes per-task speed caps.
  void _applySpeedLimits(_Record rec) {
    final task = rec.task;
    if (task == null) return;
    try {
      task.removeScheduleWindow(rec.scheduleWindowId);
    } catch (_) {}
    if (rec.downloadSpeedLimit == null && rec.uploadSpeedLimit == null) return;
    try {
      task.addScheduleWindow(ScheduleWindow(
        id: rec.scheduleWindowId,
        weekdays: const {1, 2, 3, 4, 5, 6, 7},
        start: Duration.zero,
        end: const Duration(hours: 23, minutes: 59, seconds: 59),
        maxDownloadRate: rec.downloadSpeedLimit,
        maxUploadRate: rec.uploadSpeedLimit,
        pauseOutsideWindow: false,
      ));
      task.startScheduling(tick: const Duration(seconds: 30));
    } catch (e) {
      log('addScheduleWindow failed: $e');
    }
  }

  // ---- file priority ----

  void setFilePriority(SetFilePriorityRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    rec.filePriorities[request.fileIndex] = request.priority;
    final task = rec.task;
    if (task != null) {
      try {
        task.setFilePriority(
            request.fileIndex, _toNativePriority(request.priority));
      } catch (e) {
        log('setFilePriority failed: $e');
      }
    }
    _emitDebounced(rec);
  }

  void applyFileSelection(ApplyFileSelectionRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    final total = rec.model?.files.length ?? 0;
    final selected = request.selectedIndices.toSet();
    for (var i = 0; i < total; i++) {
      rec.filePriorities[i] = selected.contains(i)
          ? FilePriorityLevel.normal
          : FilePriorityLevel.skip;
    }
    _applyAllPriorities(rec);
    _emitDebounced(rec);
  }

  void autoPrioritize(int taskId) {
    final rec = _records[taskId];
    final task = rec?.task;
    if (rec == null || task == null) return;
    try {
      task.autoPrioritizeFiles();
      // Pull back the priorities the task chose so the UI reflects them.
      final total = rec.model?.files.length ?? 0;
      for (var i = 0; i < total; i++) {
        try {
          rec.filePriorities[i] = _fromNativePriority(task.getFilePriority(i));
        } catch (_) {}
      }
    } catch (e) {
      log('autoPrioritizeFiles failed: $e');
    }
    _emitDebounced(rec);
  }

  void _applyAllPriorities(_Record rec) {
    final task = rec.task;
    if (task == null) return;
    final native = <int, FilePriority>{};
    rec.filePriorities.forEach((idx, lvl) {
      native[idx] = _toNativePriority(lvl);
    });
    if (native.isEmpty) return;
    try {
      task.setFilePriorities(native);
    } catch (e) {
      log('setFilePriorities failed: $e — falling back to per-file');
      for (final entry in native.entries) {
        try {
          task.setFilePriority(entry.key, entry.value);
        } catch (_) {}
      }
    }
  }

  // ---- trackers ----

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
        rec.trackers[url] =
            rec.trackers[url]!.copyWith(status: TrackerStatus.working);
      } catch (e) {
        rec.trackers[url] = rec.trackers[url]!.copyWith(
          status: TrackerStatus.failed,
          errorMessage: e.toString(),
        );
      }
    }
    _emitDebounced(rec);
  }

  /// dtorrent_task_v2 has no public removeTracker on TorrentTask; we drop it
  /// from our bookkeeping (UI reflects). The live tracker connection stays
  /// until the task is fully stopped and restarted.
  void removeTracker(RemoveTrackerRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    rec.userTrackers.remove(request.trackerUrl);
    rec.trackers.remove(request.trackerUrl);
    _emitDebounced(rec);
  }

  // ---- task move ----

  Future<void> moveDownloadTask(MoveDownloadTaskRequest request) async {
    final rec = _records[request.taskId];
    if (rec == null) return;
    final task = rec.task;
    try {
      if (task != null && rec.model != null) {
        final model = rec.model!;
        for (final file in model.files) {
          final relative = file.path.isEmpty ? file.name : file.path;
          final normalized = relative.replaceAll('/', Platform.pathSeparator);
          final target =
              '${request.newSavePath}${Platform.pathSeparator}$normalized';
          await task.moveDownloadedFile(relative, target);
        }
        await task.detectMovedFiles();
      } else {
        await _moveTaskDirectly(rec, request.newSavePath);
      }
      rec.savePath = request.newSavePath;
      _send(ProgressUpdate(
        taskId: rec.taskId,
        status: rec.lastStatus,
        savedFilePath: rec.savePath,
      ));
    } catch (e) {
      log('moveDownloadTask failed: $e');
    }
    _emitDebounced(rec);
  }

  Future<void> _moveTaskDirectly(_Record rec, String newSavePath) async {
    final model = rec.model;
    if (model == null) return;
    for (final file in model.files) {
      final relative = file.path.isEmpty ? file.name : file.path;
      final normalized = relative.replaceAll('/', Platform.pathSeparator);
      final fromPath = '${rec.savePath}${Platform.pathSeparator}$normalized';
      final toPath = '$newSavePath${Platform.pathSeparator}$normalized';
      final src = File(fromPath);
      if (!await src.exists()) continue;
      try {
        await Directory(File(toPath).parent.path).create(recursive: true);
      } catch (_) {}
      await src.rename(toPath);
    }
  }

  Future<void> _scrapeAllTrackers() async {
    for (final rec in _records.values) {
      final task = rec.task;
      final hex = rec.infoHashHex;
      if (task == null || hex == null) continue;
      for (final url in rec.trackers.keys.toList()) {
        try {
          final result = await task.scrapeTracker(Uri.parse(url));
          if (!result.isSuccess) continue;
          final stats = result.getStatsForInfoHash(hex);
          if (stats != null) {
            rec.trackers[url] =
                (rec.trackers[url] ?? TrackerInfo(url: url)).copyWith(
              status: TrackerStatus.working,
              seeders: stats.complete,
              leechers: stats.incomplete,
            );
          }
        } catch (e) {
          if (rec.trackers.containsKey(url)) {
            rec.trackers[url] = rec.trackers[url]!.copyWith(
              status: TrackerStatus.failed,
              errorMessage: e.toString(),
            );
          }
        }
      }
      _emitDebounced(rec);
    }
  }

  // ---- snapshot emission ----

  void _emitDebounced(_Record rec) {
    _emitDebounce[rec.taskId]?.cancel();
    _emitDebounce[rec.taskId] = Timer(const Duration(milliseconds: 500), () {
      _emitDebounce.remove(rec.taskId);
      _emitFromTask(rec);
    });
  }

  void _emitFromTask(_Record rec) {
    final task = rec.task;
    if (task == null) return;
    final progress = task.progress;
    final dl = task.currentDownloadSpeed.toInt();
    final ul = task.uploadSpeed.toInt();
    final peers = task.connectedPeersNumber;
    final seeders = task.seederNumber;
    final downloaded = (task.downloaded ?? 0).toInt();

    rec.lastStatus =
        rec.pausedByUser ? DownloadStatus.paused : DownloadStatus.downloading;

    _showNotification(
      rec.taskId,
      rec.movieTitle,
      '${(progress * 100).toStringAsFixed(1)}% • '
      '${_fmtSpeed(dl)} ↓ ${_fmtSpeed(ul)} ↑',
      progress: (progress * 100).toInt(),
      maxProgress: 100,
    );

    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: rec.lastStatus,
      progress: progress,
      downloadSpeed: dl,
      uploadSpeed: ul,
      peers: peers,
      seeders: seeders,
      downloadedBytes: downloaded,
      totalBytes: rec.totalBytes,
      files: rec.buildFileInfos(),
      trackers: rec.trackers.values.toList(),
      downloadSpeedLimit: rec.downloadSpeedLimit,
      uploadSpeedLimit: rec.uploadSpeedLimit,
      sequentialDownload: rec.sequentialDownload,
    ));
  }

  void _markFileCompleted(_Record rec, TaskFileCompleted event) {
    final m = rec.model;
    if (m == null) return;
    try {
      final name = event.file.originalFileName;
      final idx = m.files.indexWhere(
        (f) => f.path == name || f.name == name,
      );
      if (idx >= 0) {
        final size = m.files[idx].length;
        rec.fileDownloaded[idx] = size;
        rec.completedFiles.add(idx);
      }
    } catch (_) {}
  }

  // ---- helpers ----

  void _fail(_Record rec, String error) {
    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: DownloadStatus.failed,
      error: error,
    ));
    _disposeRecord(rec, removeFromMap: true);
  }

  void _disposeRecord(_Record rec, {required bool removeFromMap}) {
    rec.taskListener?.dispose();
    rec.taskListener = null;
    try {
      rec.metadata?.stop();
    } catch (_) {}
    rec.metadata = null;
    _emitDebounce.remove(rec.taskId)?.cancel();
    if (removeFromMap) {
      _records.remove(rec.taskId);
      final qid = rec.queueItemId;
      if (qid != null) _byQueueId.remove(qid);
    }
  }

  void _send(ProgressUpdate update) {
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

  String _fmtSpeed(int bytes) {
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

  Future<void> cleanup() async {
    _periodicTimer?.cancel();
    _scrapeTimer?.cancel();
    for (final t in _emitDebounce.values) {
      t.cancel();
    }
    _emitDebounce.clear();
    for (final rec in _records.values.toList()) {
      _disposeRecord(rec, removeFromMap: false);
    }
    _records.clear();
    _byQueueId.clear();
    try {
      await _qm.dispose();
    } catch (e) {
      log('QueueManager dispose: $e');
    }
  }
}
