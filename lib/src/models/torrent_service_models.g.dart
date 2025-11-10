// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'torrent_service_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StartDownloadRequest _$StartDownloadRequestFromJson(
        Map<String, dynamic> json) =>
    _StartDownloadRequest(
      taskId: (json['taskId'] as num).toInt(),
      magnetUri: json['magnetUri'] as String,
      savePath: json['savePath'] as String,
      movieTitle: json['movieTitle'] as String,
    );

Map<String, dynamic> _$StartDownloadRequestToJson(
        _StartDownloadRequest instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'magnetUri': instance.magnetUri,
      'savePath': instance.savePath,
      'movieTitle': instance.movieTitle,
    };

_PauseDownloadRequest _$PauseDownloadRequestFromJson(
        Map<String, dynamic> json) =>
    _PauseDownloadRequest(
      taskId: (json['taskId'] as num).toInt(),
    );

Map<String, dynamic> _$PauseDownloadRequestToJson(
        _PauseDownloadRequest instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
    };

_ResumeDownloadRequest _$ResumeDownloadRequestFromJson(
        Map<String, dynamic> json) =>
    _ResumeDownloadRequest(
      taskId: (json['taskId'] as num).toInt(),
    );

Map<String, dynamic> _$ResumeDownloadRequestToJson(
        _ResumeDownloadRequest instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
    };

_StopDownloadRequest _$StopDownloadRequestFromJson(Map<String, dynamic> json) =>
    _StopDownloadRequest(
      taskId: (json['taskId'] as num).toInt(),
    );

Map<String, dynamic> _$StopDownloadRequestToJson(
        _StopDownloadRequest instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
    };

_ProgressUpdate _$ProgressUpdateFromJson(Map<String, dynamic> json) =>
    _ProgressUpdate(
      taskId: (json['taskId'] as num).toInt(),
      status: $enumDecode(_$DownloadStatusTypeEnumMap, json['status']),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      downloadSpeed: (json['downloadSpeed'] as num?)?.toInt() ?? 0,
      uploadSpeed: (json['uploadSpeed'] as num?)?.toInt() ?? 0,
      peers: (json['peers'] as num?)?.toInt() ?? 0,
      seeders: (json['seeders'] as num?)?.toInt() ?? 0,
      downloadedBytes: (json['downloadedBytes'] as num?)?.toInt() ?? 0,
      totalBytes: (json['totalBytes'] as num?)?.toInt() ?? 0,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$ProgressUpdateToJson(_ProgressUpdate instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'status': _$DownloadStatusTypeEnumMap[instance.status]!,
      'progress': instance.progress,
      'downloadSpeed': instance.downloadSpeed,
      'uploadSpeed': instance.uploadSpeed,
      'peers': instance.peers,
      'seeders': instance.seeders,
      'downloadedBytes': instance.downloadedBytes,
      'totalBytes': instance.totalBytes,
      'error': instance.error,
    };

const _$DownloadStatusTypeEnumMap = {
  DownloadStatusType.downloadingMetadata: 'downloading_metadata',
  DownloadStatusType.downloading: 'downloading',
  DownloadStatusType.paused: 'paused',
  DownloadStatusType.completed: 'completed',
  DownloadStatusType.failed: 'failed',
  DownloadStatusType.stopped: 'stopped',
};
