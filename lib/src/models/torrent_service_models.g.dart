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

_DownloadControlRequest _$DownloadControlRequestFromJson(
        Map<String, dynamic> json) =>
    _DownloadControlRequest(
      taskId: (json['taskId'] as num).toInt(),
    );

Map<String, dynamic> _$DownloadControlRequestToJson(
        _DownloadControlRequest instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
    };

_ProgressUpdate _$ProgressUpdateFromJson(Map<String, dynamic> json) =>
    _ProgressUpdate(
      taskId: (json['taskId'] as num).toInt(),
      status: $enumDecode(_$DownloadStatusEnumMap, json['status']),
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
      'status': _$DownloadStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'downloadSpeed': instance.downloadSpeed,
      'uploadSpeed': instance.uploadSpeed,
      'peers': instance.peers,
      'seeders': instance.seeders,
      'downloadedBytes': instance.downloadedBytes,
      'totalBytes': instance.totalBytes,
      'error': instance.error,
    };

const _$DownloadStatusEnumMap = {
  DownloadStatus.queued: 'queued',
  DownloadStatus.downloadingMetadata: 'downloading_metadata',
  DownloadStatus.downloading: 'downloading',
  DownloadStatus.paused: 'paused',
  DownloadStatus.completed: 'completed',
  DownloadStatus.failed: 'failed',
  DownloadStatus.stopped: 'stopped',
};
