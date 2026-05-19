import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytsmovies/src/models/download_task.dart';

part 'torrent_service_models.freezed.dart';
part 'torrent_service_models.g.dart';

/// Request to start a download
@freezed
sealed class StartDownloadRequest with _$StartDownloadRequest {
  const factory StartDownloadRequest({
    required int taskId,
    required String magnetUri,
    required String savePath,
    required String movieTitle,
    @Default(<String>[]) List<String> extraTrackers,
    int? initialDownloadLimit,
    int? initialUploadLimit,
    @Default(false) bool sequentialDownload,
    List<int>? selectedIndices,
  }) = _StartDownloadRequest;

  factory StartDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$StartDownloadRequestFromJson(json);
}

/// Unified control request for pause/resume/stop operations
@freezed
sealed class DownloadControlRequest with _$DownloadControlRequest {
  const factory DownloadControlRequest({
    required int taskId,
  }) = _DownloadControlRequest;

  factory DownloadControlRequest.fromJson(Map<String, dynamic> json) =>
      _$DownloadControlRequestFromJson(json);
}

/// Set per-task speed limit (null = unlimited)
@freezed
sealed class SetSpeedLimitRequest with _$SetSpeedLimitRequest {
  const factory SetSpeedLimitRequest({
    required int taskId,
    int? downloadLimit,
    int? uploadLimit,
  }) = _SetSpeedLimitRequest;

  factory SetSpeedLimitRequest.fromJson(Map<String, dynamic> json) =>
      _$SetSpeedLimitRequestFromJson(json);
}

/// Enable or disable sequential download for a task
@freezed
sealed class SetSequentialDownloadRequest with _$SetSequentialDownloadRequest {
  const factory SetSequentialDownloadRequest({
    required int taskId,
    required bool sequentialDownload,
  }) = _SetSequentialDownloadRequest;

  factory SetSequentialDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$SetSequentialDownloadRequestFromJson(json);
}

/// Set priority for a single file
@freezed
sealed class SetFilePriorityRequest with _$SetFilePriorityRequest {
  const factory SetFilePriorityRequest({
    required int taskId,
    required int fileIndex,
    required FilePriorityLevel priority,
  }) = _SetFilePriorityRequest;

  factory SetFilePriorityRequest.fromJson(Map<String, dynamic> json) =>
      _$SetFilePriorityRequestFromJson(json);
}

/// Apply a fresh file-selection list (indices to keep)
@freezed
sealed class ApplyFileSelectionRequest with _$ApplyFileSelectionRequest {
  const factory ApplyFileSelectionRequest({
    required int taskId,
    required List<int> selectedIndices,
  }) = _ApplyFileSelectionRequest;

  factory ApplyFileSelectionRequest.fromJson(Map<String, dynamic> json) =>
      _$ApplyFileSelectionRequestFromJson(json);
}

/// Move all files for a download task to a new directory
@freezed
sealed class MoveDownloadTaskRequest with _$MoveDownloadTaskRequest {
  const factory MoveDownloadTaskRequest({
    required int taskId,
    required String newSavePath,
  }) = _MoveDownloadTaskRequest;

  factory MoveDownloadTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$MoveDownloadTaskRequestFromJson(json);
}

/// Add a custom tracker URL
@freezed
sealed class AddTrackerRequest with _$AddTrackerRequest {
  const factory AddTrackerRequest({
    required int taskId,
    required String trackerUrl,
  }) = _AddTrackerRequest;

  factory AddTrackerRequest.fromJson(Map<String, dynamic> json) =>
      _$AddTrackerRequestFromJson(json);
}

/// Remove a tracker
@freezed
sealed class RemoveTrackerRequest with _$RemoveTrackerRequest {
  const factory RemoveTrackerRequest({
    required int taskId,
    required String trackerUrl,
  }) = _RemoveTrackerRequest;

  factory RemoveTrackerRequest.fromJson(Map<String, dynamic> json) =>
      _$RemoveTrackerRequestFromJson(json);
}

/// Progress update from background service.
/// Optional fields are emitted only when something changed (saves IPC bytes).
@freezed
sealed class ProgressUpdate with _$ProgressUpdate {
  const factory ProgressUpdate({
    required int taskId,
    required DownloadStatus status,
    @Default(0.0) double progress,
    @Default(0) int downloadSpeed,
    @Default(0) int uploadSpeed,
    @Default(0) int peers,
    @Default(0) int seeders,
    @Default(0) int downloadedBytes,
    @Default(0) int totalBytes,
    String? error,
    List<TorrentFileInfo>? files,
    List<TrackerInfo>? trackers,
    int? downloadSpeedLimit,
    int? uploadSpeedLimit,
    String? savedFilePath,
    bool? sequentialDownload,
  }) = _ProgressUpdate;

  factory ProgressUpdate.fromJson(Map<String, dynamic> json) =>
      _$ProgressUpdateFromJson(json);
}
