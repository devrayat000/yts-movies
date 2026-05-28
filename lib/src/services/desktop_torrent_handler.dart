import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:libtorrent_flutter/libtorrent_flutter.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/torrent_service_models.dart';

const _logTag = 'DesktopTorrent';

// Shared progress-toast id. Reusing it lets flutter_local_notifications
// update the existing notification in place rather than spawning a new one
// per snapshot.
const int _foregroundNotificationId = 888;
int _completionIdFor(int taskId) => taskId & 0x7FFFFFFF;

/// In-process libtorrent driver for desktop platforms (Windows / Linux /
/// macOS). Mirrors the behaviour of the background-isolate handler used on
/// Android/iOS but emits progress via a plain callback instead of going
/// through flutter_background_service IPC (which doesn't run on desktop).
class DesktopTorrentHandler {
  DesktopTorrentHandler({required this.onProgress});

  final void Function(ProgressUpdate update) onProgress;

  late final LibtorrentFlutter _engine;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<Map<int, TorrentInfo>>? _torrentSub;
  bool _initialized = false;

  final Map<int, _Task> _tasks = {};
  final Map<int, int> _torrentToTask = {};

  int? _sessionDl;
  int? _sessionUl;

  Future<void> initialize({required String defaultSavePath}) async {
    if (_initialized) return;
    if (!LibtorrentFlutter.isInitialized) {
      log('initialize: LibtorrentFlutter.init starting (savePath=$defaultSavePath)',
          name: _logTag);
      try {
        await LibtorrentFlutter.init(
          defaultSavePath: defaultSavePath,
          fetchTrackers: false,
          pollInterval: const Duration(milliseconds: 750),
        );
      } catch (e, s) {
        log('LibtorrentFlutter.init FAILED: $e',
            error: e, stackTrace: s, name: _logTag);
        rethrow;
      }
    }
    _engine = LibtorrentFlutter.instance;
    _torrentSub = _engine.torrentUpdates.listen(
      _onSnapshot,
      onError: (Object e, StackTrace s) => log(
          'torrentUpdates stream error: $e',
          error: e,
          stackTrace: s,
          name: _logTag),
    );
    // Intentionally no periodic notification refresh. Windows toasts re-pop
    // on every Show() call (the plugin doesn't expose ToastNotifier.Update),
    // so live progress via timed re-show floods the Action Center. Toasts
    // fire only on status transitions; live numbers live in the tray tooltip
    // and the in-app downloads UI.
    _initialized = true;
    log('initialize: ready', name: _logTag);
  }

  Future<void> dispose() async {
    await _torrentSub?.cancel();
    try {
      await _notifications.cancel(id: _foregroundNotificationId);
    } catch (_) {}
    for (final tid in _torrentToTask.keys.toList()) {
      try {
        _engine.removeTorrent(tid, deleteFiles: false);
      } catch (_) {}
    }
    _tasks.clear();
    _torrentToTask.clear();
    _initialized = false;
  }

  // ─── Commands ──────────────────────────────────────────────────────────

  Future<void> startDownload(StartDownloadRequest req) async {
    log('startDownload: $req', name: _logTag);
    if (_tasks.containsKey(req.taskId)) {
      log('startDownload: ${req.taskId} already running, skipping',
          name: _logTag);
      return;
    }
    final task = _Task(
      taskId: req.taskId,
      movieTitle: req.movieTitle,
      savePath: req.savePath,
      selectedIndices: req.selectedIndices,
      previewMode: req.previewMode,
    );
    _tasks[req.taskId] = task;

    try {
      await Directory(task.savePath).create(recursive: true);
    } catch (e, s) {
      log('savePath create failed (${task.savePath}): $e',
          error: e, stackTrace: s, name: _logTag);
    }

    if (req.initialDownloadLimit != null) {
      _sessionDl = req.initialDownloadLimit;
      _engine.setDownloadLimit(_sessionDl ?? 0);
    }
    if (req.initialUploadLimit != null) {
      _sessionUl = req.initialUploadLimit;
      _engine.setUploadLimit(_sessionUl ?? 0);
    }

    try {
      final torrentId = _engine.addMagnet(req.magnetUri, task.savePath);
      task.torrentId = torrentId;
      _torrentToTask[torrentId] = task.taskId;
      log('addMagnet OK torrentId=$torrentId for task=${task.taskId}',
          name: _logTag);
    } catch (e, s) {
      log('addMagnet FAILED: $e', error: e, stackTrace: s, name: _logTag);
      _fail(task, e.toString());
      return;
    }

    task.lastStatus = DownloadStatus.downloadingMetadata;
    _emit(task);
  }

  void pauseDownload(DownloadControlRequest req) {
    final task = _tasks[req.taskId];
    if (task == null) return;
    final tid = task.torrentId;
    if (tid != null) _engine.pauseTorrent(tid);
    task.pausedByUser = true;
    task.lastStatus = DownloadStatus.paused;
    _emit(task);
  }

  void resumeDownload(DownloadControlRequest req) {
    final task = _tasks[req.taskId];
    if (task == null) return;
    task.pausedByUser = false;
    final tid = task.torrentId;
    if (tid != null) _engine.resumeTorrent(tid);
    task.lastStatus = task.previewMode || task.totalWanted == 0
        ? DownloadStatus.downloadingMetadata
        : DownloadStatus.downloading;
    _emit(task);
  }

  void stopDownload(DownloadControlRequest req) {
    final task = _tasks[req.taskId];
    if (task == null) return;
    _detach(task);
    _tasks.remove(task.taskId);
    task.lastStatus = DownloadStatus.stopped;
    _emit(task);
  }

  void deleteDownload(DownloadControlRequest req) {
    final task = _tasks[req.taskId];
    if (task == null) return;
    final tid = task.torrentId;
    if (tid != null) {
      try {
        _engine.removeTorrent(tid, deleteFiles: true);
      } catch (e, s) {
        log('removeTorrent failed: $e', error: e, stackTrace: s, name: _logTag);
      }
      _torrentToTask.remove(tid);
    }
    _tasks.remove(task.taskId);
    task.lastStatus = DownloadStatus.stopped;
    _emit(task);
  }

  void setSpeedLimit(SetSpeedLimitRequest req) {
    final task = _tasks[req.taskId];
    if (task == null) return;
    _sessionDl = req.downloadLimit;
    _sessionUl = req.uploadLimit;
    _engine.setDownloadLimit(_sessionDl ?? 0);
    _engine.setUploadLimit(_sessionUl ?? 0);
    _emit(task);
  }

  void setFilePriority(SetFilePriorityRequest req) {
    final task = _tasks[req.taskId];
    if (task == null) return;
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
    final task = _tasks[req.taskId];
    if (task == null) return;
    task.previewMode = false;
    task.selectedIndices = List<int>.from(req.selectedIndices);
    final selected = req.selectedIndices.toSet();
    final tid = task.torrentId;
    final fileCount = tid == null ? 0 : _engine.getFiles(tid).length;
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

  // ─── Snapshot pipeline ─────────────────────────────────────────────────

  int _snapshotCounter = 0;
  void _onSnapshot(Map<int, TorrentInfo> snapshot) {
    _snapshotCounter++;
    if (_snapshotCounter <= 5 || _snapshotCounter % 20 == 0) {
      log(
          'snapshot #$_snapshotCounter: ${snapshot.length} torrents, '
          'map=$_torrentToTask',
          name: _logTag);
    }
    for (final entry in snapshot.entries) {
      final info = entry.value;
      final taskId = _torrentToTask[entry.key];
      if (taskId == null) continue;
      final task = _tasks[taskId];
      if (task == null) {
        _torrentToTask.remove(entry.key);
        continue;
      }
      if (_snapshotCounter <= 5 || _snapshotCounter % 20 == 0) {
        log(
            'tid=${entry.key} state=${info.state} hasMeta=${info.hasMetadata} '
            'peers=${info.numPeers} seeds=${info.numSeeds} '
            'dl=${info.downloadRate} err="${info.errorMsg}"',
            name: _logTag);
      }
      _applySnapshot(task, info);
    }
  }

  void _applySnapshot(_Task task, TorrentInfo info) {
    if (!task.prioritiesPushed && info.hasMetadata) {
      task.files = _readFiles(task);
      _pushPriorities(task);
    }

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
    task.lastStatus = _statusFor(task, info);

    if (task.lastStatus == DownloadStatus.completed &&
        !task.completionEmitted) {
      task.completionEmitted = true;
      _markFilesComplete(task);
      _showCompletionNotification(task);
    } else if (task.lastStatus != prevStatus) {
      // Status transition (queued → metadata → downloading → paused, etc.).
      // Fire a single foreground toast; live numbers belong in the tray
      // tooltip + in-app UI, not in re-popping toasts.
      _updateForegroundNotification();
    }

    _emit(task, error: info.errorMsg.isEmpty ? null : info.errorMsg);
  }

  // ─── Windows toast notifications ───────────────────────────────────────

  Future<void> _showCompletionNotification(_Task task) async {
    try {
      await _notifications.show(
        id: _completionIdFor(task.taskId),
        title: task.movieTitle,
        body: 'Download complete',
        notificationDetails: NotificationDetails(
          windows: WindowsNotificationDetails(
            actions: [
              WindowsAction(
                content: 'Open folder',
                arguments: 'openFolder:${task.taskId}',
              ),
            ],
          ),
        ),
        payload: task.taskId.toString(),
      );
    } catch (e, s) {
      log('completion notification failed: $e',
          error: e, stackTrace: s, name: _logTag);
    }
  }

  /// Re-render the shared progress toast. Same id is reused across snapshots
  /// so flutter_local_notifications updates the existing toast in place.
  Future<void> _updateForegroundNotification() async {
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
      await _notifications.cancel(id: _foregroundNotificationId);
      return;
    }

    String title;
    String body;
    double? progressValue;
    String statusLine;

    if (live.length == 1) {
      final t = live.first;
      final pct = t.progress * 100;
      title = t.movieTitle;
      switch (t.lastStatus) {
        case DownloadStatus.downloading:
          body = '${pct.toStringAsFixed(1)}% · ${_fmtSpeed(t.downloadSpeed)} ↓';
          progressValue = t.progress.clamp(0.0, 1.0);
          statusLine = 'Downloading';
          break;
        case DownloadStatus.paused:
          body = '${pct.toStringAsFixed(1)}% · paused';
          progressValue = t.progress.clamp(0.0, 1.0);
          statusLine = 'Paused';
          break;
        case DownloadStatus.downloadingMetadata:
          body = 'Fetching metadata…';
          progressValue = null;
          statusLine = 'Fetching metadata';
          break;
        case DownloadStatus.queued:
          body = 'Queued';
          progressValue = null;
          statusLine = 'Queued';
          break;
        default:
          body = '${pct.toStringAsFixed(1)}%';
          progressValue = t.progress.clamp(0.0, 1.0);
          statusLine = 'Downloading';
      }
    } else {
      var totalDl = 0;
      var active = 0, meta = 0, paused = 0;
      for (final t in live) {
        totalDl += t.downloadSpeed;
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
      title = parts.join(' · ');
      body = '${_fmtSpeed(totalDl)} ↓';
      progressValue = null;
      statusLine = active > 0 ? 'Downloading' : 'In progress';
    }

    try {
      await _notifications.show(
        id: _foregroundNotificationId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          windows: WindowsNotificationDetails(
            progressBars: [
              WindowsProgressBar(
                id: 'progress',
                status: statusLine,
                value: progressValue,
              ),
            ],
          ),
        ),
      );
    } catch (e, s) {
      log('foreground notification failed: $e',
          error: e, stackTrace: s, name: _logTag);
    }
  }

  String _fmtSpeed(int bps) {
    if (bps < 1024) return '$bps B/s';
    if (bps < 1024 * 1024) return '${(bps / 1024).toStringAsFixed(1)} KB/s';
    if (bps < 1024 * 1024 * 1024) {
      return '${(bps / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    }
    return '${(bps / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB/s';
  }

  DownloadStatus _statusFor(_Task task, TorrentInfo info) {
    if (info.errorMsg.isNotEmpty || info.state == TorrentState.error) {
      return DownloadStatus.failed;
    }
    if (task.previewMode) return DownloadStatus.downloadingMetadata;
    if (task.pausedByUser || info.isPaused) return DownloadStatus.paused;
    if (!info.hasMetadata || info.state == TorrentState.downloadingMetadata) {
      return DownloadStatus.downloadingMetadata;
    }
    if (task.completionEmitted &&
        info.totalWanted > 0 &&
        info.totalDone < info.totalWanted &&
        info.progress < 0.999) {
      task.completionEmitted = false;
    }
    if (task.completionEmitted) return DownloadStatus.completed;
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
    if (tid == null) return const [];
    final raw = _engine.getFiles(tid);
    return [
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
  }

  void _pushPriorities(_Task task) {
    final tid = task.torrentId;
    if (tid == null) return;
    final files = _engine.getFiles(tid);
    if (files.isEmpty) return;

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
    try {
      _engine.setFilePriorities(tid, vector);
      task.prioritiesPushed = true;
    } catch (e, s) {
      log('setFilePriorities failed: $e',
          error: e, stackTrace: s, name: _logTag);
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

  void _detach(_Task task) {
    final tid = task.torrentId;
    if (tid == null) return;
    try {
      _engine.removeTorrent(tid, deleteFiles: false);
    } catch (e, s) {
      log('detach removeTorrent failed: $e',
          error: e, stackTrace: s, name: _logTag);
    }
    _torrentToTask.remove(tid);
  }

  void _fail(_Task task, String error) {
    task.lastStatus = DownloadStatus.failed;
    _emit(task, error: error);
    _detach(task);
    _tasks.remove(task.taskId);
  }

  void _emit(_Task task, {String? error}) {
    onProgress(ProgressUpdate(
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
    ));
  }
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
}
