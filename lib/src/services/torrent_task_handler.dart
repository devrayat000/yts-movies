import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:libtorrent_flutter/libtorrent_flutter.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/torrent_service_models.dart';

const String notificationChannelId = 'torrent_downloads';
const int notificationId = 888;

/// Background-isolate entry point. libtorrent_flutter holds a single FFI
/// session per process, so the engine lives entirely inside this isolate
/// and the main isolate talks to it via flutter_background_service IPC.
@pragma('vm:entry-point')
void onStartBackgroundService(ServiceInstance service) async {
  log('onStartBackgroundService: enter (pid=$pid)', name: 'BackgroundService');
  DartPluginRegistrant.ensureInitialized();
  log('onStartBackgroundService: DartPluginRegistrant ready',
      name: 'BackgroundService');
  final notifications = FlutterLocalNotificationsPlugin();

  if (!LibtorrentFlutter.isInitialized) {
    log('LibtorrentFlutter.init starting (defaultSavePath=${Directory.systemTemp.path})',
        name: 'BackgroundService');
    try {
      await LibtorrentFlutter.init(
        defaultSavePath: Directory.systemTemp.path,
        fetchTrackers: false,
        pollInterval: const Duration(milliseconds: 750),
      );
      log('LibtorrentFlutter.init OK (version=${LibtorrentFlutter.instance.libraryVersion})',
          name: 'BackgroundService');
    } catch (e, s) {
      log('LibtorrentFlutter.init FAILED: $e',
          error: e, stackTrace: s, name: 'BackgroundService');
      rethrow;
    }
  } else {
    log('LibtorrentFlutter already initialized', name: 'BackgroundService');
  }

  final handler = _TorrentHandler(service, notifications);
  log('_TorrentHandler constructed', name: 'BackgroundService');

  service.on('startDownload').listen((event) {
    log('IPC<- startDownload: $event', name: 'BackgroundService');
    if (event == null) {
      log('IPC<- startDownload: null payload, ignoring',
          name: 'BackgroundService');
      return;
    }
    try {
      handler.startDownload(StartDownloadRequest.fromJson(event));
    } catch (e, s) {
      log('IPC<- startDownload parse error: $e',
          error: e, stackTrace: s, name: 'BackgroundService');
    }
  });
  service.on('pauseDownload').listen((event) {
    log('IPC<- pauseDownload: $event', name: 'BackgroundService');
    if (event != null) {
      handler.pauseDownload(DownloadControlRequest.fromJson(event));
    }
  });
  service.on('resumeDownload').listen((event) {
    log('IPC<- resumeDownload: $event', name: 'BackgroundService');
    if (event != null) {
      handler.resumeDownload(DownloadControlRequest.fromJson(event));
    }
  });
  service.on('stopDownload').listen((event) {
    log('IPC<- stopDownload: $event', name: 'BackgroundService');
    if (event != null) {
      handler.stopDownload(DownloadControlRequest.fromJson(event));
    }
  });
  service.on('setSpeedLimit').listen((event) {
    log('IPC<- setSpeedLimit: $event', name: 'BackgroundService');
    if (event != null) {
      handler.setSpeedLimit(SetSpeedLimitRequest.fromJson(event));
    }
  });
  service.on('setFilePriority').listen((event) {
    log('IPC<- setFilePriority: $event', name: 'BackgroundService');
    if (event != null) {
      handler.setFilePriority(SetFilePriorityRequest.fromJson(event));
    }
  });
  service.on('applyFileSelection').listen((event) {
    log('IPC<- applyFileSelection: $event', name: 'BackgroundService');
    if (event != null) {
      handler.applyFileSelection(ApplyFileSelectionRequest.fromJson(event));
    }
  });
  service.on('deleteDownload').listen((event) {
    log('IPC<- deleteDownload: $event', name: 'BackgroundService');
    if (event != null) {
      handler.deleteDownload(DownloadControlRequest.fromJson(event));
    }
  });
  service.on('stopService').listen((event) async {
    log('IPC<- stopService', name: 'BackgroundService');
    await handler.shutdown();
    service.stopSelf();
  });

  log('onStartBackgroundService: ready, listening on IPC',
      name: 'BackgroundService');
}

/// Per-task bookkeeping inside the background isolate.
class _Task {
  _Task({
    required this.taskId,
    required this.movieTitle,
    required this.savePath,
    required this.selectedIndices,
    required this.previewMode,
  });

  final int taskId;
  final String movieTitle;
  final String savePath;
  List<int>? selectedIndices;
  bool previewMode;
  int? torrentId;
  final Map<int, FilePriorityLevel> priorities = {};
  List<TorrentFileInfo>? files;
  bool prioritiesPushed = false;
  bool completionEmitted = false;
  bool pausedByUser = false;
  DownloadStatus lastStatus = DownloadStatus.queued;

  double progress = 0;
  int downloadSpeed = 0;
  int uploadSpeed = 0;
  int totalDone = 0;
  int totalWanted = 0;
  int peers = 0;
  int seeders = 0;

  @override
  String toString() => '_Task(id=$taskId, title="$movieTitle", '
      'tid=$torrentId, status=$lastStatus, preview=$previewMode, '
      'pausedByUser=$pausedByUser, completionEmitted=$completionEmitted, '
      'prioritiesPushed=$prioritiesPushed, sel=$selectedIndices, '
      'progress=${(progress * 100).toStringAsFixed(1)}%, '
      'done=$totalDone/$totalWanted, peers=$peers, seeders=$seeders)';
}

int _priorityToInt(FilePriorityLevel level) {
  switch (level) {
    case FilePriorityLevel.skip:
      return 0;
    case FilePriorityLevel.low:
      return 1;
    case FilePriorityLevel.normal:
      return 4;
    case FilePriorityLevel.high:
      return 7;
  }
}

String _infoStr(TorrentInfo i) =>
    'TorrentInfo(id=${i.id}, name="${i.name}", state=${i.state}, '
    'progress=${(i.progress * 100).toStringAsFixed(1)}%, '
    'dlRate=${i.downloadRate}, ulRate=${i.uploadRate}, '
    'totalDone=${i.totalDone}, totalWanted=${i.totalWanted}, '
    'peers=${i.numPeers}, seeds=${i.numSeeds}, '
    'isPaused=${i.isPaused}, isFinished=${i.isFinished}, '
    'hasMetadata=${i.hasMetadata}, err="${i.errorMsg}")';

class _TorrentHandler {
  _TorrentHandler(this.service, this.notifications) {
    log('_TorrentHandler: subscribing to torrentUpdates',
        name: '_TorrentHandler');
    _torrentSub = _engine.torrentUpdates.listen(
      _onSnapshot,
      onError: (Object e, StackTrace s) => log(
          'torrentUpdates stream error: $e',
          error: e,
          stackTrace: s,
          name: '_TorrentHandler'),
      onDone: () =>
          log('torrentUpdates stream closed', name: '_TorrentHandler'),
    );
    _aggregateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateForegroundNotification();
    });
  }

  final ServiceInstance service;
  final FlutterLocalNotificationsPlugin notifications;
  final LibtorrentFlutter _engine = LibtorrentFlutter.instance;

  final Map<int, _Task> _tasks = {};
  final Map<int, int> _torrentToTask = {};

  StreamSubscription<Map<int, TorrentInfo>>? _torrentSub;
  Timer? _aggregateTimer;
  Timer? _idleStopTimer;
  bool _shuttingDown = false;
  bool _shutdownComplete = false;

  int? _sessionDl;
  int? _sessionUl;

  static const Duration _idleGrace = Duration(seconds: 30);

  // ─── IPC commands ────────────────────────────────────────────────────────

  Future<void> startDownload(StartDownloadRequest req) async {
    log('startDownload: req=$req', name: '_TorrentHandler');
    if (_tasks.containsKey(req.taskId)) {
      log('startDownload: ${req.taskId} already running, skipping',
          name: '_TorrentHandler');
      return;
    }
    _cancelIdleStop();

    final task = _Task(
      taskId: req.taskId,
      movieTitle: req.movieTitle,
      savePath: req.savePath,
      selectedIndices: req.selectedIndices,
      previewMode: req.previewMode,
    );
    _tasks[req.taskId] = task;
    log('startDownload: task registered $task', name: '_TorrentHandler');

    try {
      await Directory(task.savePath).create(recursive: true);
      log('startDownload: savePath ready (${task.savePath})',
          name: '_TorrentHandler');
    } catch (e, s) {
      log('startDownload: save dir create failed (${task.savePath}): $e',
          error: e, stackTrace: s, name: '_TorrentHandler');
    }

    if (req.initialDownloadLimit != null) {
      _sessionDl = req.initialDownloadLimit;
      _engine.setDownloadLimit(_sessionDl ?? 0);
      log('startDownload: session DL limit set to $_sessionDl',
          name: '_TorrentHandler');
    }
    if (req.initialUploadLimit != null) {
      _sessionUl = req.initialUploadLimit;
      _engine.setUploadLimit(_sessionUl ?? 0);
      log('startDownload: session UL limit set to $_sessionUl',
          name: '_TorrentHandler');
    }

    try {
      log('startDownload: calling addMagnet (savePath=${task.savePath})',
          name: '_TorrentHandler');
      final torrentId = _engine.addMagnet(req.magnetUri, task.savePath);
      task.torrentId = torrentId;
      _torrentToTask[torrentId] = task.taskId;
      log('startDownload: addMagnet OK torrentId=$torrentId for task=${task.taskId}',
          name: '_TorrentHandler');
    } catch (e, s) {
      log('startDownload: addMagnet FAILED: $e',
          error: e, stackTrace: s, name: '_TorrentHandler');
      _fail(task, e.toString());
      return;
    }

    task.lastStatus = DownloadStatus.downloadingMetadata;
    _updateForegroundNotification();
    _emit(task);
  }

  void pauseDownload(DownloadControlRequest req) {
    log('pauseDownload: taskId=${req.taskId}');
    final task = _tasks[req.taskId];
    if (task == null) {
      log('pauseDownload: no task for ${req.taskId}, ignoring',
          name: '_TorrentHandler');
      return;
    }
    final tid = task.torrentId;
    if (tid != null) {
      _engine.pauseTorrent(tid);
      log('pauseDownload: engine.pauseTorrent($tid) called',
          name: '_TorrentHandler');
    } else {
      log('pauseDownload: task has no torrentId yet', name: '_TorrentHandler');
    }
    task.pausedByUser = true;
    task.lastStatus = DownloadStatus.paused;
    _emit(task);
  }

  void resumeDownload(DownloadControlRequest req) {
    log('resumeDownload: taskId=${req.taskId}', name: '_TorrentHandler');
    final task = _tasks[req.taskId];
    if (task == null) {
      log('resumeDownload: no task for ${req.taskId}, ignoring',
          name: '_TorrentHandler');
      return;
    }
    _cancelIdleStop();
    task.pausedByUser = false;
    final tid = task.torrentId;
    if (tid != null) {
      _engine.resumeTorrent(tid);
      log('resumeDownload: engine.resumeTorrent($tid) called',
          name: '_TorrentHandler');
    }
    task.lastStatus = task.previewMode || task.totalWanted == 0
        ? DownloadStatus.downloadingMetadata
        : DownloadStatus.downloading;
    log('resumeDownload: optimistic status -> ${task.lastStatus}',
        name: '_TorrentHandler');
    _emit(task);
  }

  void stopDownload(DownloadControlRequest req) {
    log('stopDownload: taskId=${req.taskId}', name: '_TorrentHandler');
    final task = _tasks[req.taskId];
    if (task == null) {
      log('stopDownload: no task for ${req.taskId}, ignoring',
          name: '_TorrentHandler');
      return;
    }
    _detachFromEngine(task);
    _tasks.remove(task.taskId);
    _cancelTaskNotification(task.taskId);
    task.lastStatus = DownloadStatus.stopped;
    _emit(task);
    _scheduleIdleStop();
  }

  /// Drop the torrent AND wipe its on-disk files via libtorrent. Cleaner
  /// than manual fs deletion because the engine releases its file handles
  /// before unlinking, which matters on Windows.
  void deleteDownload(DownloadControlRequest req) {
    log('deleteDownload: taskId=${req.taskId}', name: '_TorrentHandler');
    final task = _tasks[req.taskId];
    if (task == null) {
      log(
          'deleteDownload: no task in engine for ${req.taskId} '
          '(probably rehydrated/stopped) — main isolate will sweep disk',
          name: '_TorrentHandler');
      return;
    }
    final tid = task.torrentId;
    if (tid != null) {
      try {
        _engine.removeTorrent(tid, deleteFiles: true);
        log('deleteDownload: removeTorrent(tid=$tid, deleteFiles=true) OK',
            name: '_TorrentHandler');
      } catch (e, s) {
        log('deleteDownload: removeTorrent failed: $e',
            error: e, stackTrace: s, name: '_TorrentHandler');
      }
      _torrentToTask.remove(tid);
    }
    _tasks.remove(task.taskId);
    _cancelTaskNotification(task.taskId);
    task.lastStatus = DownloadStatus.stopped;
    _emit(task);
    _scheduleIdleStop();
  }

  void setSpeedLimit(SetSpeedLimitRequest req) {
    log('setSpeedLimit: dl=${req.downloadLimit}, ul=${req.uploadLimit}',
        name: '_TorrentHandler');
    final task = _tasks[req.taskId];
    if (task == null) {
      log('setSpeedLimit: no task for ${req.taskId}, ignoring',
          name: '_TorrentHandler');
      return;
    }
    _sessionDl = req.downloadLimit;
    _sessionUl = req.uploadLimit;
    _engine.setDownloadLimit(_sessionDl ?? 0);
    _engine.setUploadLimit(_sessionUl ?? 0);
    log('setSpeedLimit: applied session-wide dl=$_sessionDl, ul=$_sessionUl',
        name: '_TorrentHandler');
    _emit(task);
  }

  void setFilePriority(SetFilePriorityRequest req) {
    log(
        'setFilePriority: taskId=${req.taskId}, file=${req.fileIndex}, '
        'prio=${req.priority}',
        name: '_TorrentHandler');
    final task = _tasks[req.taskId];
    if (task == null) {
      log('setFilePriority: no task, ignoring', name: '_TorrentHandler');
      return;
    }
    task.priorities[req.fileIndex] = req.priority;
    _pushPriorities(task);
    final files = task.files;
    if (files != null) {
      task.files = [
        for (final f in files)
          f.index == req.fileIndex ? f.copyWith(priority: req.priority) : f,
      ];
    }
    _emit(task);
  }

  void applyFileSelection(ApplyFileSelectionRequest req) {
    log(
        'applyFileSelection: taskId=${req.taskId}, '
        'selected=${req.selectedIndices}',
        name: '_TorrentHandler');
    final task = _tasks[req.taskId];
    if (task == null) {
      log('applyFileSelection: no task, ignoring', name: '_TorrentHandler');
      return;
    }
    final wasPreview = task.previewMode;
    task.previewMode = false;
    task.selectedIndices = List<int>.from(req.selectedIndices);
    final selected = req.selectedIndices.toSet();
    final tid = task.torrentId;
    final fileCount = tid == null ? 0 : _engine.getFiles(tid).length;
    log('applyFileSelection: wasPreview=$wasPreview, fileCount=$fileCount',
        name: '_TorrentHandler');
    for (var i = 0; i < fileCount; i++) {
      task.priorities[i] = selected.contains(i)
          ? FilePriorityLevel.normal
          : FilePriorityLevel.skip;
    }
    _pushPriorities(task);
    final files = task.files;
    if (files != null) {
      task.files = [
        for (final f in files)
          f.copyWith(
            priority: task.priorities[f.index] ?? FilePriorityLevel.normal,
          ),
      ];
    }
    _emit(task);
  }

  // ─── Engine snapshot handling ────────────────────────────────────────────

  int _snapshotCounter = 0;

  void _onSnapshot(Map<int, TorrentInfo> snapshot) {
    _snapshotCounter++;
    // Log every snapshot in full while debugging — re-enable throttling once
    // download flow is verified end-to-end.
    const verbose = true;
    if (verbose) {
      log(
          '_onSnapshot #$_snapshotCounter: '
          '${snapshot.length} torrents, map=$_torrentToTask',
          name: '_TorrentHandler');
    }
    for (final entry in snapshot.entries) {
      final taskId = _torrentToTask[entry.key];
      if (taskId == null) {
        if (verbose) {
          log('_onSnapshot: unknown torrentId=${entry.key}, skipping',
              name: '_TorrentHandler');
        }
        continue;
      }
      final task = _tasks[taskId];
      if (task == null) {
        log(
            '_onSnapshot: stale taskId=$taskId for torrentId=${entry.key}, '
            'cleaning up',
            name: '_TorrentHandler');
        _torrentToTask.remove(entry.key);
        continue;
      }
      _applySnapshot(task, entry.value, verbose: verbose);
    }
  }

  void _applySnapshot(_Task task, TorrentInfo info, {required bool verbose}) {
    if (verbose) {
      log('_applySnapshot[task=${task.taskId}]: ${_infoStr(info)}',
          name: '_TorrentHandler');
    }
    if (!task.prioritiesPushed && info.hasMetadata) {
      log(
          '_applySnapshot: first metadata for task=${task.taskId}, '
          'reading files + pushing priorities',
          name: '_TorrentHandler');
      task.files = _readFiles(task);
      _pushPriorities(task);
    }

    // libtorrent reports progress=1.0 when totalWanted==0 (vacuously done).
    // Suppress that — UI flashes 100% otherwise during the metadata window
    // and the brief settle right after applyFileSelection.
    task.progress = (info.totalWanted > 0 && info.hasMetadata)
        ? info.progress.clamp(0.0, 1.0)
        : 0.0;
    task.downloadSpeed = info.downloadRate;
    task.uploadSpeed = info.uploadRate;
    task.totalDone = info.totalDone;
    if (info.totalWanted > 0) task.totalWanted = info.totalWanted;
    task.peers = info.numPeers;
    task.seeders = info.numSeeds;

    final prevStatus = task.lastStatus;
    final newStatus = _statusFor(task, info);
    task.lastStatus = newStatus;

    if (prevStatus != newStatus) {
      log(
          '_applySnapshot[task=${task.taskId}]: status $prevStatus -> '
          '$newStatus (totalWanted=${info.totalWanted}, '
          'totalDone=${info.totalDone}, isFinished=${info.isFinished}, '
          'state=${info.state}, hasMetadata=${info.hasMetadata}, '
          'previewMode=${task.previewMode})',
          name: '_TorrentHandler');
    }

    if (newStatus == DownloadStatus.completed && !task.completionEmitted) {
      log(
          '_applySnapshot[task=${task.taskId}]: ** COMPLETION LATCH SET ** '
          'totalDone=${info.totalDone}, totalWanted=${info.totalWanted}, '
          'isFinished=${info.isFinished}, '
          'progress=${(info.progress * 100).toStringAsFixed(2)}%, '
          'state=${info.state}',
          name: '_TorrentHandler');
      task.completionEmitted = true;
      _markFilesComplete(task);
      _showCompletionNotification(task);
      // Refresh foreground notification immediately so it stops showing
      // this task as in-progress.
      _updateForegroundNotification();
      _scheduleIdleStop();
    } else if (newStatus == DownloadStatus.downloading) {
      // Per-task notifications get noisy when multiple downloads run; the
      // foreground service notification carries progress + speeds.
      _updateForegroundNotification();
    } else if (newStatus == DownloadStatus.failed &&
        prevStatus != DownloadStatus.failed) {
      log('_applySnapshot[task=${task.taskId}]: FAILED, errorMsg="${info.errorMsg}"');
      _scheduleIdleStop();
    }

    _emit(task, error: info.errorMsg.isEmpty ? null : info.errorMsg);
  }

  /// Map a libtorrent snapshot to our UI-facing [DownloadStatus].
  ///
  /// libtorrent quirks:
  ///   - `isFinished` is true whenever `totalDone >= totalWanted`. That
  ///     holds spuriously when totalWanted==0 (no metadata yet, or for a
  ///     few polls right after priorities change).
  ///   - state `finished`/`seeding` means engine has every wanted byte.
  /// Completion is gated on `hasMetadata && totalWanted > 0`.
  DownloadStatus _statusFor(_Task task, TorrentInfo info) {
    if (info.errorMsg.isNotEmpty || info.state == TorrentState.error) {
      return DownloadStatus.failed;
    }
    if (task.previewMode) return DownloadStatus.downloadingMetadata;
    if (task.pausedByUser || info.isPaused) return DownloadStatus.paused;
    if (!info.hasMetadata || info.state == TorrentState.downloadingMetadata) {
      return DownloadStatus.downloadingMetadata;
    }
    // Escape hatch: if the latch was set by a stale/transient snapshot
    // (libtorrent briefly reported isFinished=true while priorities were
    // mid-propagation), drop it when the engine clearly shows mid-download.
    if (task.completionEmitted &&
        info.totalWanted > 0 &&
        info.totalDone < info.totalWanted &&
        info.progress < 0.999) {
      log(
          '_statusFor[task=${task.taskId}]: clearing stale completion latch '
          '(done=${info.totalDone}/${info.totalWanted}, '
          'progress=${(info.progress * 100).toStringAsFixed(1)}%)',
          name: '_TorrentHandler');
      task.completionEmitted = false;
    }
    if (task.completionEmitted) return DownloadStatus.completed;
    // Trust byte counts and progress %, not `state` or `isFinished` alone.
    // libtorrent_flutter has been observed reporting state=finished /
    // isFinished=true with totalDone << totalWanted during the brief window
    // right after priorities change (preview commit). Require ALL of:
    //   - totalWanted positive
    //   - isFinished flag set
    //   - totalDone >= totalWanted (all wanted bytes on disk)
    //   - progress >= 99.9% (defensive — guards against the transient case
    //     where totalWanted briefly equals a tiny totalDone)
    final actuallyDone = info.totalWanted > 0 &&
        info.isFinished &&
        info.totalDone >= info.totalWanted &&
        info.progress >= 0.999;
    if (actuallyDone) return DownloadStatus.completed;
    if (info.totalWanted == 0) return DownloadStatus.downloadingMetadata;
    return DownloadStatus.downloading;
  }

  List<TorrentFileInfo> _readFiles(_Task task) {
    final tid = task.torrentId;
    if (tid == null) {
      log('_readFiles: no torrentId for task=${task.taskId}');
      return const [];
    }
    final raw = _engine.getFiles(tid);
    log('_readFiles[task=${task.taskId}]: engine returned ${raw.length} files');
    final out = [
      for (final f in raw)
        TorrentFileInfo(
          index: f.index,
          name: f.path.isNotEmpty ? f.path : f.name,
          size: f.size,
          downloaded: 0,
          priority: task.priorities[f.index] ?? FilePriorityLevel.normal,
          completed: false,
        ),
    ];
    for (final f in out) {
      log('  file[${f.index}]: name="${f.name}", size=${f.size}, prio=${f.priority}');
    }
    return out;
  }

  /// Compute the priority vector and ship it to libtorrent. Safe to call any
  /// time after metadata is available; no-op otherwise.
  void _pushPriorities(_Task task) {
    final tid = task.torrentId;
    if (tid == null) {
      log('_pushPriorities: no torrentId for task=${task.taskId}, skip');
      return;
    }
    final files = _engine.getFiles(tid);
    if (files.isEmpty) {
      log('_pushPriorities[task=${task.taskId}]: no files yet (metadata pending), skip');
      return;
    }

    final selected = task.selectedIndices?.toSet();
    final vector = List<int>.generate(files.length, (i) {
      final explicit = task.priorities[i];
      if (explicit != null) return _priorityToInt(explicit);
      final FilePriorityLevel level;
      if (task.previewMode) {
        level = FilePriorityLevel.skip;
      } else if (selected != null && !selected.contains(i)) {
        level = FilePriorityLevel.skip;
      } else {
        level = FilePriorityLevel.normal;
      }
      task.priorities[i] = level;
      return _priorityToInt(level);
    });
    log(
        '_pushPriorities[task=${task.taskId}]: vector=$vector '
        '(previewMode=${task.previewMode}, selected=$selected)',
        name: '_TorrentHandler');
    try {
      _engine.setFilePriorities(tid, vector);
      task.prioritiesPushed = true;
      log('_pushPriorities[task=${task.taskId}]: engine ack',
          name: '_TorrentHandler');
    } catch (e, s) {
      log('_pushPriorities[task=${task.taskId}]: FAILED $e',
          error: e, stackTrace: s, name: '_TorrentHandler');
    }
  }

  void _markFilesComplete(_Task task) {
    final files = task.files;
    if (files == null) return;
    task.files = [
      for (final f in files)
        if (f.priority == FilePriorityLevel.skip)
          f
        else
          f.copyWith(downloaded: f.size, completed: true),
    ];
  }

  // ─── IPC emit + lifecycle ────────────────────────────────────────────────

  int _emitCounter = 0;

  void _emit(_Task task, {String? error}) {
    _emitCounter++;
    final verbose = _emitCounter <= 10 || _emitCounter % 5 == 0;
    final update = ProgressUpdate(
      taskId: task.taskId,
      status: task.lastStatus,
      progress: task.progress,
      downloadSpeed: task.downloadSpeed,
      uploadSpeed: task.uploadSpeed,
      peers: task.peers,
      seeders: task.seeders,
      downloadedBytes: task.totalDone,
      totalBytes: task.totalWanted,
      files: task.files,
      savedFilePath: task.savePath,
      downloadSpeedLimit: _sessionDl,
      uploadSpeedLimit: _sessionUl,
      error: error,
    );
    if (verbose) {
      log(
          'IPC-> progressUpdate #$_emitCounter: '
          'task=${task.taskId}, status=${task.lastStatus}, '
          'progress=${(task.progress * 100).toStringAsFixed(1)}%, '
          'dl=${task.downloadSpeed}, ul=${task.uploadSpeed}, '
          'done=${task.totalDone}/${task.totalWanted}, error=$error',
          name: '_TorrentHandler');
    }
    try {
      service.invoke('progressUpdate', update.toJson());
    } catch (e, s) {
      log('_emit: service.invoke FAILED $e',
          error: e, stackTrace: s, name: '_TorrentHandler');
    }
  }

  void _fail(_Task task, String error) {
    log('_fail[task=${task.taskId}]: $error');
    task.lastStatus = DownloadStatus.failed;
    _emit(task, error: error);
    _detachFromEngine(task);
    _tasks.remove(task.taskId);
    _cancelTaskNotification(task.taskId);
    _scheduleIdleStop();
  }

  void _detachFromEngine(_Task task) {
    final tid = task.torrentId;
    if (tid == null) return;
    try {
      _engine.removeTorrent(tid, deleteFiles: false);
      log('_detachFromEngine: removeTorrent($tid) OK');
    } catch (e, s) {
      log('_detachFromEngine: removeTorrent($tid) FAILED $e',
          error: e, stackTrace: s, name: '_TorrentHandler');
    }
    _torrentToTask.remove(tid);
  }

  // ─── Notifications ───────────────────────────────────────────────────────
  //
  // We own the foreground service notification (ID 888) directly via
  // flutter_local_notifications instead of using
  // setForegroundNotificationInfo, because the latter only takes title +
  // content — no progress bar. Updating the same ID replaces the plugin's
  // initial notification while keeping the service in foreground state.
  //
  // Per-task completion notifications use separate IDs derived from the
  // taskId (masked to Int32) so they appear alongside the foreground one.

  int _notificationIdFor(int taskId) => taskId & 0x7FFFFFFF;

  Future<void> _cancelTaskNotification(int taskId) async {
    try {
      await notifications.cancel(_notificationIdFor(taskId));
    } catch (_) {}
  }

  Future<void> _showCompletionNotification(_Task task) async {
    final details = AndroidNotificationDetails(
      notificationChannelId,
      'Torrent Downloads',
      channelDescription: 'Shows progress for active torrent downloads',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: false,
      ongoing: false,
      autoCancel: true,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
    );
    try {
      await notifications.show(
        _notificationIdFor(task.taskId),
        task.movieTitle,
        'Download complete',
        NotificationDetails(android: details),
        payload: task.taskId.toString(),
      );
    } catch (e, s) {
      log('completion notification failed: $e',
          error: e, stackTrace: s, name: '_TorrentHandler');
    }
  }

  /// Re-render the foreground service notification (ID 888). Shows the
  /// active download's progress + speeds when there's exactly one; falls
  /// back to an aggregate summary when multiple are running.
  void _updateForegroundNotification() {
    if (_shuttingDown) return;

    final live = _tasks.values.where((t) {
      switch (t.lastStatus) {
        case DownloadStatus.downloading:
        case DownloadStatus.downloadingMetadata:
        case DownloadStatus.paused:
        case DownloadStatus.queued:
          return true;
        case DownloadStatus.completed:
        case DownloadStatus.failed:
        case DownloadStatus.stopped:
          return false;
      }
    }).toList();

    if (live.isEmpty) {
      _showForegroundNotification(
        title: 'YTS Movies',
        body: 'Torrent service idle',
      );
      return;
    }

    if (live.length == 1) {
      final t = live.first;
      final pct = (t.progress * 100);
      final pctText = pct.toStringAsFixed(1);
      final speedText = '${_fmtSpeed(t.downloadSpeed)} ↓ '
          '${_fmtSpeed(t.uploadSpeed)} ↑';
      final body = switch (t.lastStatus) {
        DownloadStatus.downloading => '$pctText% • $speedText',
        DownloadStatus.paused => '$pctText% • paused',
        DownloadStatus.downloadingMetadata => 'Fetching metadata…',
        DownloadStatus.queued => 'Queued',
        _ => '$pctText%',
      };
      _showForegroundNotification(
        title: t.movieTitle,
        body: body,
        progress: t.lastStatus == DownloadStatus.downloading ||
                t.lastStatus == DownloadStatus.paused
            ? pct.toInt().clamp(0, 100)
            : null,
        indeterminate: t.lastStatus == DownloadStatus.downloadingMetadata,
      );
      return;
    }

    // Multiple live tasks — show aggregate.
    var active = 0, meta = 0, paused = 0;
    var totalDl = 0, totalUl = 0;
    for (final t in live) {
      totalDl += t.downloadSpeed;
      totalUl += t.uploadSpeed;
      switch (t.lastStatus) {
        case DownloadStatus.downloading:
          active++;
          break;
        case DownloadStatus.downloadingMetadata:
        case DownloadStatus.queued:
          meta++;
          break;
        case DownloadStatus.paused:
          paused++;
          break;
        default:
          break;
      }
    }
    final parts = <String>[];
    if (active > 0) parts.add('$active downloading');
    if (meta > 0) parts.add('$meta queued');
    if (paused > 0) parts.add('$paused paused');
    _showForegroundNotification(
      title: parts.join(' • '),
      body: '${_fmtSpeed(totalDl)} ↓ ${_fmtSpeed(totalUl)} ↑',
      indeterminate: active > 0,
    );
  }

  Future<void> _showForegroundNotification({
    required String title,
    required String body,
    int? progress,
    bool indeterminate = false,
  }) async {
    final showBar = progress != null || indeterminate;
    final details = AndroidNotificationDetails(
      notificationChannelId,
      'Torrent Downloads',
      channelDescription: 'Shows progress for active torrent downloads',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: showBar,
      maxProgress: 100,
      progress: progress ?? 0,
      indeterminate: progress == null && indeterminate,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
    );
    try {
      await notifications.show(
        notificationId,
        title,
        body,
        NotificationDetails(android: details),
      );
    } catch (e, s) {
      log('foreground notification failed: $e',
          error: e, stackTrace: s, name: '_TorrentHandler');
    }
  }

  // ─── Idle stop + shutdown ────────────────────────────────────────────────

  bool _hasActiveWork() {
    for (final t in _tasks.values) {
      switch (t.lastStatus) {
        case DownloadStatus.queued:
        case DownloadStatus.downloadingMetadata:
        case DownloadStatus.downloading:
        case DownloadStatus.paused:
          return true;
        case DownloadStatus.completed:
        case DownloadStatus.failed:
        case DownloadStatus.stopped:
          break;
      }
    }
    return false;
  }

  void _cancelIdleStop() {
    _idleStopTimer?.cancel();
    _idleStopTimer = null;
  }

  void _scheduleIdleStop() {
    if (_shuttingDown) return;
    if (_hasActiveWork()) {
      _cancelIdleStop();
      return;
    }
    _idleStopTimer?.cancel();
    _idleStopTimer = Timer(_idleGrace, () {
      _idleStopTimer = null;
      if (_shuttingDown || _hasActiveWork()) return;
      log('_scheduleIdleStop: grace elapsed, shutting down service',
          name: '_TorrentHandler');
      _shuttingDown = true;
      shutdown().then((_) {
        try {
          service.stopSelf();
        } catch (e, s) {
          log('stopSelf failed: $e',
              error: e, stackTrace: s, name: '_TorrentHandler');
        }
      });
    });
  }

  Future<void> shutdown() async {
    log('shutdown: enter (alreadyDone=$_shutdownComplete)',
        name: '_TorrentHandler');
    if (_shutdownComplete) return;
    _shutdownComplete = true;
    await _torrentSub?.cancel();
    _aggregateTimer?.cancel();
    _idleStopTimer?.cancel();
    for (final tid in _torrentToTask.keys.toList()) {
      try {
        _engine.removeTorrent(tid, deleteFiles: false);
      } catch (_) {}
    }
    for (final taskId in _tasks.keys.toList()) {
      await _cancelTaskNotification(taskId);
    }
    _tasks.clear();
    _torrentToTask.clear();
    log('shutdown: done', name: '_TorrentHandler');
  }

  String _fmtSpeed(int bps) {
    if (bps < 1024) return '$bps B/s';
    if (bps < 1024 * 1024) return '${(bps / 1024).toStringAsFixed(1)} KB/s';
    if (bps < 1024 * 1024 * 1024) {
      return '${(bps / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    }
    return '${(bps / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB/s';
  }
}
