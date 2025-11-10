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

/// Progress update from background service
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
  }) = _ProgressUpdate;

  factory ProgressUpdate.fromJson(Map<String, dynamic> json) =>
      _$ProgressUpdateFromJson(json);
}
