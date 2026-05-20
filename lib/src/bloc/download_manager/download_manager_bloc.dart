import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/torrent_service_models.dart';
import 'package:ytsmovies/src/services/foreground_download_service.dart';

part 'download_manager_event.dart';
part 'download_manager_state.dart';

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
  }

  Future<void> _onStarted(
    DownloadManagerStarted event,
    Emitter<DownloadManagerState> emit,
  ) async {
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
        next[id] = t.copyWith(status: DownloadStatus.stopped);
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
      // Stale updates land here when the user deletes a task while the bg
      // handler still has in-flight progress on the wire. No-op silently.
      if (existing == null) return;
      // Only overwrite fields that the update meaningfully carries.
      final updated = existing.copyWith(
        status: update.status,
        progress: update.progress > 0 ? update.progress : existing.progress,
        downloadSpeed: update.downloadSpeed,
        uploadSpeed: update.uploadSpeed,
        peers: update.peers,
        seeders: update.seeders,
        downloadedBytes: update.downloadedBytes > 0
            ? update.downloadedBytes
            : existing.downloadedBytes,
        totalBytes:
            update.totalBytes > 0 ? update.totalBytes : existing.totalBytes,
        // Stick to whichever error is newest; clear if the engine reports a
        // healthy state again (recovery).
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
        // Set once on the first completed update; later seeding-phase
        // updates would otherwise keep bumping the timestamp forward.
        completedAt: update.status == DownloadStatus.completed
            ? (existing.completedAt ?? DateTime.now())
            : existing.completedAt,
      );
      add(DownloadManagerUpdateProgress(updated));
    } catch (e, s) {
      log('ERROR in _handleProgressUpdate: $e', error: e, stackTrace: s);
    }
  }

  Future<void> _onAddDownload(
    DownloadManagerAddDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      if (state.downloads.containsKey(event.task.taskId)) return;

      final initial = event.task.copyWith(
        status: DownloadStatus.queued,
        startedAt: DateTime.now(),
      );
      emit(state.copyWith(
        downloads: {...state.downloads, event.task.taskId: initial},
      ));

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
      log('Error adding download: $e', error: e, stackTrace: s);
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
    try {
      final task = state.downloads[event.taskId];
      await _foregroundDownloadService.stopDownload(event.taskId);
      await _deleteDownloadArtifacts(task);
      final next = Map<int, DownloadTask>.from(state.downloads)
        ..remove(event.taskId);
      emit(state.copyWith(downloads: next));
    } catch (e, s) {
      log('Error deleting download: $e', error: e, stackTrace: s);
    }
  }

  /// `filePath` is the save **directory**. Delete each known file plus the
  /// directory itself if empty. Best-effort — swallow per-entry errors so
  /// one stuck file doesn't block removing the rest.
  Future<void> _deleteDownloadArtifacts(DownloadTask? task) async {
    if (task == null) return;
    final basePath = task.filePath;
    if (basePath == null) return;
    for (final file in task.files) {
      try {
        final normalized = file.name.replaceAll('/', Platform.pathSeparator);
        final f = File('$basePath${Platform.pathSeparator}$normalized');
        if (await f.exists()) await f.delete();
      } catch (e) {
        log('Delete file failed: $e');
      }
    }
    try {
      final dir = Directory(basePath);
      if (await dir.exists()) {
        final remaining = await dir.list().toList();
        if (remaining.isEmpty) {
          await dir.delete();
        } else if (task.files.isEmpty) {
          // No file metadata recorded (e.g. download failed before metadata).
          // Wipe the per-task dir wholesale to clean up state files.
          await dir.delete(recursive: true);
        }
      }
    } catch (e) {
      log('Delete dir failed: $e');
    }
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
    final next = Map<int, DownloadTask>.from(state.downloads)
      ..removeWhere((_, v) => v.status == DownloadStatus.completed);
    emit(state.copyWith(downloads: next));
  }

  Future<void> _onSetSpeedLimit(
    DownloadManagerSetSpeedLimit event,
    Emitter<DownloadManagerState> emit,
  ) async {
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
      log('Local move failed: $e', error: e, stackTrace: s);
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
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }

  @override
  DownloadManagerState? fromJson(Map<String, dynamic> json) {
    try {
      return DownloadManagerState.fromJson(json);
    } catch (e) {
      log('Error deserializing DownloadManagerState: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(DownloadManagerState state) {
    try {
      return state.toJson();
    } catch (e) {
      log('Error serializing DownloadManagerState: $e');
      return null;
    }
  }
}
