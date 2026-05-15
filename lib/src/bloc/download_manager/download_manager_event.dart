part of 'download_manager_bloc.dart';

/// Base class for download manager events
sealed class DownloadManagerEvent {}

class DownloadManagerStarted extends DownloadManagerEvent {}

class DownloadManagerAddDownload extends DownloadManagerEvent {
  final DownloadTask task;
  DownloadManagerAddDownload({required this.task});
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

/// Set per-task speed limits (null = unlimited)
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

class DownloadManagerAddTracker extends DownloadManagerEvent {
  final int taskId;
  final String trackerUrl;
  DownloadManagerAddTracker({required this.taskId, required this.trackerUrl});
}

class DownloadManagerRemoveTracker extends DownloadManagerEvent {
  final int taskId;
  final String trackerUrl;
  DownloadManagerRemoveTracker({
    required this.taskId,
    required this.trackerUrl,
  });
}
