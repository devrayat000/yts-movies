import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ytsmovies/src/bloc/download_manager/index.dart';
import 'package:ytsmovies/src/injection.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/models/movie.dart';
import 'package:ytsmovies/src/models/torrent.dart' as m;
import 'package:ytsmovies/src/services/foreground_download_service.dart';

/// Full-page pre-download configuration.
///
/// Opens immediately on a quality-button tap and kicks off a preview-mode
/// addDownload — libtorrent fetches metadata in the background isolate while
/// the user picks files, save path, and speed caps. "Start" commits the
/// selection (handler clears preview mode and the engine begins downloading
/// only the chosen files). "Cancel" deletes the preview torrent and any
/// scratch state.
class DownloadConfigPage extends StatefulWidget {
  final m.Torrent torrent;
  final Movie movie;
  final String magnetUri;
  final int taskId;

  const DownloadConfigPage({
    super.key,
    required this.torrent,
    required this.movie,
    required this.magnetUri,
    required this.taskId,
  });

  @override
  State<DownloadConfigPage> createState() => _DownloadConfigPageState();
}

class _DownloadConfigPageState extends State<DownloadConfigPage> {
  late DownloadManagerBloc _bloc;
  late String _savePath;
  final Set<int> _selectedIndices = <int>{};
  bool _initialSelectionApplied = false;
  bool _showAdvanced = false;
  bool _committed = false;
  bool _disposed = false;
  bool _previewStartScheduled = false;

  final TextEditingController _dlCtrl = TextEditingController();
  final TextEditingController _ulCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = context.read<DownloadManagerBloc>();
    _savePath = getIt<ForegroundDownloadService>().downloadPath;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPreview());
  }

  @override
  void dispose() {
    _disposed = true;
    _dlCtrl.dispose();
    _ulCtrl.dispose();
    // Abandon the preview torrent if the user backed out without committing.
    // Use a scheduled flag too — covers the case where _changeSavePath
    // queued a re-add that hasn't fired yet.
    if (!_committed &&
        (_previewStartScheduled ||
            _bloc.state.downloads.containsKey(widget.taskId))) {
      _bloc.add(DownloadManagerDeleteDownload(widget.taskId));
    }
    super.dispose();
  }

  void _startPreview() {
    if (_disposed) return;
    _previewStartScheduled = false;
    if (_bloc.state.downloads.containsKey(widget.taskId)) return;
    final task = DownloadTask(
      taskId: widget.taskId,
      movieId: widget.movie.id,
      movieTitle: widget.movie.title,
      torrentHash: widget.torrent.hash,
      magnetUri: widget.magnetUri,
      quality: widget.torrent.quality,
      type: widget.torrent.type,
      size: widget.torrent.size,
      coverImage: widget.movie.mediumCoverImage,
      filePath: _savePath,
    );
    _bloc.add(DownloadManagerAddDownload(
      task: task,
      selectedIndices: const [],
      previewMode: true,
    ));
  }

  Future<void> _changeSavePath() async {
    final newPath = await FilePicker.platform.getDirectoryPath();
    if (newPath == null || newPath == _savePath) return;
    // libtorrent has no live-move so we drop the current preview and re-add
    // against the new path. Wait for the bloc to drop the entry first —
    // otherwise the re-add's containsKey guard skips silently.
    _bloc.add(DownloadManagerDeleteDownload(widget.taskId));
    _previewStartScheduled = true;
    try {
      await _bloc.stream
          .firstWhere((s) => !s.downloads.containsKey(widget.taskId))
          .timeout(const Duration(seconds: 3));
    } catch (_) {/* fall through; _startPreview will re-check */}
    if (!mounted) return;
    setState(() {
      _savePath = newPath;
      _selectedIndices.clear();
      _initialSelectionApplied = false;
    });
    _startPreview();
  }

  void _start() {
    if (_selectedIndices.isEmpty) return;
    _committed = true;
    _bloc.add(DownloadManagerApplyFileSelection(
      taskId: widget.taskId,
      selectedIndices: _selectedIndices.toList()..sort(),
    ));
    final dl = int.tryParse(_dlCtrl.text.trim());
    final ul = int.tryParse(_ulCtrl.text.trim());
    if (dl != null || ul != null) {
      _bloc.add(DownloadManagerSetSpeedLimit(
        taskId: widget.taskId,
        downloadLimit: dl == null ? null : dl * 1024,
        uploadLimit: ul == null ? null : ul * 1024,
      ));
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Download started'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => context.pushNamed('downloads'),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _cancel() {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<DownloadManagerBloc, DownloadManagerState>(
      buildWhen: (prev, curr) =>
          prev.downloads[widget.taskId] != curr.downloads[widget.taskId],
      listenWhen: (prev, curr) {
        final prevLen = prev.downloads[widget.taskId]?.files.length ?? 0;
        final currLen = curr.downloads[widget.taskId]?.files.length ?? 0;
        return prevLen != currLen;
      },
      listener: (context, state) {
        final task = state.downloads[widget.taskId];
        if (task != null &&
            task.files.isNotEmpty &&
            !_initialSelectionApplied) {
          setState(() {
            _selectedIndices
              ..clear()
              ..addAll(List<int>.generate(task.files.length, (i) => i));
            _initialSelectionApplied = true;
          });
        }
      },
      builder: (context, state) {
        final task = state.downloads[widget.taskId];
        final filesReady = task != null && task.files.isNotEmpty;
        final hasError =
            task != null && task.status == DownloadStatus.failed;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Configure Download'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancel,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _movieCard(theme),
              const SizedBox(height: 16),
              _savePathCard(theme),
              const SizedBox(height: 16),
              if (hasError)
                _errorCard(theme, task.errorMessage ?? 'Unknown error')
              else if (!filesReady)
                _metadataLoadingCard(theme, task)
              else
                _filesCard(theme, task),
              const SizedBox(height: 16),
              _advancedCard(theme),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: filesReady && _selectedIndices.isNotEmpty
                          ? _start
                          : null,
                      icon: const Icon(Icons.download),
                      label: const Text('START'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _movieCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.movie.mediumCoverImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: widget.movie.mediumCoverImage,
                  width: 70,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.torrent.quality}'
                    '${widget.torrent.type != null ? " ${widget.torrent.type!.toUpperCase()}" : ""}'
                    ' • ${widget.torrent.size}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.magnetUri,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _savePathCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Save to',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.folder, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _savePath,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: _changeSavePath,
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('Change'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metadataLoadingCard(ThemeData theme, DownloadTask? task) {
    final progress = task?.progress ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Fetching torrent metadata…',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (progress > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.labelSmall,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'The file list will appear once metadata is downloaded.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(ThemeData theme, String message) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Metadata fetch failed: $message',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filesCard(ThemeData theme, DownloadTask task) {
    final files = task.files;
    final selectedSize = files
        .where((f) => _selectedIndices.contains(f.index))
        .fold<int>(0, (s, f) => s + f.size);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Files (${_selectedIndices.length} / ${files.length})',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndices
                        ..clear()
                        ..addAll(List.generate(files.length, (i) => i));
                    });
                  },
                  child: const Text('All'),
                ),
                TextButton(
                  onPressed: () {
                    setState(_selectedIndices.clear);
                  },
                  child: const Text('None'),
                ),
              ],
            ),
            Text(
              '${DownloadTask.formatBytes(selectedSize)} selected',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: files.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final f = files[i];
                  final selected = _selectedIndices.contains(f.index);
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: selected,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedIndices.add(f.index);
                        } else {
                          _selectedIndices.remove(f.index);
                        }
                      });
                    },
                    title: Text(
                      f.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    subtitle: Text(
                      DownloadTask.formatBytes(f.size),
                      style: theme.textTheme.labelSmall,
                    ),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _advancedCard(ThemeData theme) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Advanced options'),
            subtitle: const Text('Speed limits (session-wide)'),
            trailing: Icon(
              _showAdvanced ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () => setState(() => _showAdvanced = !_showAdvanced),
          ),
          if (_showAdvanced)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'libtorrent_flutter only exposes engine-wide caps. The '
                    'most recent value wins across every active download.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dlCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Download limit (KB/s, blank = unlimited)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ulCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Upload limit (KB/s, blank = unlimited)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
