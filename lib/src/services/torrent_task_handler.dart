import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:libtorrent_flutter/libtorrent_flutter.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/torrent_service_models.dart';

const String notificationChannelId = 'torrent_downloads';
const int notificationId = 888;

/// Entry point for the background isolate. libtorrent_flutter holds a single
/// FFI session per process, so the engine lives entirely inside this isolate
/// and the main isolate talks to it via flutter_background_service IPC.
@pragma('vm:entry-point')
void onStartBackgroundService(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  if (!LibtorrentFlutter.isInitialized) {
    await LibtorrentFlutter.init(
      defaultSavePath: Directory.systemTemp.path,
      fetchTrackers: true,
      pollInterval: const Duration(milliseconds: 600),
    );
  }

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
  service.on('stopService').listen((event) async {
    await handler.cleanup();
    service.stopSelf();
  });
  log('TorrentTaskHandler: service started');
}

/// Per-task bookkeeping inside the background isolate.
class _Record {
  final int taskId;
  final String movieTitle;
  String savePath;
  StartDownloadRequest request;

  /// libtorrent torrent handle id. null until addMagnet succeeds.
  int? torrentId;

  /// File indices the user wants to keep (null = all). Applied as priorities
  /// once metadata lands.
  List<int>? selectedIndices;

  /// User-set priorities per file index.
  final Map<int, FilePriorityLevel> filePriorities = {};

  /// File list cached from the engine once metadata arrives.
  List<TorrentFileInfo>? files;

  /// Priorities pushed to engine after first hasMetadata=true.
  bool metadataApplied = false;

  /// True if the user explicitly paused this task — keeps the status mapping
  /// from flipping to "downloading" the next poll after we call pauseTorrent.
  bool pausedByUser = false;

  /// True while the magnet has been added solely to fetch metadata for the
  /// pre-download config dialog. All file priorities are forced to 0 so the
  /// engine doesn't actually download bytes; cleared on the first
  /// applyFileSelection (the "commit" from the dialog).
  bool previewMode = false;

  DownloadStatus lastStatus = DownloadStatus.queued;

  int totalBytes = 0;
  int downloadedBytes = 0;
  double progress = 0;
  int downloadSpeed = 0;
  int uploadSpeed = 0;
  int peers = 0;
  int seeders = 0;

  /// Last requested per-task limit (advisory only — engine uses session-wide
  /// limits so the most recent setSpeedLimit across any task wins).
  int? downloadSpeedLimit;
  int? uploadSpeedLimit;

  _Record({
    required this.taskId,
    required this.movieTitle,
    required this.savePath,
    required this.request,
  });
}

int _priorityToInt(FilePriorityLevel l) {
  switch (l) {
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

DownloadStatus _mapStatus(
  TorrentInfo t, {
  required bool pausedByUser,
  required bool previewMode,
}) {
  if (t.errorMsg.isNotEmpty || t.state == TorrentState.error) {
    return DownloadStatus.failed;
  }
  // Preview-only torrents have all-skip priorities, so the engine reports
  // "finished" immediately after metadata. Don't surface that to the UI —
  // commit (applyFileSelection) clears previewMode and unblocks the real
  // state transitions.
  if (previewMode) return DownloadStatus.downloadingMetadata;
  if (t.isFinished || t.state.isDone) return DownloadStatus.completed;
  if (pausedByUser || t.isPaused) return DownloadStatus.paused;
  if (t.state == TorrentState.downloadingMetadata) {
    return DownloadStatus.downloadingMetadata;
  }
  return DownloadStatus.downloading;
}

class _TorrentTaskHandler {
  final ServiceInstance service;
  final FlutterLocalNotificationsPlugin notificationsPlugin;
  final LibtorrentFlutter _engine = LibtorrentFlutter.instance;

  final Map<int, _Record> _records = {}; // taskId -> rec
  final Map<int, int> _byTorrentId = {}; // torrentId -> taskId

  StreamSubscription<Map<int, TorrentInfo>>? _torrentSub;
  Timer? _foregroundNotifTimer;
  Timer? _idleStopTimer;
  bool _stopping = false;
  bool _cleanedUp = false;

  /// Session-wide last-applied speed caps (libtorrent_flutter only supports
  /// per-session limits, so we surface the most recent ones to the UI).
  int? _globalDl;
  int? _globalUl;

  /// Grace period after the last active download finishes before the
  /// background service is allowed to stop itself.
  static const Duration _idleStopGrace = Duration(seconds: 30);

  _TorrentTaskHandler(this.service, this.notificationsPlugin) {
    _torrentSub = _engine.torrentUpdates.listen(_onTorrentUpdates);
    _foregroundNotifTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateAggregateForegroundNotification();
    });
  }

  // ─── Engine event handling ────────────────────────────────────────────────

  void _onTorrentUpdates(Map<int, TorrentInfo> snapshot) {
    for (final entry in snapshot.entries) {
      final taskId = _byTorrentId[entry.key];
      if (taskId == null) continue;
      final rec = _records[taskId];
      if (rec == null) continue;
      _applySnapshot(rec, entry.value);
    }
  }

  void _applySnapshot(_Record rec, TorrentInfo info) {
    if (!rec.metadataApplied && info.hasMetadata) {
      rec.metadataApplied = true;
      // Skip priority push in preview mode — user hasn't selected files yet.
      // Priorities will be applied via applyFileSelection (the dialog commit).
      if (!rec.previewMode) _pushPriorities(rec);
      rec.files = _readFiles(rec);
    }

    rec.progress = info.progress;
    rec.downloadSpeed = info.downloadRate;
    rec.uploadSpeed = info.uploadRate;
    rec.peers = info.numPeers;
    rec.seeders = info.numSeeds;
    rec.downloadedBytes = info.totalDone;
    if (info.totalWanted > 0) rec.totalBytes = info.totalWanted;

    final prevStatus = rec.lastStatus;
    final newStatus = _mapStatus(
      info,
      pausedByUser: rec.pausedByUser,
      previewMode: rec.previewMode,
    );
    rec.lastStatus = newStatus;

    if (newStatus == DownloadStatus.completed &&
        prevStatus != DownloadStatus.completed) {
      _markAllSelectedFilesComplete(rec);
      _showNotification(
        rec.taskId,
        rec.movieTitle,
        'Download completed!',
        progress: 100,
        maxProgress: 100,
        ongoing: false,
      );
      _scheduleIdleStop();
    } else if (newStatus == DownloadStatus.failed) {
      _scheduleIdleStop();
    } else if (newStatus == DownloadStatus.downloading) {
      _showNotification(
        rec.taskId,
        rec.movieTitle,
        '${(rec.progress * 100).toStringAsFixed(1)}% • '
        '${_fmtSpeed(rec.downloadSpeed)} ↓ ${_fmtSpeed(rec.uploadSpeed)} ↑',
        progress: (rec.progress * 100).toInt(),
        maxProgress: 100,
      );
    }

    _sendProgress(rec, errorMsg: info.errorMsg);
  }

  List<TorrentFileInfo> _readFiles(_Record rec) {
    final tid = rec.torrentId;
    if (tid == null) return const [];
    final list = _engine.getFiles(tid);
    return [
      for (final f in list)
        TorrentFileInfo(
          index: f.index,
          name: f.path.isNotEmpty ? f.path : f.name,
          size: f.size,
          downloaded: 0,
          priority: rec.filePriorities[f.index] ?? FilePriorityLevel.normal,
          completed: false,
        )
    ];
  }

  void _pushPriorities(_Record rec) {
    final tid = rec.torrentId;
    if (tid == null) return;
    final files = _engine.getFiles(tid);
    if (files.isEmpty) return;

    final selected = rec.selectedIndices?.toSet();
    final priorities = List<int>.generate(files.length, (i) {
      // Initial selection from StartDownloadRequest wins when no explicit
      // per-file priority has been set yet.
      final explicit = rec.filePriorities[i];
      if (explicit != null) return _priorityToInt(explicit);
      final level = (selected != null && !selected.contains(i))
          ? FilePriorityLevel.skip
          : FilePriorityLevel.normal;
      // Sync the cache so later per-file edits don't accidentally promote
      // skipped files back to normal.
      rec.filePriorities[i] = level;
      return _priorityToInt(level);
    });
    try {
      _engine.setFilePriorities(tid, priorities);
    } catch (e) {
      log('setFilePriorities failed: $e');
    }
  }

  void _markAllSelectedFilesComplete(_Record rec) {
    final files = rec.files;
    if (files == null) return;
    rec.files = [
      for (final f in files)
        if (f.priority == FilePriorityLevel.skip)
          f
        else
          f.copyWith(downloaded: f.size, completed: true)
    ];
  }

  // ─── IPC commands ────────────────────────────────────────────────────────

  Future<void> startDownload(StartDownloadRequest request) async {
    if (_records.containsKey(request.taskId)) {
      log('startDownload: task ${request.taskId} already known');
      return;
    }

    final rec = _Record(
      taskId: request.taskId,
      movieTitle: request.movieTitle,
      savePath: request.savePath,
      request: request,
    )
      ..selectedIndices = request.selectedIndices
      ..downloadSpeedLimit = request.initialDownloadLimit
      ..uploadSpeedLimit = request.initialUploadLimit
      ..previewMode = request.previewMode;
    _records[request.taskId] = rec;
    _cancelIdleStop();

    try {
      await Directory(rec.savePath).create(recursive: true);
    } catch (_) {}

    try {
      final torrentId = _engine.addMagnet(request.magnetUri, rec.savePath);
      rec.torrentId = torrentId;
      _byTorrentId[torrentId] = rec.taskId;

      if (request.initialDownloadLimit != null) {
        _globalDl = request.initialDownloadLimit;
        _engine.setDownloadLimit(_globalDl ?? 0);
      }
      if (request.initialUploadLimit != null) {
        _globalUl = request.initialUploadLimit;
        _engine.setUploadLimit(_globalUl ?? 0);
      }

      _showNotification(rec.taskId, 'Downloading Metadata', rec.movieTitle);
      _send(ProgressUpdate(
        taskId: rec.taskId,
        status: DownloadStatus.downloadingMetadata,
        savedFilePath: rec.savePath,
        downloadSpeedLimit: _globalDl,
        uploadSpeedLimit: _globalUl,
      ));
    } catch (e, s) {
      log('startDownload failed: $e', error: e, stackTrace: s);
      _fail(rec, e.toString());
    }
  }

  void pauseDownload(DownloadControlRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    final tid = rec.torrentId;
    if (tid != null) _engine.pauseTorrent(tid);
    rec.pausedByUser = true;
    rec.lastStatus = DownloadStatus.paused;
    _send(ProgressUpdate(taskId: rec.taskId, status: DownloadStatus.paused));
  }

  void resumeDownload(DownloadControlRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    _cancelIdleStop();
    rec.pausedByUser = false;
    final tid = rec.torrentId;
    if (tid != null) _engine.resumeTorrent(tid);
    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: DownloadStatus.downloading,
    ));
  }

  Future<void> stopDownload(DownloadControlRequest request) async {
    final rec = _records[request.taskId];
    if (rec == null) return;
    final tid = rec.torrentId;
    if (tid != null) {
      try {
        _engine.removeTorrent(tid, deleteFiles: false);
      } catch (e) {
        log('removeTorrent failed: $e');
      }
      _byTorrentId.remove(tid);
    }
    _records.remove(rec.taskId);
    _cancelTaskNotification(rec.taskId);
    _send(ProgressUpdate(taskId: rec.taskId, status: DownloadStatus.stopped));
    _scheduleIdleStop();
  }

  void setSpeedLimit(SetSpeedLimitRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    rec.downloadSpeedLimit = request.downloadLimit;
    rec.uploadSpeedLimit = request.uploadLimit;
    // libtorrent_flutter has no per-task speed limits; treat the request as a
    // session-wide cap. Last writer across tasks wins.
    _globalDl = request.downloadLimit;
    _globalUl = request.uploadLimit;
    _engine.setDownloadLimit(_globalDl ?? 0);
    _engine.setUploadLimit(_globalUl ?? 0);
    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: rec.lastStatus,
      downloadSpeedLimit: _globalDl,
      uploadSpeedLimit: _globalUl,
    ));
  }

  void setFilePriority(SetFilePriorityRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    rec.filePriorities[request.fileIndex] = request.priority;
    _pushAllPriorities(rec);
    final files = rec.files;
    if (files != null) {
      rec.files = [
        for (final f in files)
          f.index == request.fileIndex
              ? f.copyWith(priority: request.priority)
              : f
      ];
    }
    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: rec.lastStatus,
      files: rec.files,
    ));
  }

  void applyFileSelection(ApplyFileSelectionRequest request) {
    final rec = _records[request.taskId];
    if (rec == null) return;
    // First commit out of preview mode — engine starts downloading the
    // selected files once priorities go non-zero.
    rec.previewMode = false;
    final selected = request.selectedIndices.toSet();
    final tid = rec.torrentId;
    final fileCount = tid == null ? 0 : _engine.getFiles(tid).length;
    for (var i = 0; i < fileCount; i++) {
      rec.filePriorities[i] = selected.contains(i)
          ? FilePriorityLevel.normal
          : FilePriorityLevel.skip;
    }
    rec.selectedIndices = request.selectedIndices;
    _pushAllPriorities(rec);
    final files = rec.files;
    if (files != null) {
      rec.files = [
        for (final f in files)
          f.copyWith(
            priority: rec.filePriorities[f.index] ?? FilePriorityLevel.normal,
          )
      ];
    }
    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: rec.lastStatus,
      files: rec.files,
    ));
  }

  void _pushAllPriorities(_Record rec) {
    final tid = rec.torrentId;
    if (tid == null || !rec.metadataApplied) return;
    final files = _engine.getFiles(tid);
    if (files.isEmpty) return;
    final priorities = List<int>.generate(files.length, (i) {
      return _priorityToInt(rec.filePriorities[i] ?? FilePriorityLevel.normal);
    });
    try {
      _engine.setFilePriorities(tid, priorities);
    } catch (e) {
      log('setFilePriorities failed: $e');
    }
  }

  // ─── helpers ─────────────────────────────────────────────────────────────

  void _fail(_Record rec, String error) {
    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: DownloadStatus.failed,
      error: error,
    ));
    final tid = rec.torrentId;
    if (tid != null) {
      try {
        _engine.removeTorrent(tid, deleteFiles: false);
      } catch (_) {}
      _byTorrentId.remove(tid);
    }
    _records.remove(rec.taskId);
    _cancelTaskNotification(rec.taskId);
    _scheduleIdleStop();
  }

  Future<void> _cancelTaskNotification(int id) async {
    try {
      await notificationsPlugin.cancel(id);
    } catch (_) {}
  }

  void _sendProgress(_Record rec, {String? errorMsg}) {
    _send(ProgressUpdate(
      taskId: rec.taskId,
      status: rec.lastStatus,
      progress: rec.progress,
      downloadSpeed: rec.downloadSpeed,
      uploadSpeed: rec.uploadSpeed,
      peers: rec.peers,
      seeders: rec.seeders,
      downloadedBytes: rec.downloadedBytes,
      totalBytes: rec.totalBytes,
      files: rec.files,
      savedFilePath: rec.savePath,
      downloadSpeedLimit: _globalDl,
      uploadSpeedLimit: _globalUl,
      error: errorMsg == null || errorMsg.isEmpty ? null : errorMsg,
    ));
  }

  void _send(ProgressUpdate update) {
    service.invoke('progressUpdate', update.toJson());
  }

  void _setForegroundNotification(String title, String content) {
    try {
      if (service is AndroidServiceInstance) {
        (service as AndroidServiceInstance).setForegroundNotificationInfo(
          title: title,
          content: content,
        );
      }
    } catch (_) {}
  }

  void _updateAggregateForegroundNotification() {
    if (_stopping) return;
    if (_records.isEmpty) {
      _setForegroundNotification('YTS Movies', 'Torrent service running');
      return;
    }
    var active = 0, meta = 0, paused = 0, completed = 0;
    var totalDl = 0, totalUl = 0;
    for (final rec in _records.values) {
      totalDl += rec.downloadSpeed;
      totalUl += rec.uploadSpeed;
      switch (rec.lastStatus) {
        case DownloadStatus.downloading:
          active++;
          break;
        case DownloadStatus.paused:
          paused++;
          break;
        case DownloadStatus.downloadingMetadata:
        case DownloadStatus.queued:
          meta++;
          break;
        case DownloadStatus.completed:
          completed++;
          break;
        case DownloadStatus.failed:
        case DownloadStatus.stopped:
          break;
      }
    }
    final parts = <String>[];
    if (active > 0) parts.add('$active downloading');
    if (meta > 0) parts.add('$meta queued');
    if (paused > 0) parts.add('$paused paused');
    if (completed > 0) parts.add('$completed done');
    final title = parts.isEmpty ? 'YTS Movies' : parts.join(' • ');
    final body = active > 0 || paused > 0
        ? '${_fmtSpeed(totalDl)} ↓ ${_fmtSpeed(totalUl)} ↑'
        : 'Torrent service running';
    _setForegroundNotification(title, body);
  }

  bool _hasActiveWork() {
    return _records.values.any((rec) {
      switch (rec.lastStatus) {
        case DownloadStatus.queued:
        case DownloadStatus.downloadingMetadata:
        case DownloadStatus.downloading:
        case DownloadStatus.paused:
          return true;
        case DownloadStatus.completed:
        case DownloadStatus.failed:
        case DownloadStatus.stopped:
          return false;
      }
    });
  }

  void _cancelIdleStop() {
    _idleStopTimer?.cancel();
    _idleStopTimer = null;
  }

  void _scheduleIdleStop() {
    if (_stopping) return;
    if (_hasActiveWork()) {
      _cancelIdleStop();
      return;
    }
    _idleStopTimer?.cancel();
    _idleStopTimer = Timer(_idleStopGrace, () {
      _idleStopTimer = null;
      if (_stopping || _hasActiveWork()) return;
      _stopping = true;
      cleanup().then((_) {
        try {
          service.stopSelf();
        } catch (e) {
          log('service.stopSelf failed: $e');
        }
      });
    });
  }

  Future<void> _showNotification(
    int id,
    String title,
    String body, {
    int? progress,
    int? maxProgress,
    bool ongoing = true,
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
      ongoing: ongoing,
      autoCancel: !ongoing,
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

  Future<void> cleanup() async {
    if (_cleanedUp) return;
    _cleanedUp = true;
    await _torrentSub?.cancel();
    _foregroundNotifTimer?.cancel();
    _idleStopTimer?.cancel();
    // Detach known torrents from the engine without deleting on-disk files.
    for (final tid in _byTorrentId.keys.toList()) {
      try {
        _engine.removeTorrent(tid, deleteFiles: false);
      } catch (_) {}
    }
    for (final taskId in _records.keys.toList()) {
      await _cancelTaskNotification(taskId);
    }
    _records.clear();
    _byTorrentId.clear();
  }
}
