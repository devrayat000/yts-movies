part of 'download_manager_bloc.dart';

/// Base class for download manager events
sealed class DownloadManagerEvent {}

/// Event to initialize the download manager
class DownloadManagerStarted extends DownloadManagerEvent {}

/// Event to add a new download
class DownloadManagerAddDownload extends DownloadManagerEvent {
  final DownloadTask task;

  DownloadManagerAddDownload({
    required this.task,
  });
}

/// Event to pause a download
class DownloadManagerPauseDownload extends DownloadManagerEvent {
  final int taskId;

  DownloadManagerPauseDownload(this.taskId);
}

/// Event to resume a download
class DownloadManagerResumeDownload extends DownloadManagerEvent {
  final int taskId;

  DownloadManagerResumeDownload(this.taskId);
}

/// Event to stop a download
class DownloadManagerStopDownload extends DownloadManagerEvent {
  final int taskId;

  DownloadManagerStopDownload(this.taskId);
}

/// Event to delete a download
class DownloadManagerDeleteDownload extends DownloadManagerEvent {
  final int taskId;

  DownloadManagerDeleteDownload(this.taskId);
}

/// Event to update download progress
class DownloadManagerUpdateProgress extends DownloadManagerEvent {
  final DownloadTask task;

  DownloadManagerUpdateProgress(this.task);
}

/// Event to clear all completed downloads
class DownloadManagerClearCompleted extends DownloadManagerEvent {}
