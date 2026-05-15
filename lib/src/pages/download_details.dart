import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ytsmovies/src/bloc/download_manager/index.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Page to show detailed information about a download
class DownloadDetailsPage extends StatelessWidget {
  final int taskId;

  const DownloadDetailsPage({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Details'),
      ),
      body: BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
        builder: (context, state) {
          final task = state.downloads[taskId];

          if (task == null) {
            return const Center(
              child: Text('Download not found'),
            );
          }

          return _DownloadDetailsContent(task: task);
        },
      ),
    );
  }
}

class _DownloadDetailsContent extends StatelessWidget {
  final DownloadTask task;

  const _DownloadDetailsContent({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie poster and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.coverImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: task.coverImage!,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.movieTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${task.quality}${task.type != null ? ' ${task.type!.toUpperCase()}' : ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Size: ${task.size}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status card
          _StatusCard(task: task),
          const SizedBox(height: 16),

          // Progress section (only for active downloads)
          if (task.status == DownloadStatus.downloading ||
              task.status == DownloadStatus.paused) ...[
            _ProgressSection(task: task),
            const SizedBox(height: 16),
          ],

          // Download statistics
          _StatisticsCard(task: task),
          const SizedBox(height: 16),

          // Action buttons
          _ActionButtons(task: task),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final DownloadTask task;

  const _StatusCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color, statusText) = _getStatusInfo();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    statusText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color, String) _getStatusInfo() {
    switch (task.status) {
      case DownloadStatus.queued:
        return (Icons.queue, Colors.orange, 'Queued');
      case DownloadStatus.downloadingMetadata:
        return (Icons.download, Colors.blue, 'Downloading Metadata');
      case DownloadStatus.downloading:
        return (Icons.download, Colors.green, 'Downloading');
      case DownloadStatus.paused:
        return (Icons.pause_circle, Colors.orange, 'Paused');
      case DownloadStatus.completed:
        return (Icons.check_circle, Colors.green, 'Completed');
      case DownloadStatus.failed:
        return (Icons.error, Colors.red, 'Failed');
      case DownloadStatus.stopped:
        return (Icons.stop_circle, Colors.grey, 'Stopped');
    }
  }
}

class _ProgressSection extends StatelessWidget {
  final DownloadTask task;

  const _ProgressSection({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Progress bar
            LinearProgressIndicator(
              value: task.progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                task.status == DownloadStatus.paused
                    ? Colors.orange
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            // Progress percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.progressPercentage,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${task.formattedDownloadedSize} / ${task.formattedTotalSize}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Speed information
            if (task.status == DownloadStatus.downloading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SpeedIndicator(
                    label: 'Download',
                    speed: task.formattedDownloadSpeed,
                    icon: Icons.arrow_downward,
                    color: Colors.green,
                  ),
                  _SpeedIndicator(
                    label: 'Upload',
                    speed: task.formattedUploadSpeed,
                    icon: Icons.arrow_upward,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpeedIndicator extends StatelessWidget {
  final String label;
  final String speed;
  final IconData icon;
  final Color color;

  const _SpeedIndicator({
    required this.label,
    required this.speed,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              speed,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  final DownloadTask task;

  const _StatisticsCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _StatRow(
              label: 'Peers',
              value: task.peers.toString(),
              icon: Icons.people,
            ),
            const SizedBox(height: 8),
            _StatRow(
              label: 'Seeders',
              value: task.seeders.toString(),
              icon: Icons.cloud_upload,
            ),
            const SizedBox(height: 8),
            _StatRow(
              label: 'Hash',
              value: task.torrentHash,
              icon: Icons.tag,
              monospace: true,
            ),
            if (task.startedAt != null) ...[
              const SizedBox(height: 8),
              _StatRow(
                label: 'Started',
                value: _formatDateTime(task.startedAt!),
                icon: Icons.schedule,
              ),
            ],
            if (task.completedAt != null) ...[
              const SizedBox(height: 8),
              _StatRow(
                label: 'Completed',
                value: _formatDateTime(task.completedAt!),
                icon: Icons.check_circle,
              ),
            ],
            if (task.errorMessage != null) ...[
              const SizedBox(height: 8),
              _StatRow(
                label: 'Error',
                value: task.errorMessage!,
                icon: Icons.error,
                valueColor: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool monospace;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.monospace = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: monospace ? 'monospace' : null,
                  fontSize: monospace ? 10 : null,
                  color: valueColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final DownloadTask task;

  const _ActionButtons({required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (task.canPause)
          FilledButton.icon(
            onPressed: () {
              context
                  .read<DownloadManagerBloc>()
                  .add(DownloadManagerPauseDownload(task.taskId));
            },
            icon: const Icon(Icons.pause),
            label: const Text('Pause Download'),
          ),
        if (task.canResume)
          FilledButton.icon(
            onPressed: () {
              context
                  .read<DownloadManagerBloc>()
                  .add(DownloadManagerResumeDownload(task.taskId));
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume Download'),
          ),
        if (task.isActive) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              context
                  .read<DownloadManagerBloc>()
                  .add(DownloadManagerStopDownload(task.taskId));
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.stop),
            label: const Text('Stop Download'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}
