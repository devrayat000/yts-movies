import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ytsmovies/src/bloc/download_manager/index.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/pages/download_settings.dart';
import 'package:ytsmovies/src/pages/download_details.dart';
import 'package:ytsmovies/src/services/foreground_download_service.dart';
import 'package:ytsmovies/src/injection.dart';
import 'package:open_file_manager/open_file_manager.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DownloadSettingsPage(),
                ),
              );
            },
            tooltip: 'Download settings',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              context.read<DownloadManagerBloc>().add(
                    DownloadManagerClearCompleted(),
                  );
            },
            tooltip: 'Clear completed downloads',
          ),
        ],
      ),
      body: BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
        builder: (context, state) {
          if (state.allDownloads.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.download_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No downloads yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              if (state.activeDownloads.isNotEmpty) ...[
                _SectionHeader(
                    title: 'Active (${state.activeDownloads.length})'),
                ...state.activeDownloads
                    .map((task) => _DownloadTaskCard(task: task)),
                const SizedBox(height: 16),
              ],
              if (state.pausedDownloads.isNotEmpty) ...[
                _SectionHeader(
                    title: 'Paused (${state.pausedDownloads.length})'),
                ...state.pausedDownloads
                    .map((task) => _DownloadTaskCard(task: task)),
                const SizedBox(height: 16),
              ],
              if (state.completedDownloads.isNotEmpty) ...[
                _SectionHeader(
                    title: 'Completed (${state.completedDownloads.length})'),
                ...state.completedDownloads
                    .map((task) => _DownloadTaskCard(task: task)),
                const SizedBox(height: 16),
              ],
              if (state.failedDownloads.isNotEmpty) ...[
                _SectionHeader(
                    title: 'Failed (${state.failedDownloads.length})'),
                ...state.failedDownloads
                    .map((task) => _DownloadTaskCard(task: task)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _DownloadTaskCard extends StatelessWidget {
  final DownloadTask task;

  const _DownloadTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () => _onCardTap(context),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie cover image
              if (task.coverImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: task.coverImage!,
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 90,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 90,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              // Download info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.movieTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${task.quality}${task.type != null ? ' ${task.type!.toUpperCase()}' : ''} • ${task.size}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    if (task.status == DownloadStatus.downloading ||
                        task.status == DownloadStatus.paused) ...[
                      LinearProgressIndicator(
                        value: task.progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          task.status == DownloadStatus.paused
                              ? Colors.orange
                              : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            task.progressPercentage,
                            style: theme.textTheme.bodySmall,
                          ),
                          if (task.status == DownloadStatus.downloading)
                            Text(
                              '${task.formattedDownloadSpeed} ↓ ${task.formattedUploadSpeed} ↑',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                      if (task.peers > 0 || task.seeders > 0)
                        Text(
                          'Peers: ${task.peers} • Seeders: ${task.seeders}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                    if (task.status == DownloadStatus.completed) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (task.status == DownloadStatus.failed) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.error,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              task.errorMessage ?? 'Download failed',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Action buttons
              _DownloadActionsMenu(task: task),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCardTap(BuildContext context) async {
    // If downloading or paused, navigate to details page
    if (task.status == DownloadStatus.downloading ||
        task.status == DownloadStatus.paused ||
        task.status == DownloadStatus.downloadingMetadata ||
        task.status == DownloadStatus.queued) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DownloadDetailsPage(taskId: task.taskId),
        ),
      );
    }
    // If completed, open the file location
    else if (task.status == DownloadStatus.completed) {
      await _openDownloadLocation(context);
    }
  }

  Future<void> _openDownloadLocation(BuildContext context) async {
    try {
      final downloadService = getIt<ForegroundDownloadService>();
      final downloadPath = downloadService.downloadPath;

      // Get the directory where the file is located
      final directory = Directory(downloadPath);

      if (!await directory.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download directory not found'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Try to find the movie file
      await openFileManager(
        androidConfig: AndroidConfig(
          folderType: AndroidFolderType.other,
          folderPath: downloadPath,
        ),
        iosConfig: IosConfig(
          folderPath: downloadPath,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class _DownloadActionsMenu extends StatelessWidget {
  final DownloadTask task;

  const _DownloadActionsMenu({required this.task});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        final bloc = context.read<DownloadManagerBloc>();
        switch (value) {
          case 'pause':
            bloc.add(DownloadManagerPauseDownload(task.taskId));
            break;
          case 'resume':
            bloc.add(DownloadManagerResumeDownload(task.taskId));
            break;
          case 'stop':
            bloc.add(DownloadManagerStopDownload(task.taskId));
            break;
          case 'delete':
            _showDeleteConfirmation(context, bloc);
            break;
        }
      },
      itemBuilder: (context) {
        return [
          if (task.canPause)
            const PopupMenuItem(
              value: 'pause',
              child: Row(
                children: [
                  Icon(Icons.pause),
                  SizedBox(width: 8),
                  Text('Pause'),
                ],
              ),
            ),
          if (task.canResume)
            const PopupMenuItem(
              value: 'resume',
              child: Row(
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Resume'),
                ],
              ),
            ),
          if (task.isActive)
            const PopupMenuItem(
              value: 'stop',
              child: Row(
                children: [
                  Icon(Icons.stop),
                  SizedBox(width: 8),
                  Text('Stop'),
                ],
              ),
            ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ];
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, DownloadManagerBloc bloc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Download'),
        content: const Text(
          'Are you sure you want to delete this download? This will also remove downloaded files.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              bloc.add(DownloadManagerDeleteDownload(task.taskId));
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
