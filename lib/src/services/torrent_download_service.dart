import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dtorrent_task_v2/dtorrent_task_v2.dart';
import 'package:dtorrent_parser/dtorrent_parser.dart' as parser;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/movie.dart';
import 'package:ytsmovies/src/models/torrent.dart' as models;
import 'package:ytsmovies/src/services/preferences_service.dart';

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
      // Request storage permissions
      await _requestStoragePermissions();

      // Check if user has set a custom download path
      final customPath = PreferencesService.instance.customDownloadPath;

      if (customPath != null && await Directory(customPath).exists()) {
        _downloadPath = customPath;
        log('Using custom download path: $_downloadPath');
      } else {
        // Use default app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        _downloadPath = '${appDir.path}/downloads';
        log('Using default download path: $_downloadPath');
      }

      final appDir = await getApplicationDocumentsDirectory();
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

  /// Request storage permissions
  Future<bool> _requestStoragePermissions() async {
    try {
      if (Platform.isAndroid) {
        // Check Android version
        final androidInfo = await _getAndroidVersion();

        if (androidInfo >= 33) {
          // Android 13+ - Request READ_MEDIA_VIDEO
          final status = await Permission.videos.request();
          if (!status.isGranted) {
            log('Video permission not granted');
            return false;
          }
        } else if (androidInfo >= 30) {
          // Android 11-12 - Request MANAGE_EXTERNAL_STORAGE
          var status = await Permission.manageExternalStorage.status;
          if (!status.isGranted) {
            status = await Permission.manageExternalStorage.request();
          }
          if (!status.isGranted) {
            // Fallback to storage permission
            status = await Permission.storage.request();
          }
          if (!status.isGranted) {
            log('Storage permission not granted');
            return false;
          }
        } else {
          // Android 10 and below - Request WRITE_EXTERNAL_STORAGE
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            log('Storage permission not granted');
            return false;
          }
        }
      } else if (Platform.isIOS) {
        // iOS - Request photo library access
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          log('Photos permission not granted on iOS');
          return false;
        }
      }

      log('Storage permissions granted');
      return true;
    } catch (e, s) {
      log('Error requesting permissions: $e', error: e, stackTrace: s);
      return false;
    }
  }

  /// Get Android SDK version
  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      // This is a simple way to check - in production you might want to use
      // device_info_plus package for more reliable version checking
      return 33; // Default to recent version - update this logic as needed
    } catch (e) {
      return 30;
    }
  }

  /// Update download path (called when user selects custom directory)
  Future<void> updateDownloadPath(String newPath) async {
    try {
      // Validate the path
      final dir = Directory(newPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Save to preferences
      await PreferencesService.instance.setCustomDownloadPath(newPath);

      // Update current path
      _downloadPath = newPath;

      log('Download path updated to: $newPath');
    } catch (e, s) {
      log('Error updating download path: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Reset to default download path
  Future<void> resetToDefaultPath() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final defaultPath = '${appDir.path}/downloads';

      await PreferencesService.instance.setCustomDownloadPath(null);
      _downloadPath = defaultPath;

      await Directory(_downloadPath).create(recursive: true);

      log('Download path reset to default: $defaultPath');
    } catch (e, s) {
      log('Error resetting download path: $e', error: e, stackTrace: s);
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
