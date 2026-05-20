import 'dart:async';
import 'dart:developer' as dev;
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

const String _logTag = 'TT';

/// Tee every debug line to debugPrint (stdout / `adb logcat`) AND
/// dart:developer.log (DevTools). The background isolate is the dark
/// continent of Flutter logging — be loud.
void _d(String msg, {Object? error, StackTrace? stack}) {
  // ignore: avoid_print
  debugPrint('[$_logTag] $msg');
  dev.log(msg, name: _logTag, error: error, stackTrace: stack);
}

/// Background-isolate entry point. libtorrent_flutter holds a single FFI
/// session per process, so the engine lives entirely inside this isolate
/// and the main isolate talks to it via flutter_background_service IPC.
@pragma('vm:entry-point')
void onStartBackgroundService(ServiceInstance service) async {
  _d('onStartBackgroundService: enter (pid=$pid)');
  DartPluginRegistrant.ensureInitialized();
  _d('onStartBackgroundService: DartPluginRegistrant ready');
  final notifications = FlutterLocalNotificationsPlugin();

  if (!LibtorrentFlutter.isInitialized) {
    _d('LibtorrentFlutter.init starting (defaultSavePath=${Directory.systemTemp.path})');
    try {
      await LibtorrentFlutter.init(
        defaultSavePath: Directory.systemTemp.path,
        fetchTrackers: false,
        pollInterval: const Duration(milliseconds: 750),
      );
      _d('LibtorrentFlutter.init OK (version=${LibtorrentFlutter.instance.libraryVersion})');
    } catch (e, s) {
      _d('LibtorrentFlutter.init FAILED: $e', error: e, stack: s);
      rethrow;
    }
  } else {
    _d('LibtorrentFlutter already initialized');
  }

  final handler = _TorrentHandler(service, notifications);
  _d('_TorrentHandler constructed');

  service.on('startDownload').listen((event) {
    _d('IPC<- startDownload: $event');
    if (event == null) {
      _d('IPC<- startDownload: null payload, ignoring');
      return;
    }
    try {
      handler.startDownload(StartDownloadRequest.fromJson(event));
    } catch (e, s) {
      _d('IPC<- startDownload parse error: $e', error: e, stack: s);
    }
  });
  service.on('pauseDownload').listen((event) {
    _d('IPC<- pauseDownload: $event');
    if (event != null) {
      handler.pauseDownload(DownloadControlRequest.fromJson(event));
    }
  });
  service.on('resumeDownload').listen((event) {
    _d('IPC<- resumeDownload: $event');
    if (event != null) {
      handler.resumeDownload(DownloadControlRequest.fromJson(event));
    }
  });
  service.on('stopDownload').listen((event) {
    _d('IPC<- stopDownload: $event');
    if (event != null) {
      handler.stopDownload(DownloadControlRequest.fromJson(event));
    }
  });
  service.on('setSpeedLimit').listen((event) {
    _d('IPC<- setSpeedLimit: $event');
    if (event != null) {
      handler.setSpeedLimit(SetSpeedLimitRequest.fromJson(event));
    }
  });
  service.on('setFilePriority').listen((event) {
    _d('IPC<- setFilePriority: $event');
    if (event != null) {
      handler.setFilePriority(SetFilePriorityRequest.fromJson(event));
    }
  });
  service.on('applyFileSelection').listen((event) {
    _d('IPC<- applyFileSelection: $event');
    if (event != null) {
      handler.applyFileSelection(ApplyFileSelectionRequest.fromJson(event));
    }
  });
  service.on('deleteDownload').listen((event) {
    _d('IPC<- deleteDownload: $event');
    if (event != null) {
      handler.deleteDownload(DownloadControlRequest.fromJson(event));
    }
  });
  service.on('stopService').listen((event) async {
    _d('IPC<- stopService');
    await handler.shutdown();
    service.stopSelf();
  });

  _d('onStartBackgroundService: ready, listening on IPC');
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
    _d('_TorrentHandler: subscribing to torrentUpdates');
    _torrentSub = _engine.torrentUpdates.listen(
      _onSnapshot,
      onError: (Object e, StackTrace s) =>
          _d('torrentUpdates stream error: $e', error: e, stack: s),
      onDone: () => _d('torrentUpdates stream closed'),
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
    _d('startDownload: req=$req');
    if (_tasks.containsKey(req.taskId)) {
      _d('startDownload: ${req.taskId} already running, skipping');
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
    _d('startDownload: task registered $task');

    try {
      await Directory(task.savePath).create(recursive: true);
      _d('startDownload: savePath ready (${task.savePath})');
    } catch (e, s) {
      _d('startDownload: save dir create failed (${task.savePath}): $e',
          error: e, stack: s);
    }

    if (req.initialDownloadLimit != null) {
      _sessionDl = req.initialDownloadLimit;
      _engine.setDownloadLimit(_sessionDl ?? 0);
      _d('startDownload: session DL limit set to $_sessionDl');
    }
    if (req.initialUploadLimit != null) {
      _sessionUl = req.initialUploadLimit;
      _engine.setUploadLimit(_sessionUl ?? 0);
      _d('startDownload: session UL limit set to $_sessionUl');
    }

    try {
      _d('startDownload: calling addMagnet (savePath=${task.savePath})');
      final torrentId = _engine.addMagnet(req.magnetUri, task.savePath);
      task.torrentId = torrentId;
      _torrentToTask[torrentId] = task.taskId;
      _d('startDownload: addMagnet OK torrentId=$torrentId for task=${task.taskId}');
    } catch (e, s) {
      _d('startDownload: addMagnet FAILED: $e', error: e, stack: s);
      _fail(task, e.toString());
      return;
    }

    task.lastStatus = DownloadStatus.downloadingMetadata;
    _updateForegroundNotification();
    _emit(task);
  }

  void pauseDownload(DownloadControlRequest req) {
    _d('pauseDownload: taskId=${req.taskId}');
    final task = _tasks[req.taskId];
    if (task == null) {
      _d('pauseDownload: no task for ${req.taskId}, ignoring');
      return;
    }
    final tid = task.torrentId;
    if (tid != null) {
      _engine.pauseTorrent(tid);
      _d('pauseDownload: engine.pauseTorrent($tid) called');
    } else {
      _d('pauseDownload: task has no torrentId yet');
    }
    task.pausedByUser = true;
    task.lastStatus = DownloadStatus.paused;
    _emit(task);
  }

  void resumeDownload(DownloadControlRequest req) {
    _d('resumeDownload: taskId=${req.taskId}');
    final task = _tasks[req.taskId];
    if (task == null) {
      _d('resumeDownload: no task for ${req.taskId}, ignoring');
      return;
    }
    _cancelIdleStop();
    task.pausedByUser = false;
    final tid = task.torrentId;
    if (tid != null) {
      _engine.resumeTorrent(tid);
      _d('resumeDownload: engine.resumeTorrent($tid) called');
    }
    task.lastStatus = task.previewMode || task.totalWanted == 0
        ? DownloadStatus.downloadingMetadata
        : DownloadStatus.downloading;
    _d('resumeDownload: optimistic status -> ${task.lastStatus}');
    _emit(task);
  }

  void stopDownload(DownloadControlRequest req) {
    _d('stopDownload: taskId=${req.taskId}');
    final task = _tasks[req.taskId];
    if (task == null) {
      _d('stopDownload: no task for ${req.taskId}, ignoring');
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
    _d('deleteDownload: taskId=${req.taskId}');
    final task = _tasks[req.taskId];
    if (task == null) {
      _d('deleteDownload: no task in engine for ${req.taskId} '
          '(probably rehydrated/stopped) — main isolate will sweep disk');
      return;
    }
    final tid = task.torrentId;
    if (tid != null) {
      try {
        _engine.removeTorrent(tid, deleteFiles: true);
        _d('deleteDownload: removeTorrent(tid=$tid, deleteFiles=true) OK');
      } catch (e, s) {
        _d('deleteDownload: removeTorrent failed: $e', error: e, stack: s);
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
    _d('setSpeedLimit: dl=${req.downloadLimit}, ul=${req.uploadLimit}');
    final task = _tasks[req.taskId];
    if (task == null) {
      _d('setSpeedLimit: no task for ${req.taskId}, ignoring');
      return;
    }
    _sessionDl = req.downloadLimit;
    _sessionUl = req.uploadLimit;
    _engine.setDownloadLimit(_sessionDl ?? 0);
    _engine.setUploadLimit(_sessionUl ?? 0);
    _d('setSpeedLimit: applied session-wide dl=$_sessionDl, ul=$_sessionUl');
    _emit(task);
  }

  void setFilePriority(SetFilePriorityRequest req) {
    _d('setFilePriority: taskId=${req.taskId}, file=${req.fileIndex}, '
        'prio=${req.priority}');
    final task = _tasks[req.taskId];
    if (task == null) {
      _d('setFilePriority: no task, ignoring');
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
    _d('applyFileSelection: taskId=${req.taskId}, '
        'selected=${req.selectedIndices}');
    final task = _tasks[req.taskId];
    if (task == null) {
      _d('applyFileSelection: no task, ignoring');
      return;
    }
    final wasPreview = task.previewMode;
    task.previewMode = false;
    task.selectedIndices = List<int>.from(req.selectedIndices);
    final selected = req.selectedIndices.toSet();
    final tid = task.torrentId;
    final fileCount = tid == null ? 0 : _engine.getFiles(tid).length;
    _d('applyFileSelection: wasPreview=$wasPreview, fileCount=$fileCount');
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
      _d('_onSnapshot #$_snapshotCounter: '
          '${snapshot.length} torrents, map=$_torrentToTask');
    }
    for (final entry in snapshot.entries) {
      final taskId = _torrentToTask[entry.key];
      if (taskId == null) {
        if (verbose) {
          _d('_onSnapshot: unknown torrentId=${entry.key}, skipping');
        }
        continue;
      }
      final task = _tasks[taskId];
      if (task == null) {
        _d('_onSnapshot: stale taskId=$taskId for torrentId=${entry.key}, '
            'cleaning up');
        _torrentToTask.remove(entry.key);
        continue;
      }
      _applySnapshot(task, entry.value, verbose: verbose);
    }
  }

  void _applySnapshot(_Task task, TorrentInfo info, {required bool verbose}) {
    if (verbose) {
      _d('_applySnapshot[task=${task.taskId}]: ${_infoStr(info)}');
    }
    if (!task.prioritiesPushed && info.hasMetadata) {
      _d('_applySnapshot: first metadata for task=${task.taskId}, '
          'reading files + pushing priorities');
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
      _d('_applySnapshot[task=${task.taskId}]: status $prevStatus -> '
          '$newStatus (totalWanted=${info.totalWanted}, '
          'totalDone=${info.totalDone}, isFinished=${info.isFinished}, '
          'state=${info.state}, hasMetadata=${info.hasMetadata}, '
          'previewMode=${task.previewMode})');
    }

    if (newStatus == DownloadStatus.completed && !task.completionEmitted) {
      _d('_applySnapshot[task=${task.taskId}]: ** COMPLETION LATCH SET ** '
          'totalDone=${info.totalDone}, totalWanted=${info.totalWanted}, '
          'isFinished=${info.isFinished}, '
          'progress=${(info.progress * 100).toStringAsFixed(2)}%, '
          'state=${info.state}');
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
      _d('_applySnapshot[task=${task.taskId}]: FAILED, errorMsg="${info.errorMsg}"');
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
      _d('_statusFor[task=${task.taskId}]: clearing stale completion latch '
          '(done=${info.totalDone}/${info.totalWanted}, '
          'progress=${(info.progress * 100).toStringAsFixed(1)}%)');
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
      _d('_readFiles: no torrentId for task=${task.taskId}');
      return const [];
    }
    final raw = _engine.getFiles(tid);
    _d('_readFiles[task=${task.taskId}]: engine returned ${raw.length} files');
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
      _d('  file[${f.index}]: name="${f.name}", size=${f.size}, prio=${f.priority}');
    }
    return out;
  }

  /// Compute the priority vector and ship it to libtorrent. Safe to call any
  /// time after metadata is available; no-op otherwise.
  void _pushPriorities(_Task task) {
    final tid = task.torrentId;
    if (tid == null) {
      _d('_pushPriorities: no torrentId for task=${task.taskId}, skip');
      return;
    }
    final files = _engine.getFiles(tid);
    if (files.isEmpty) {
      _d('_pushPriorities[task=${task.taskId}]: no files yet (metadata pending), skip');
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
    _d('_pushPriorities[task=${task.taskId}]: vector=$vector '
        '(previewMode=${task.previewMode}, selected=$selected)');
    try {
      _engine.setFilePriorities(tid, vector);
      task.prioritiesPushed = true;
      _d('_pushPriorities[task=${task.taskId}]: engine ack');
    } catch (e, s) {
      _d('_pushPriorities[task=${task.taskId}]: FAILED $e', error: e, stack: s);
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
      _d('IPC-> progressUpdate #$_emitCounter: '
          'task=${task.taskId}, status=${task.lastStatus}, '
          'progress=${(task.progress * 100).toStringAsFixed(1)}%, '
          'dl=${task.downloadSpeed}, ul=${task.uploadSpeed}, '
          'done=${task.totalDone}/${task.totalWanted}, error=$error');
    }
    try {
      service.invoke('progressUpdate', update.toJson());
    } catch (e, s) {
      _d('_emit: service.invoke FAILED $e', error: e, stack: s);
    }
  }

  void _fail(_Task task, String error) {
    _d('_fail[task=${task.taskId}]: $error');
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
      _d('_detachFromEngine: removeTorrent($tid) OK');
    } catch (e, s) {
      _d('_detachFromEngine: removeTorrent($tid) FAILED $e', error: e, stack: s);
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
      _d('completion notification failed: $e', error: e, stack: s);
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
      _d('foreground notification failed: $e', error: e, stack: s);
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
      _d('_scheduleIdleStop: grace elapsed, shutting down service');
      _shuttingDown = true;
      shutdown().then((_) {
        try {
          service.stopSelf();
        } catch (e, s) {
          _d('stopSelf failed: $e', error: e, stack: s);
        }
      });
    });
  }

  Future<void> shutdown() async {
    _d('shutdown: enter (alreadyDone=$_shutdownComplete)');
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
    _d('shutdown: done');
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
