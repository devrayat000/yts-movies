import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/torrent_service_models.dart';
import 'package:ytsmovies/src/services/foreground_download_service.dart';

part 'download_manager_event.dart';
part 'download_manager_state.dart';

const String _logTag = 'DMB';

void _d(String msg, {Object? error, StackTrace? stackTrace}) {
  // ignore: avoid_print
  debugPrint('[$_logTag] $msg');
  log(msg, name: _logTag, error: error, stackTrace: stackTrace);
}

/// BLoC for managing downloads
@singleton
class DownloadManagerBloc
    extends HydratedBloc<DownloadManagerEvent, DownloadManagerState> {
  final ForegroundDownloadService _foregroundDownloadService;
  StreamSubscription<ProgressUpdate>? _progressSubscription;

  DownloadManagerBloc(this._foregroundDownloadService)
      : super(const DownloadManagerState()) {
    on<DownloadManagerStarted>(_onStarted);
    on<DownloadManagerAddDownload>(_onAddDownload);
    on<DownloadManagerPauseDownload>(_onPauseDownload);
    on<DownloadManagerResumeDownload>(_onResumeDownload);
    on<DownloadManagerStopDownload>(_onStopDownload);
    on<DownloadManagerDeleteDownload>(_onDeleteDownload);
    on<DownloadManagerUpdateProgress>(_onUpdateProgress);
    on<DownloadManagerClearCompleted>(_onClearCompleted);
    on<DownloadManagerSetSpeedLimit>(_onSetSpeedLimit);
    on<DownloadManagerSetFilePriority>(_onSetFilePriority);
    on<DownloadManagerApplyFileSelection>(_onApplyFileSelection);
    on<DownloadManagerMoveDownloadTask>(_onMoveDownloadTask);
    _d('DownloadManagerBloc constructed, hydrated downloads='
        '${state.downloads.length}');
  }

  Future<void> _onStarted(
    DownloadManagerStarted event,
    Emitter<DownloadManagerState> emit,
  ) async {
    _d('_onStarted: subscribing to progressStream, '
        'rehydrated=${state.downloads.length}');
    _progressSubscription =
        _foregroundDownloadService.progressStream.listen(_handleProgressUpdate);
    // HydratedBloc may have rehydrated tasks that were active when the app
    // last quit. The bg engine forgets all torrents on app restart, so any
    // queued/metadata/downloading entry would otherwise display as live
    // forever. Mark them stopped so the user can resume (re-add) if wanted.
    final next = <int, DownloadTask>{};
    var dirty = false;
    state.downloads.forEach((id, t) {
      if (t.status == DownloadStatus.downloading ||
          t.status == DownloadStatus.downloadingMetadata ||
          t.status == DownloadStatus.queued) {
        _d('_onStarted: reset stale task=$id from ${t.status} to paused');
        next[id] = t.copyWith(status: DownloadStatus.paused);
        dirty = true;
      } else {
        next[id] = t;
      }
    });
    if (dirty) emit(state.copyWith(downloads: next));
  }

  void _handleProgressUpdate(ProgressUpdate update) {
    try {
      final existing = state.downloads[update.taskId];
      if (existing == null) {
        _d('_handleProgressUpdate: stale update for unknown taskId='
            '${update.taskId}, ignoring');
        return;
      }
      if (existing.status != update.status) {
        _d('_handleProgressUpdate: task=${update.taskId} status '
            '${existing.status} -> ${update.status} '
            '(progress=${(update.progress * 100).toStringAsFixed(1)}%, '
            'dl=${update.downloadSpeed}, ul=${update.uploadSpeed}, '
            'done=${update.downloadedBytes}/${update.totalBytes})');
      }
      final updated = existing.copyWith(
        status: update.status,
        progress: update.progress.clamp(0.0, 1.0),
        downloadSpeed: update.downloadSpeed,
        uploadSpeed: update.uploadSpeed,
        peers: update.peers,
        seeders: update.seeders,
        downloadedBytes: update.downloadedBytes,
        totalBytes:
            update.totalBytes > 0 ? update.totalBytes : existing.totalBytes,
        errorMessage: update.error ??
            (update.status == DownloadStatus.failed
                ? existing.errorMessage
                : null),
        files: update.files ?? existing.files,
        trackers: update.trackers ?? existing.trackers,
        downloadSpeedLimit:
            update.downloadSpeedLimit ?? existing.downloadSpeedLimit,
        uploadSpeedLimit: update.uploadSpeedLimit ?? existing.uploadSpeedLimit,
        filePath: update.savedFilePath ?? existing.filePath,
        completedAt: update.status == DownloadStatus.completed
            ? (existing.completedAt ?? DateTime.now())
            : existing.completedAt,
      );
      add(DownloadManagerUpdateProgress(updated));
    } catch (e, s) {
      _d('ERROR in _handleProgressUpdate: $e', error: e, stackTrace: s);
    }
  }

  Future<void> _onAddDownload(
    DownloadManagerAddDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    _d('_onAddDownload: taskId=${event.task.taskId}, '
        'movieTitle="${event.task.movieTitle}", '
        'selected=${event.selectedIndices}, preview=${event.previewMode}');
    try {
      if (state.downloads.containsKey(event.task.taskId)) {
        _d('_onAddDownload: duplicate taskId, skipping');
        return;
      }

      final initial = event.task.copyWith(
        status: DownloadStatus.queued,
        startedAt: DateTime.now(),
      );
      emit(state.copyWith(
        downloads: {...state.downloads, event.task.taskId: initial},
      ));
      _d('_onAddDownload: emitted queued state, dispatching to service');

      await _foregroundDownloadService.startDownload(
        taskId: event.task.taskId,
        magnetUri: event.task.magnetUri,
        savePath:
            event.task.filePath ?? _foregroundDownloadService.downloadPath,
        movieTitle: event.task.movieTitle,
        downloadLimit: event.task.downloadSpeedLimit,
        uploadLimit: event.task.uploadSpeedLimit,
        selectedIndices:
            event.selectedIndices ?? _selectedIndices(event.task.files),
        previewMode: event.previewMode,
      );
    } catch (e, s) {
      _d('_onAddDownload: failed: $e', error: e, stackTrace: s);
      final errorTask = event.task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
      emit(state.copyWith(
        downloads: {...state.downloads, event.task.taskId: errorTask},
      ));
    }
  }

  Future<void> _onPauseDownload(
    DownloadManagerPauseDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    _d('_onPauseDownload: taskId=${event.taskId}');
    await _foregroundDownloadService.pauseDownload(event.taskId);
    final task = state.downloads[event.taskId];
    if (task != null) {
      emit(state.copyWith(downloads: {
        ...state.downloads,
        event.taskId: task.copyWith(status: DownloadStatus.paused),
      }));
    }
  }

  Future<void> _onResumeDownload(
    DownloadManagerResumeDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    _d('_onResumeDownload: taskId=${event.taskId}');
    await _foregroundDownloadService.resumeDownload(event.taskId);
    final task = state.downloads[event.taskId];
    if (task != null) {
      emit(state.copyWith(downloads: {
        ...state.downloads,
        event.taskId: task.copyWith(status: DownloadStatus.downloading),
      }));
    }
  }

  Future<void> _onStopDownload(
    DownloadManagerStopDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    _d('_onStopDownload: taskId=${event.taskId}');
    await _foregroundDownloadService.stopDownload(event.taskId);
    final task = state.downloads[event.taskId];
    if (task != null) {
      emit(state.copyWith(downloads: {
        ...state.downloads,
        event.taskId: task.copyWith(status: DownloadStatus.stopped),
      }));
    }
  }

  Future<void> _onDeleteDownload(
    DownloadManagerDeleteDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    _d('_onDeleteDownload: taskId=${event.taskId}');
    try {
      final task = state.downloads[event.taskId];
      // Ask the engine to wipe files first (it releases its file handles
      // before unlinking, important on Windows). No-op if the task wasn't
      // attached to the engine (e.g. rehydrated as stopped after restart).
      await _foregroundDownloadService.deleteDownload(event.taskId);
      // Then sweep anything the engine missed (rehydrated/never-started).
      // Wait a tick so the engine's deleteFiles unlinks land first; otherwise
      // we'd race on multi-file torrents.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await _deleteDownloadArtifacts(task);
      final next = Map<int, DownloadTask>.from(state.downloads)
        ..remove(event.taskId);
      emit(state.copyWith(downloads: next));
    } catch (e, s) {
      _d('_onDeleteDownload: failed: $e', error: e, stackTrace: s);
    }
  }

  /// Best-effort filesystem cleanup. Runs after the engine-side delete and
  /// also handles rehydrated tasks the engine never knew about.
  ///
  /// libtorrent stores files at `<basePath>/<file.name>`, where `file.name`
  /// is the in-torrent path. Multi-file torrents share a common root folder
  /// (the torrent name) — wipe that whole subdir. Single-file torrents drop
  /// straight into `<basePath>`, so delete the individual file. Never touch
  /// `basePath` itself — other torrents may share it.
  Future<void> _deleteDownloadArtifacts(DownloadTask? task) async {
    if (task == null) return;
    final basePath = task.filePath;
    if (basePath == null) return;
    _d('_deleteDownloadArtifacts: basePath=$basePath, '
        'files=${task.files.length}');

    final sep = Platform.pathSeparator;
    final commonRoot = _commonTopFolder(task.files);
    if (commonRoot != null) {
      final rootDir = Directory('$basePath$sep$commonRoot');
      try {
        if (await rootDir.exists()) {
          await rootDir.delete(recursive: true);
          _d('_deleteDownloadArtifacts: wiped $rootDir');
          return;
        }
      } catch (e, s) {
        _d('_deleteDownloadArtifacts: wipe subdir failed: $e',
            error: e, stackTrace: s);
      }
    }
    for (final file in task.files) {
      try {
        final normalized = file.name.replaceAll('/', sep);
        final f = File('$basePath$sep$normalized');
        if (await f.exists()) await f.delete();
      } catch (e) {
        _d('_deleteDownloadArtifacts: delete file failed: $e');
      }
    }
  }

  /// Returns the shared top-level folder name across [files] (e.g. the
  /// torrent root) when every file lives under one, else null. Treats
  /// both `/` and `\` as separators since libtorrent uses POSIX paths.
  static String? _commonTopFolder(List<TorrentFileInfo> files) {
    if (files.isEmpty) return null;
    String? root;
    for (final f in files) {
      final parts = f.name.split(RegExp(r'[\\/]'));
      if (parts.length < 2 || parts.first.isEmpty) return null;
      if (root == null) {
        root = parts.first;
      } else if (root != parts.first) {
        return null;
      }
    }
    return root;
  }

  void _onUpdateProgress(
    DownloadManagerUpdateProgress event,
    Emitter<DownloadManagerState> emit,
  ) {
    emit(state.copyWith(downloads: {
      ...state.downloads,
      event.task.taskId: event.task,
    }));
  }

  void _onClearCompleted(
    DownloadManagerClearCompleted event,
    Emitter<DownloadManagerState> emit,
  ) {
    final before = state.downloads.length;
    final next = Map<int, DownloadTask>.from(state.downloads)
      ..removeWhere((_, v) => v.status == DownloadStatus.completed);
    _d('_onClearCompleted: removed ${before - next.length} entries');
    emit(state.copyWith(downloads: next));
  }

  Future<void> _onSetSpeedLimit(
    DownloadManagerSetSpeedLimit event,
    Emitter<DownloadManagerState> emit,
  ) async {
    _d('_onSetSpeedLimit: taskId=${event.taskId}, '
        'dl=${event.downloadLimit}, ul=${event.uploadLimit}');
    await _foregroundDownloadService.setSpeedLimit(
      taskId: event.taskId,
      downloadLimit: event.downloadLimit,
      uploadLimit: event.uploadLimit,
    );
    final task = state.downloads[event.taskId];
    if (task != null) {
      emit(state.copyWith(downloads: {
        ...state.downloads,
        event.taskId: task.copyWith(
          downloadSpeedLimit: event.downloadLimit,
          uploadSpeedLimit: event.uploadLimit,
        ),
      }));
    }
  }

  Future<void> _onSetFilePriority(
    DownloadManagerSetFilePriority event,
    Emitter<DownloadManagerState> emit,
  ) async {
    _d('_onSetFilePriority: taskId=${event.taskId}, '
        'file=${event.fileIndex}, prio=${event.priority}');
    await _foregroundDownloadService.setFilePriority(
      taskId: event.taskId,
      fileIndex: event.fileIndex,
      priority: event.priority,
    );
  }

  Future<void> _onApplyFileSelection(
    DownloadManagerApplyFileSelection event,
    Emitter<DownloadManagerState> emit,
  ) async {
    _d('_onApplyFileSelection: taskId=${event.taskId}, '
        'selected=${event.selectedIndices}');
    await _foregroundDownloadService.applyFileSelection(
      taskId: event.taskId,
      selectedIndices: event.selectedIndices,
    );
  }

  /// libtorrent_flutter has no live-move API. We rename files on disk from the
  /// main isolate — works for completed/paused/stopped tasks; an in-progress
  /// download will keep writing to the old path until restarted.
  Future<void> _onMoveDownloadTask(
    DownloadManagerMoveDownloadTask event,
    Emitter<DownloadManagerState> emit,
  ) async {
    _d('_onMoveDownloadTask: taskId=${event.taskId}, '
        'newPath=${event.newSavePath}');
    final current = state.downloads[event.taskId];
    if (current == null) return;
    final moved = await _moveTaskFilesLocal(current, event.newSavePath);
    if (moved) {
      emit(state.copyWith(downloads: {
        ...state.downloads,
        event.taskId: current.copyWith(filePath: event.newSavePath),
      }));
    }
  }

  Future<bool> _moveTaskFilesLocal(
      DownloadTask task, String newSavePath) async {
    final basePath = task.filePath ?? _foregroundDownloadService.downloadPath;
    try {
      await Directory(newSavePath).create(recursive: true);
      var moved = 0;
      for (final file in task.files) {
        final normalized = file.name.replaceAll('/', Platform.pathSeparator);
        final fromPath = '$basePath${Platform.pathSeparator}$normalized';
        final toPath = '$newSavePath${Platform.pathSeparator}$normalized';
        final src = File(fromPath);
        if (!await src.exists()) continue;
        await Directory(File(toPath).parent.path).create(recursive: true);
        await src.rename(toPath);
        moved++;
      }
      // If the source basePath itself is now empty and is a subdir of the
      // legacy default, tidy it up. Best-effort only.
      try {
        final srcDir = Directory(basePath);
        if (await srcDir.exists() &&
            await srcDir.list().isEmpty &&
            basePath != newSavePath) {
          await srcDir.delete();
        }
      } catch (_) {}
      return moved > 0 || task.files.isEmpty;
    } catch (e, s) {
      _d('_moveTaskFilesLocal failed: $e', error: e, stackTrace: s);
      return false;
    }
  }

  List<int>? _selectedIndices(List<TorrentFileInfo> files) {
    if (files.isEmpty) return null;
    final selected = <int>[];
    for (final file in files) {
      if (file.priority != FilePriorityLevel.skip) {
        selected.add(file.index);
      }
    }
    return selected;
  }

  @override
  @disposeMethod
  Future<void> close() {
    _d('close: cancelling subscription');
    _progressSubscription?.cancel();
    return super.close();
  }

  @override
  DownloadManagerState? fromJson(Map<String, dynamic> json) {
    try {
      return DownloadManagerState.fromJson(json);
    } catch (e, s) {
      _d('fromJson failed: $e', error: e, stackTrace: s);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(DownloadManagerState state) {
    try {
      return state.toJson();
    } catch (e, s) {
      _d('toJson failed: $e', error: e, stackTrace: s);
      return null;
    }
  }
}
