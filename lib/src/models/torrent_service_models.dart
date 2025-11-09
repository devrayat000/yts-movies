import 'package:freezed_annotation/freezed_annotation.dart';

part 'torrent_service_models.freezed.dart';
part 'torrent_service_models.g.dart';

/// Request to start a download
@freezed
sealed class StartDownloadRequest with _$StartDownloadRequest {
  const factory StartDownloadRequest({
    required String taskId,
    required String magnetUri,
    required String savePath,
    required String movieTitle,
  }) = _StartDownloadRequest;

  factory StartDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$StartDownloadRequestFromJson(json);
}

/// Request to pause a download
@freezed
sealed class PauseDownloadRequest with _$PauseDownloadRequest {
  const factory PauseDownloadRequest({
    required String taskId,
  }) = _PauseDownloadRequest;

  factory PauseDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$PauseDownloadRequestFromJson(json);
}

/// Request to resume a download
@freezed
sealed class ResumeDownloadRequest with _$ResumeDownloadRequest {
  const factory ResumeDownloadRequest({
    required String taskId,
  }) = _ResumeDownloadRequest;

  factory ResumeDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$ResumeDownloadRequestFromJson(json);
}

/// Request to stop a download
@freezed
sealed class StopDownloadRequest with _$StopDownloadRequest {
  const factory StopDownloadRequest({
    required String taskId,
  }) = _StopDownloadRequest;

  factory StopDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$StopDownloadRequestFromJson(json);
}

/// Download status enum
enum DownloadStatusType {
  @JsonValue('downloading_metadata')
  downloadingMetadata,
  @JsonValue('downloading')
  downloading,
  @JsonValue('paused')
  paused,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('stopped')
  stopped,
}

/// Progress update from background service
@freezed
sealed class ProgressUpdate with _$ProgressUpdate {
  const factory ProgressUpdate({
    required String taskId,
    required DownloadStatusType status,
    @Default(0.0) double progress,
    @Default(0) int downloadSpeed,
    @Default(0) int uploadSpeed,
    @Default(0) int peers,
    @Default(0) int seeders,
    @Default(0) int downloadedBytes,
    @Default(0) int totalBytes,
    String? error,
  }) = _ProgressUpdate;

  factory ProgressUpdate.fromJson(Map<String, dynamic> json) =>
      _$ProgressUpdateFromJson(json);
}
