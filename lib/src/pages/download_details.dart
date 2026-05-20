import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ytsmovies/src/bloc/download_manager/index.dart';
import 'package:ytsmovies/src/models/download_task.dart';

class DownloadDetailsPage extends StatelessWidget {
  final int taskId;

  const DownloadDetailsPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Download Details'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
              Tab(icon: Icon(Icons.folder_open), text: 'Files'),
              Tab(icon: Icon(Icons.tune), text: 'Storage'),
            ],
          ),
        ),
        body: BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
          builder: (context, state) {
            final task = state.downloads[taskId];
            if (task == null) {
              return const Center(child: Text('Download not found'));
            }
            return TabBarView(
              children: [
                _OverviewTab(task: task),
                _FilesTab(task: task),
                _StorageTab(task: task),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// Overview tab
// ============================================================
class _OverviewTab extends StatelessWidget {
  final DownloadTask task;
  const _OverviewTab({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    placeholder: (_, __) => Container(
                      width: 100,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => Container(
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
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${task.quality}'
                      '${task.type != null ? ' ${task.type!.toUpperCase()}' : ''}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text('Size: ${task.size}',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _StatusCard(task: task),
          const SizedBox(height: 16),
          if (task.status == DownloadStatus.downloading ||
              task.status == DownloadStatus.paused ||
              task.status == DownloadStatus.downloadingMetadata) ...[
            _ProgressSection(task: task),
            const SizedBox(height: 16),
          ],
          _StatisticsCard(task: task),
          const SizedBox(height: 16),
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
    final (icon, color, statusText) = _statusInfo(task.status);
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
                  Text('Status',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.grey[600])),
                  Text(statusText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (IconData, Color, String) _statusInfo(DownloadStatus s) {
    switch (s) {
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
            Text('Progress',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: task.progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                task.status == DownloadStatus.paused
                    ? Colors.orange
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.progressPercentage,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  '${task.formattedDownloadedSize} / ${task.formattedTotalSize}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (task.status == DownloadStatus.downloading)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SpeedIndicator(
                    label: 'Down',
                    speed: task.formattedDownloadSpeed,
                    icon: Icons.arrow_downward,
                    color: Colors.green,
                  ),
                  _SpeedIndicator(
                    label: 'Up',
                    speed: task.formattedUploadSpeed,
                    icon: Icons.arrow_upward,
                    color: Colors.blue,
                  ),
                  Column(
                    children: [
                      Text('ETA',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: Colors.grey[600])),
                      Text(task.formattedEta,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ],
              ),
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
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: Colors.grey[600])),
            Text(speed,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                )),
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
            Text('Statistics',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
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
            if (task.startedAt != null) ...[
              const SizedBox(height: 8),
              _StatRow(
                label: 'Started',
                value: _fmtDate(task.startedAt!),
                icon: Icons.schedule,
              ),
            ],
            if (task.completedAt != null) ...[
              const SizedBox(height: 8),
              _StatRow(
                label: 'Completed',
                value: _fmtDate(task.completedAt!),
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

  static String _fmtDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
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
              Text(label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: Colors.grey[600])),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(color: valueColor),
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
            onPressed: () => context
                .read<DownloadManagerBloc>()
                .add(DownloadManagerPauseDownload(task.taskId)),
            icon: const Icon(Icons.pause),
            label: const Text('Pause'),
          ),
        if (task.canResume)
          FilledButton.icon(
            onPressed: () => context
                .read<DownloadManagerBloc>()
                .add(DownloadManagerResumeDownload(task.taskId)),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume'),
          ),
        if (task.isActive || task.status == DownloadStatus.paused) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              context
                  .read<DownloadManagerBloc>()
                  .add(DownloadManagerStopDownload(task.taskId));
            },
            icon: const Icon(Icons.stop),
            label: const Text('Stop'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ],
    );
  }
}

// ============================================================
// Files tab — include / skip only. libtorrent supports four priority
// levels but they're noise for end users; collapse to a checkbox.
// ============================================================
class _FilesTab extends StatelessWidget {
  final DownloadTask task;
  const _FilesTab({required this.task});

  @override
  Widget build(BuildContext context) {
    if (task.files.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'File list will appear once metadata has been downloaded.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${task.files.length} files • '
                  '${task.files.where((f) => f.priority != FilePriorityLevel.skip).length} selected',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              TextButton.icon(
                onPressed: () => _setAll(context, FilePriorityLevel.normal),
                icon: const Icon(Icons.done_all, size: 16),
                label: const Text('All'),
              ),
              TextButton.icon(
                onPressed: () => _setAll(context, FilePriorityLevel.skip),
                icon: const Icon(Icons.block, size: 16),
                label: const Text('None'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: task.files.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) =>
                _FileRow(taskId: task.taskId, file: task.files[i]),
          ),
        ),
      ],
    );
  }

  void _setAll(BuildContext context, FilePriorityLevel level) {
    final indices = level == FilePriorityLevel.skip
        ? <int>[]
        : List<int>.generate(task.files.length, (i) => i);
    context.read<DownloadManagerBloc>().add(
          DownloadManagerApplyFileSelection(
            taskId: task.taskId,
            selectedIndices: indices,
          ),
        );
  }
}

class _FileRow extends StatelessWidget {
  final int taskId;
  final TorrentFileInfo file;
  const _FileRow({required this.taskId, required this.file});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = file.priority != FilePriorityLevel.skip;
    return CheckboxListTile(
      value: selected,
      onChanged: (v) {
        context.read<DownloadManagerBloc>().add(
              DownloadManagerSetFilePriority(
                taskId: taskId,
                fileIndex: file.index,
                priority: v == true
                    ? FilePriorityLevel.normal
                    : FilePriorityLevel.skip,
              ),
            );
      },
      title: Text(
        file.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium,
      ),
      // libtorrent_flutter doesn't expose per-file byte progress; surface
      // size and (when known) the Done marker set on torrent completion.
      subtitle: Text(
        '${DownloadTask.formatBytes(file.size)}'
        '${file.completed ? " • Done" : ""}',
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }
}

// ============================================================
// Storage tab — move-on-disk only. Per-task speed caps don't exist in
// libtorrent_flutter (session-wide), so we don't expose them here.
// ============================================================
class _StorageTab extends StatefulWidget {
  final DownloadTask task;
  const _StorageTab({required this.task});

  @override
  State<_StorageTab> createState() => _StorageTabState();
}

class _StorageTabState extends State<_StorageTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Save location',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.task.filePath ?? '—',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Move renames already-written files on disk. In-progress '
                  'downloads keep writing to the original path until stopped.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: widget.task.isActive ? null : _moveDownload,
                  icon: const Icon(Icons.drive_file_move_outline),
                  label: Text(widget.task.isActive
                      ? 'Pause to move'
                      : 'Move to new location'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _moveDownload() async {
    final newPath = await FilePicker.platform.getDirectoryPath();
    if (newPath == null || !mounted) return;
    context.read<DownloadManagerBloc>().add(
          DownloadManagerMoveDownloadTask(
            taskId: widget.task.taskId,
            newSavePath: newPath,
          ),
        );
  }
}
