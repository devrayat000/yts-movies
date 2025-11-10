import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_task.g.dart';
part 'download_task.freezed.dart';

/// Download status enumeration
enum DownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  stopped,
}

/// Model representing a torrent download task
@Freezed(equal: true, toStringOverride: true)
sealed class DownloadTask with _$DownloadTask {
  const DownloadTask._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory DownloadTask({
    /// Unique task identifier
    required int taskId,

    /// Movie ID from YTS
    required int movieId,

    /// Movie title
    required String movieTitle,

    /// Torrent hash
    required String torrentHash,

    /// Torrent magnet link
    required String magnetUri,

    /// Quality (e.g., "720p", "1080p")
    required String quality,

    /// File type (e.g., "web", "bluray")
    String? type,

    /// File size
    required String size,

    /// Download progress (0.0 to 1.0)
    @Default(0.0) double progress,

    /// Download status
    @Default(DownloadStatus.queued) DownloadStatus status,

    /// Download speed in bytes per second
    @Default(0) int downloadSpeed,

    /// Upload speed in bytes per second
    @Default(0) int uploadSpeed,

    /// Number of peers
    @Default(0) int peers,

    /// Number of seeders
    @Default(0) int seeders,

    /// Downloaded bytes
    @Default(0) int downloadedBytes,

    /// Total bytes
    @Default(0) int totalBytes,

    /// File path where the download is saved
    String? filePath,

    /// Error message if download failed
    String? errorMessage,

    /// Time when download was started
    DateTime? startedAt,

    /// Time when download was completed
    DateTime? completedAt,

    /// Movie cover image URL
    String? coverImage,
  }) = _DownloadTask;

  factory DownloadTask.fromJson(Map<String, dynamic> json) =>
      _$DownloadTaskFromJson(json);

  /// Check if download is active
  bool get isActive =>
      status == DownloadStatus.downloading || status == DownloadStatus.queued;

  /// Check if download can be resumed
  bool get canResume =>
      status == DownloadStatus.paused ||
      status == DownloadStatus.failed ||
      status == DownloadStatus.stopped;

  /// Check if download can be paused
  bool get canPause => status == DownloadStatus.downloading;

  /// Get formatted progress percentage
  String get progressPercentage => '${(progress * 100).toStringAsFixed(1)}%';

  /// Get formatted download speed
  String get formattedDownloadSpeed => _formatBytes(downloadSpeed) + '/s';

  /// Get formatted upload speed
  String get formattedUploadSpeed => _formatBytes(uploadSpeed) + '/s';

  /// Get formatted downloaded size
  String get formattedDownloadedSize => _formatBytes(downloadedBytes);

  /// Get formatted total size
  String get formattedTotalSize => _formatBytes(totalBytes);

  /// Format bytes to human readable format
  static String _formatBytes(int bytes) {
    bytes = bytes * 1000;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
