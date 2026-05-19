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
    on<DownloadManagerSetSequentialDownload>(_onSetSequentialDownload);
    on<DownloadManagerSetFilePriority>(_onSetFilePriority);
    on<DownloadManagerApplyFileSelection>(_onApplyFileSelection);
    on<DownloadManagerAddTracker>(_onAddTracker);
    on<DownloadManagerRemoveTracker>(_onRemoveTracker);
    on<DownloadManagerMoveDownloadTask>(_onMoveDownloadTask);
  }

  Future<void> _onStarted(
    DownloadManagerStarted event,
    Emitter<DownloadManagerState> emit,
  ) async {
    _progressSubscription =
        _foregroundDownloadService.progressStream.listen(_handleProgressUpdate);
  }

  void _handleProgressUpdate(ProgressUpdate update) {
    try {
      final existing = state.downloads[update.taskId];
      if (existing == null) {
        log('Progress for unknown task ${update.taskId}');
        return;
      }
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
        errorMessage: update.error ?? existing.errorMessage,
        files: update.files ?? existing.files,
        trackers: update.trackers ?? existing.trackers,
        downloadSpeedLimit:
            update.downloadSpeedLimit ?? existing.downloadSpeedLimit,
        uploadSpeedLimit: update.uploadSpeedLimit ?? existing.uploadSpeedLimit,
        sequentialDownload:
            update.sequentialDownload ?? existing.sequentialDownload,
        filePath: update.savedFilePath ?? existing.filePath,
        completedAt: update.status == DownloadStatus.completed
            ? DateTime.now()
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
        sequentialDownload: event.task.sequentialDownload,
        extraTrackers: event.task.trackers.map((t) => t.url).toList(),
        selectedIndices:
            event.selectedIndices ?? _selectedIndices(event.task.files),
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
      if (task?.filePath != null) {
        try {
          final f = File(task!.filePath!);
          if (await f.exists()) await f.delete();
        } catch (e) {
          log('Error deleting file: $e');
        }
      }
      final next = Map<int, DownloadTask>.from(state.downloads)
        ..remove(event.taskId);
      emit(state.copyWith(downloads: next));
    } catch (e, s) {
      log('Error deleting download: $e', error: e, stackTrace: s);
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

  Future<void> _onSetSequentialDownload(
    DownloadManagerSetSequentialDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    await _foregroundDownloadService.setSequentialDownload(
      taskId: event.taskId,
      sequentialDownload: event.sequentialDownload,
    );
    final task = state.downloads[event.taskId];
    if (task != null) {
      emit(state.copyWith(downloads: {
        ...state.downloads,
        event.taskId:
            task.copyWith(sequentialDownload: event.sequentialDownload),
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

  Future<void> _onAddTracker(
    DownloadManagerAddTracker event,
    Emitter<DownloadManagerState> emit,
  ) async {
    await _foregroundDownloadService.addTracker(
      taskId: event.taskId,
      trackerUrl: event.trackerUrl,
    );
  }

  Future<void> _onRemoveTracker(
    DownloadManagerRemoveTracker event,
    Emitter<DownloadManagerState> emit,
  ) async {
    await _foregroundDownloadService.removeTracker(
      taskId: event.taskId,
      trackerUrl: event.trackerUrl,
    );
  }

  Future<void> _onMoveDownloadTask(
    DownloadManagerMoveDownloadTask event,
    Emitter<DownloadManagerState> emit,
  ) async {
    final current = state.downloads[event.taskId];
    final running = await _foregroundDownloadService.isServiceRunning();
    if (running) {
      await _foregroundDownloadService.moveDownloadTask(
        taskId: event.taskId,
        newSavePath: event.newSavePath,
      );
    } else if (current != null) {
      await _moveTaskFilesLocal(current, event.newSavePath);
    }
    if (current != null) {
      emit(state.copyWith(downloads: {
        ...state.downloads,
        event.taskId: current.copyWith(filePath: event.newSavePath),
      }));
    }
  }

  Future<void> _moveTaskFilesLocal(
      DownloadTask task, String newSavePath) async {
    final basePath = task.filePath ?? _foregroundDownloadService.downloadPath;
    for (final file in task.files) {
      final fromPath = '$basePath${Platform.pathSeparator}${file.name}';
      final toPath = '$newSavePath${Platform.pathSeparator}${file.name}';
      final src = File(fromPath);
      if (!await src.exists()) continue;
      try {
        await Directory(File(toPath).parent.path).create(recursive: true);
      } catch (_) {}
      await src.rename(toPath);
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
