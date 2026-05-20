part of 'download_manager_bloc.dart';

/// Base class for download manager events
sealed class DownloadManagerEvent {}

class DownloadManagerStarted extends DownloadManagerEvent {}

class DownloadManagerAddDownload extends DownloadManagerEvent {
  final DownloadTask task;
  final List<int>? selectedIndices;

  /// When true, the magnet is added only to fetch metadata for the
  /// pre-download config dialog. The handler skips all files until the dialog
  /// confirms with applyFileSelection.
  final bool previewMode;
  DownloadManagerAddDownload({
    required this.task,
    this.selectedIndices,
    this.previewMode = false,
  });
}

class DownloadManagerPauseDownload extends DownloadManagerEvent {
  final int taskId;
  DownloadManagerPauseDownload(this.taskId);
}

class DownloadManagerResumeDownload extends DownloadManagerEvent {
  final int taskId;
  DownloadManagerResumeDownload(this.taskId);
}

class DownloadManagerStopDownload extends DownloadManagerEvent {
  final int taskId;
  DownloadManagerStopDownload(this.taskId);
}

class DownloadManagerDeleteDownload extends DownloadManagerEvent {
  final int taskId;
  DownloadManagerDeleteDownload(this.taskId);
}

class DownloadManagerUpdateProgress extends DownloadManagerEvent {
  final DownloadTask task;
  DownloadManagerUpdateProgress(this.task);
}

class DownloadManagerClearCompleted extends DownloadManagerEvent {}

/// libtorrent_flutter only honours session-wide caps; the handler stores the
/// last requested values for UI display.
class DownloadManagerSetSpeedLimit extends DownloadManagerEvent {
  final int taskId;
  final int? downloadLimit;
  final int? uploadLimit;
  DownloadManagerSetSpeedLimit({
    required this.taskId,
    this.downloadLimit,
    this.uploadLimit,
  });
}

/// Set priority for a single file in a task
class DownloadManagerSetFilePriority extends DownloadManagerEvent {
  final int taskId;
  final int fileIndex;
  final FilePriorityLevel priority;
  DownloadManagerSetFilePriority({
    required this.taskId,
    required this.fileIndex,
    required this.priority,
  });
}

/// Replace the selected-file set for a task
class DownloadManagerApplyFileSelection extends DownloadManagerEvent {
  final int taskId;
  final List<int> selectedIndices;
  DownloadManagerApplyFileSelection({
    required this.taskId,
    required this.selectedIndices,
  });
}

/// Move all files for a download task to a new directory.
/// Handled entirely in the main isolate (libtorrent_flutter has no live-move
/// API); rename only succeeds for finished or paused downloads.
class DownloadManagerMoveDownloadTask extends DownloadManagerEvent {
  final int taskId;
  final String newSavePath;
  DownloadManagerMoveDownloadTask({
    required this.taskId,
    required this.newSavePath,
  });
}
