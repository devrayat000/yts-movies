part of 'download_manager_bloc.dart';

/// State for download manager
class DownloadManagerState {
  final Map<int, DownloadTask> downloads;

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
    Map<int, DownloadTask>? downloads,
  }) {
    return DownloadManagerState(
      downloads: downloads ?? this.downloads,
    );
  }

  /// Serialize to JSON.
  ///
  /// JSON object keys must be strings, so int taskIds are stringified here
  /// and parsed back in [fromJson]. Storing them as int keys silently
  /// produces an empty map on rehydrate (the cast in fromJson fails).
  Map<String, dynamic> toJson() {
    return {
      'downloads': {
        for (final e in downloads.entries) e.key.toString(): e.value.toJson(),
      },
    };
  }

  factory DownloadManagerState.fromJson(Map<String, dynamic> json) {
    final raw = (json['downloads'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return DownloadManagerState(
      downloads: {
        for (final e in raw.entries)
          int.parse(e.key):
              DownloadTask.fromJson((e.value as Map).cast<String, dynamic>()),
      },
    );
  }
}
