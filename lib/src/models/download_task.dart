import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_task.g.dart';
part 'download_task.freezed.dart';

/// Unified download status enumeration for both UI and background service
enum DownloadStatus {
  @JsonValue('queued')
  queued,
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

/// Per-file download priority (maps to dtorrent_task_v2 FilePriority)
enum FilePriorityLevel {
  @JsonValue('skip')
  skip,
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
}

/// Tracker connection status
enum TrackerStatus {
  @JsonValue('unknown')
  unknown,
  @JsonValue('connecting')
  connecting,
  @JsonValue('working')
  working,
  @JsonValue('failed')
  failed,
}

/// Per-file information for a torrent download
@Freezed(equal: true, toStringOverride: true)
sealed class TorrentFileInfo with _$TorrentFileInfo {
  const TorrentFileInfo._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TorrentFileInfo({
    required int index,
    required String name,
    required int size,
    @Default(0) int downloaded,
    @Default(FilePriorityLevel.normal) FilePriorityLevel priority,
    @Default(false) bool completed,
  }) = _TorrentFileInfo;

  factory TorrentFileInfo.fromJson(Map<String, dynamic> json) =>
      _$TorrentFileInfoFromJson(json);

  double get progress => size == 0 ? 0 : downloaded / size;
  String get progressPercentage => '${(progress * 100).toStringAsFixed(1)}%';
}

/// Tracker information
@Freezed(equal: true, toStringOverride: true)
sealed class TrackerInfo with _$TrackerInfo {
  const TrackerInfo._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TrackerInfo({
    required String url,
    @Default(TrackerStatus.unknown) TrackerStatus status,
    @Default(0) int seeders,
    @Default(0) int leechers,
    String? errorMessage,
    @Default(false) bool userAdded,
  }) = _TrackerInfo;

  factory TrackerInfo.fromJson(Map<String, dynamic> json) =>
      _$TrackerInfoFromJson(json);
}

/// Model representing a torrent download task
@Freezed(equal: true, toStringOverride: true)
sealed class DownloadTask with _$DownloadTask {
  const DownloadTask._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory DownloadTask({
    required int taskId,
    required int movieId,
    required String movieTitle,
    required String torrentHash,
    required String magnetUri,
    required String quality,
    String? type,
    required String size,
    @Default(0.0) double progress,
    @Default(DownloadStatus.queued) DownloadStatus status,
    @Default(0) int downloadSpeed,
    @Default(0) int uploadSpeed,
    @Default(0) int peers,
    @Default(0) int seeders,
    @Default(0) int downloadedBytes,
    @Default(0) int totalBytes,
    String? filePath,
    String? errorMessage,
    DateTime? startedAt,
    DateTime? completedAt,
    String? coverImage,

    /// Per-task download speed limit in bytes/sec (null = unlimited)
    int? downloadSpeedLimit,

    /// Per-task upload speed limit in bytes/sec (null = unlimited)
    int? uploadSpeedLimit,

    /// File listing (populated after metadata is downloaded)
    @Default(<TorrentFileInfo>[]) List<TorrentFileInfo> files,

    /// Active trackers
    @Default(<TrackerInfo>[]) List<TrackerInfo> trackers,
  }) = _DownloadTask;

  factory DownloadTask.fromJson(Map<String, dynamic> json) =>
      _$DownloadTaskFromJson(json);

  bool get isActive =>
      status == DownloadStatus.downloading ||
      status == DownloadStatus.queued ||
      status == DownloadStatus.downloadingMetadata;

  bool get canResume =>
      status == DownloadStatus.paused ||
      status == DownloadStatus.failed ||
      status == DownloadStatus.stopped;

  bool get canPause =>
      status == DownloadStatus.downloading ||
      status == DownloadStatus.downloadingMetadata;

  String get progressPercentage => '${(progress * 100).toStringAsFixed(1)}%';

  String get formattedDownloadSpeed => '${formatBytes(downloadSpeed)}/s';
  String get formattedUploadSpeed => '${formatBytes(uploadSpeed)}/s';
  String get formattedDownloadedSize => formatBytes(downloadedBytes);
  String get formattedTotalSize => formatBytes(totalBytes);

  String? get formattedDownloadLimit =>
      downloadSpeedLimit == null ? null : '${formatBytes(downloadSpeedLimit!)}/s';
  String? get formattedUploadLimit =>
      uploadSpeedLimit == null ? null : '${formatBytes(uploadSpeedLimit!)}/s';

  /// ETA in seconds, null if unknown / not downloading
  int? get etaSeconds {
    if (downloadSpeed <= 0 || totalBytes <= 0) return null;
    final remaining = totalBytes - downloadedBytes;
    if (remaining <= 0) return 0;
    return remaining ~/ downloadSpeed;
  }

  String get formattedEta {
    final eta = etaSeconds;
    if (eta == null) return '--';
    if (eta < 60) return '${eta}s';
    if (eta < 3600) return '${eta ~/ 60}m ${eta % 60}s';
    if (eta < 86400) return '${eta ~/ 3600}h ${(eta % 3600) ~/ 60}m';
    return '${eta ~/ 86400}d ${(eta % 86400) ~/ 3600}h';
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
