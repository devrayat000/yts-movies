import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dtorrent_task_v2/dtorrent_task_v2.dart';
import 'package:dtorrent_parser/dtorrent_parser.dart' as parser;
import 'package:path_provider/path_provider.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/movie.dart';
import 'package:ytsmovies/src/models/torrent.dart' as models;

/// Service to manage torrent downloads using dtorrent_task_v2
class TorrentDownloadService {
  static TorrentDownloadService? _instance;
  static TorrentDownloadService get instance =>
      _instance ?? (throw StateError('TorrentDownloadService not initialized'));

  late final String _downloadPath;
  late final String _configPath;
  final Map<String, TorrentTask> _activeTasks = {};
  final StreamController<DownloadTask> _progressController =
      StreamController<DownloadTask>.broadcast();

  /// Stream of download progress updates
  Stream<DownloadTask> get progressStream => _progressController.stream;

  TorrentDownloadService._();

  /// Initialize the service
  static Future<TorrentDownloadService> initialize() async {
    if (_instance != null) return _instance!;

    final service = TorrentDownloadService._();
    await service._initPaths();
    _instance = service;
    return service;
  }

  /// Initialize download and config paths
  Future<void> _initPaths() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _downloadPath = '${appDir.path}/downloads';
      _configPath = '${appDir.path}/torrent_config';

      // Create directories if they don't exist
      await Directory(_downloadPath).create(recursive: true);
      await Directory(_configPath).create(recursive: true);

      log('Download path: $_downloadPath');
      log('Config path: $_configPath');
    } catch (e, s) {
      log('Error initializing paths: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Start a new download
  Future<DownloadTask> startDownload({
    required Movie movie,
    required models.Torrent torrent,
  }) async {
    try {
      final taskId = '${movie.id}_${torrent.hash}';
      final magnetUri = torrent.magnet(movie.title);

      log('Starting download for: ${movie.title} [${torrent.quality}]');
      log('Magnet URI: $magnetUri');

      // Create download task model
      final downloadTask = DownloadTask(
        taskId: taskId,
        movieId: movie.id,
        movieTitle: movie.title,
        torrentHash: torrent.hash,
        magnetUri: magnetUri.toString(),
        quality: torrent.quality,
        type: torrent.type,
        size: torrent.size,
        status: DownloadStatus.queued,
        startedAt: DateTime.now(),
        coverImage: movie.mediumCoverImage,
      );

      // Parse torrent from magnet URI
      final parsedTorrent = await parser.Torrent.parse(magnetUri.toString());

      // Create torrent task
      final torrentTask = TorrentTask.newTask(
        parsedTorrent,
        _downloadPath,
      );

      // Start the download
      torrentTask.start();

      // Store active task
      _activeTasks[taskId] = torrentTask;

      // Listen to progress updates
      _listenToTask(taskId, torrentTask, downloadTask);

      log('Download started successfully for task: $taskId');
      return downloadTask.copyWith(status: DownloadStatus.downloading);
    } catch (e, s) {
      log('Error starting download: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Listen to task progress and emit updates
  void _listenToTask(
    String taskId,
    TorrentTask torrentTask,
    DownloadTask downloadTask,
  ) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_activeTasks.containsKey(taskId)) {
        timer.cancel();
        return;
      }

      try {
        final progress = torrentTask.progress;
        final downloadSpeed = torrentTask.currentDownloadSpeed.toInt();
        final uploadSpeed = torrentTask.uploadSpeed.toInt();
        final allPeers = torrentTask.connectedPeersNumber;
        final seeders = torrentTask.seederNumber;
        final downloaded = torrentTask.downloaded ?? 0;

        // Determine status based on task state and progress
        DownloadStatus status = downloadTask.status;
        if (progress >= 1.0) {
          status = DownloadStatus.completed;
          timer.cancel();
          _activeTasks.remove(taskId);
        } else if (downloadSpeed == 0 && uploadSpeed == 0 && progress > 0) {
          // If no activity and has some progress, consider it paused
          status = DownloadStatus.paused;
        } else if (progress > 0) {
          status = DownloadStatus.downloading;
        }

        final updatedTask = downloadTask.copyWith(
          progress: progress,
          status: status,
          downloadSpeed: downloadSpeed,
          uploadSpeed: uploadSpeed,
          peers: allPeers,
          seeders: seeders,
          downloadedBytes: downloaded.toInt(),
          totalBytes: downloaded > 0 && progress > 0
              ? (downloaded / progress).toInt()
              : 0,
          completedAt:
              status == DownloadStatus.completed ? DateTime.now() : null,
        );

        _progressController.add(updatedTask);
      } catch (e, s) {
        log('Error updating task progress: $e', error: e, stackTrace: s);
      }
    });
  }

  /// Pause a download
  Future<void> pauseDownload(String taskId) async {
    try {
      final task = _activeTasks[taskId];
      if (task != null) {
        task.pause();
        log('Download paused: $taskId');
      }
    } catch (e, s) {
      log('Error pausing download: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Resume a download
  Future<void> resumeDownload(String taskId, String magnetUri) async {
    try {
      var task = _activeTasks[taskId];
      if (task == null) {
        // Recreate task if not in active tasks
        final parsedTorrent = await parser.Torrent.parse(magnetUri);
        task = TorrentTask.newTask(parsedTorrent, _downloadPath);
        _activeTasks[taskId] = task;
      }
      task.start();
      log('Download resumed: $taskId');
    } catch (e, s) {
      log('Error resuming download: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Stop a download
  Future<void> stopDownload(String taskId) async {
    try {
      final task = _activeTasks[taskId];
      if (task != null) {
        task.stop();
        _activeTasks.remove(taskId);
        log('Download stopped: $taskId');
      }
    } catch (e, s) {
      log('Error stopping download: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Delete a download and its files
  Future<void> deleteDownload(String taskId, String? filePath) async {
    try {
      // Stop the download first
      await stopDownload(taskId);

      // Delete the files if they exist
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          log('Deleted download file: $filePath');
        }
      }
    } catch (e, s) {
      log('Error deleting download: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Get all active tasks
  Map<String, TorrentTask> get activeTasks => Map.unmodifiable(_activeTasks);

  /// Check if a task is active
  bool isTaskActive(String taskId) => _activeTasks.containsKey(taskId);

  /// Get download path
  String get downloadPath => _downloadPath;

  /// Dispose the service
  Future<void> dispose() async {
    // Stop all active downloads
    for (final entry in _activeTasks.entries) {
      try {
        entry.value.stop();
      } catch (e) {
        log('Error stopping task ${entry.key}: $e');
      }
    }
    _activeTasks.clear();
    await _progressController.close();
    _instance = null;
  }
}
