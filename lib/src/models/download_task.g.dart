// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DownloadTask _$DownloadTaskFromJson(Map<String, dynamic> json) =>
    _DownloadTask(
      taskId: (json['task_id'] as num).toInt(),
      movieId: (json['movie_id'] as num).toInt(),
      movieTitle: json['movie_title'] as String,
      torrentHash: json['torrent_hash'] as String,
      magnetUri: json['magnet_uri'] as String,
      quality: json['quality'] as String,
      type: json['type'] as String?,
      size: json['size'] as String,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      status: $enumDecodeNullable(_$DownloadStatusEnumMap, json['status']) ??
          DownloadStatus.queued,
      downloadSpeed: (json['download_speed'] as num?)?.toInt() ?? 0,
      uploadSpeed: (json['upload_speed'] as num?)?.toInt() ?? 0,
      peers: (json['peers'] as num?)?.toInt() ?? 0,
      seeders: (json['seeders'] as num?)?.toInt() ?? 0,
      downloadedBytes: (json['downloaded_bytes'] as num?)?.toInt() ?? 0,
      totalBytes: (json['total_bytes'] as num?)?.toInt() ?? 0,
      filePath: json['file_path'] as String?,
      errorMessage: json['error_message'] as String?,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      coverImage: json['cover_image'] as String?,
    );

Map<String, dynamic> _$DownloadTaskToJson(_DownloadTask instance) =>
    <String, dynamic>{
      'task_id': instance.taskId,
      'movie_id': instance.movieId,
      'movie_title': instance.movieTitle,
      'torrent_hash': instance.torrentHash,
      'magnet_uri': instance.magnetUri,
      'quality': instance.quality,
      'type': instance.type,
      'size': instance.size,
      'progress': instance.progress,
      'status': _$DownloadStatusEnumMap[instance.status]!,
      'download_speed': instance.downloadSpeed,
      'upload_speed': instance.uploadSpeed,
      'peers': instance.peers,
      'seeders': instance.seeders,
      'downloaded_bytes': instance.downloadedBytes,
      'total_bytes': instance.totalBytes,
      'file_path': instance.filePath,
      'error_message': instance.errorMessage,
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'cover_image': instance.coverImage,
    };

const _$DownloadStatusEnumMap = {
  DownloadStatus.queued: 'queued',
  DownloadStatus.downloading: 'downloading',
  DownloadStatus.paused: 'paused',
  DownloadStatus.completed: 'completed',
  DownloadStatus.failed: 'failed',
  DownloadStatus.stopped: 'stopped',
};
