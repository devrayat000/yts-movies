import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/movie.dart';
import 'package:ytsmovies/src/models/torrent.dart' as models;
import 'package:ytsmovies/src/services/torrent_download_service.dart';

part 'download_manager_event.dart';
part 'download_manager_state.dart';

/// BLoC for managing downloads
class DownloadManagerBloc
    extends HydratedBloc<DownloadManagerEvent, DownloadManagerState> {
  final TorrentDownloadService _downloadService;
  StreamSubscription<DownloadTask>? _progressSubscription;

  DownloadManagerBloc(this._downloadService)
      : super(const DownloadManagerState()) {
    on<DownloadManagerStarted>(_onStarted);
    on<DownloadManagerAddDownload>(_onAddDownload);
    on<DownloadManagerPauseDownload>(_onPauseDownload);
    on<DownloadManagerResumeDownload>(_onResumeDownload);
    on<DownloadManagerStopDownload>(_onStopDownload);
    on<DownloadManagerDeleteDownload>(_onDeleteDownload);
    on<DownloadManagerUpdateProgress>(_onUpdateProgress);
    on<DownloadManagerClearCompleted>(_onClearCompleted);
  }

  /// Handle initialization
  Future<void> _onStarted(
    DownloadManagerStarted event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      // Subscribe to progress updates
      _progressSubscription = _downloadService.progressStream.listen(
        (task) => add(DownloadManagerUpdateProgress(task)),
      );

      log('DownloadManager started and listening to progress updates');
    } catch (e, s) {
      log('Error starting DownloadManager: $e', error: e, stackTrace: s);
    }
  }

  /// Handle adding a new download
  Future<void> _onAddDownload(
    DownloadManagerAddDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      // Check if already downloading
      if (state.downloads.containsKey(event.task.taskId)) {
        log('Download already exists: ${event.task.taskId}');
        return;
      }

      // Add task to state
      final updatedDownloads = Map<String, DownloadTask>.from(state.downloads)
        ..[event.task.taskId] = event.task;

      emit(state.copyWith(downloads: updatedDownloads));

      // Start download in service
      final downloadTask = await _downloadService.startDownload(
        movie: event.movie,
        torrent: event.torrent,
      );

      // Update with started status
      final startedDownloads = Map<String, DownloadTask>.from(state.downloads)
        ..[downloadTask.taskId] = downloadTask;

      emit(state.copyWith(downloads: startedDownloads));
    } catch (e, s) {
      log('Error adding download: $e', error: e, stackTrace: s);
      // Update task with error
      final errorTask = event.task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
      final errorDownloads = Map<String, DownloadTask>.from(state.downloads)
        ..[event.task.taskId] = errorTask;

      emit(state.copyWith(downloads: errorDownloads));
    }
  }

  /// Handle pausing a download
  Future<void> _onPauseDownload(
    DownloadManagerPauseDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      await _downloadService.pauseDownload(event.taskId);

      final task = state.downloads[event.taskId];
      if (task != null) {
        final updatedTask = task.copyWith(status: DownloadStatus.paused);
        final updatedDownloads = Map<String, DownloadTask>.from(state.downloads)
          ..[event.taskId] = updatedTask;

        emit(state.copyWith(downloads: updatedDownloads));
      }
    } catch (e, s) {
      log('Error pausing download: $e', error: e, stackTrace: s);
    }
  }

  /// Handle resuming a download
  Future<void> _onResumeDownload(
    DownloadManagerResumeDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      final task = state.downloads[event.taskId];
      if (task != null) {
        await _downloadService.resumeDownload(event.taskId, task.magnetUri);

        final updatedTask = task.copyWith(status: DownloadStatus.downloading);
        final updatedDownloads = Map<String, DownloadTask>.from(state.downloads)
          ..[event.taskId] = updatedTask;

        emit(state.copyWith(downloads: updatedDownloads));
      }
    } catch (e, s) {
      log('Error resuming download: $e', error: e, stackTrace: s);
    }
  }

  /// Handle stopping a download
  Future<void> _onStopDownload(
    DownloadManagerStopDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      await _downloadService.stopDownload(event.taskId);

      final task = state.downloads[event.taskId];
      if (task != null) {
        final updatedTask = task.copyWith(status: DownloadStatus.stopped);
        final updatedDownloads = Map<String, DownloadTask>.from(state.downloads)
          ..[event.taskId] = updatedTask;

        emit(state.copyWith(downloads: updatedDownloads));
      }
    } catch (e, s) {
      log('Error stopping download: $e', error: e, stackTrace: s);
    }
  }

  /// Handle deleting a download
  Future<void> _onDeleteDownload(
    DownloadManagerDeleteDownload event,
    Emitter<DownloadManagerState> emit,
  ) async {
    try {
      final task = state.downloads[event.taskId];
      await _downloadService.deleteDownload(event.taskId, task?.filePath);

      final updatedDownloads = Map<String, DownloadTask>.from(state.downloads)
        ..remove(event.taskId);

      emit(state.copyWith(downloads: updatedDownloads));
    } catch (e, s) {
      log('Error deleting download: $e', error: e, stackTrace: s);
    }
  }

  /// Handle progress updates
  void _onUpdateProgress(
    DownloadManagerUpdateProgress event,
    Emitter<DownloadManagerState> emit,
  ) {
    final updatedDownloads = Map<String, DownloadTask>.from(state.downloads)
      ..[event.task.taskId] = event.task;

    emit(state.copyWith(downloads: updatedDownloads));
  }

  /// Handle clearing completed downloads
  void _onClearCompleted(
    DownloadManagerClearCompleted event,
    Emitter<DownloadManagerState> emit,
  ) {
    final updatedDownloads = Map<String, DownloadTask>.from(state.downloads)
      ..removeWhere((key, value) => value.status == DownloadStatus.completed);

    emit(state.copyWith(downloads: updatedDownloads));
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
