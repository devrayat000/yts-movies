part of 'download_manager_bloc.dart';

/// State for download manager
class DownloadManagerState {
  final Map<String, DownloadTask> downloads;

  const DownloadManagerState({
    this.downloads = const {},
  });

  /// Get active downloads (downloading or queued)
  List<DownloadTask> get activeDownloads =>
      downloads.values.where((task) => task.isActive).toList()
        ..sort((a, b) => (b.startedAt ?? DateTime.now())
            .compareTo(a.startedAt ?? DateTime.now()));

  /// Get completed downloads
  List<DownloadTask> get completedDownloads => downloads.values
      .where((task) => task.status == DownloadStatus.completed)
      .toList()
    ..sort((a, b) => (b.completedAt ?? DateTime.now())
        .compareTo(a.completedAt ?? DateTime.now()));

  /// Get paused downloads
  List<DownloadTask> get pausedDownloads => downloads.values
      .where((task) => task.status == DownloadStatus.paused)
      .toList()
    ..sort((a, b) => (b.startedAt ?? DateTime.now())
        .compareTo(a.startedAt ?? DateTime.now()));

  /// Get failed downloads
  List<DownloadTask> get failedDownloads => downloads.values
      .where((task) => task.status == DownloadStatus.failed)
      .toList()
    ..sort((a, b) => (b.startedAt ?? DateTime.now())
        .compareTo(a.startedAt ?? DateTime.now()));

  /// Get all downloads as a list
  List<DownloadTask> get allDownloads => downloads.values.toList()
    ..sort((a, b) => (b.startedAt ?? DateTime.now())
        .compareTo(a.startedAt ?? DateTime.now()));

  /// Copy with
  DownloadManagerState copyWith({
    Map<String, DownloadTask>? downloads,
  }) {
    return DownloadManagerState(
      downloads: downloads ?? this.downloads,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'downloads': downloads.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  /// Deserialize from JSON
  factory DownloadManagerState.fromJson(Map<String, dynamic> json) {
    final downloadsMap = (json['downloads'] as Map<String, dynamic>?) ?? {};
    return DownloadManagerState(
      downloads: downloadsMap.map(
        (key, value) => MapEntry(
          key,
          DownloadTask.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }
}
