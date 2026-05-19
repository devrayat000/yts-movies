import 'dart:typed_data';

import 'package:b_encode_decode/b_encode_decode.dart';
import 'package:dtorrent_task_v2/dtorrent_task_v2.dart';
import 'package:events_emitter2/src/events_emitter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ytsmovies/src/injection.dart';
import 'package:ytsmovies/src/models/torrent.dart' as m;
import 'package:ytsmovies/src/services/foreground_download_service.dart';

class AdvancedDownloadDialog extends StatefulWidget {
  final m.Torrent torrent;
  final String movieTitle;
  final String magnetUri;
  final VoidCallback? onDownloadStart;

  const AdvancedDownloadDialog({
    super.key,
    required this.torrent,
    required this.movieTitle,
    required this.magnetUri,
    this.onDownloadStart,
  });

  @override
  State<AdvancedDownloadDialog> createState() => _AdvancedDownloadDialogState();
}

class _AdvancedDownloadDialogState extends State<AdvancedDownloadDialog> {
  late String _savePath;
  bool _wifiOnly = false;
  bool _sequentialDownload = true;
  bool _showAdvanced = false;
  double _downloadSpeedLimit = 0; // 0 = MAX
  double _uploadSpeedLimit = 0; // 0 = MAX
  final List<String> _trackers = [];
  MetadataDownloader? _metadataDownloader;
  EventsListener? _metadataListener;
  TorrentModel? _model;
  String? _metadataError;
  double _metadataProgress = 0;
  final Set<int> _selectedIndices = <int>{};

  @override
  void initState() {
    super.initState();
    _savePath = getIt<ForegroundDownloadService>().downloadPath;
    _loadTrackers();
    _loadMetadata();
  }

  @override
  void dispose() {
    _metadataListener?.dispose();
    _metadataDownloader?.stop();
    super.dispose();
  }

  void _loadTrackers() {
    // Parse trackers from magnet URI
    final uri = Uri.parse(widget.magnetUri);
    final trParams = uri.queryParametersAll['tr'] ?? [];
    _trackers.addAll(trParams);
  }

  void _loadMetadata() {
    final magnet = MagnetParser.parse(widget.magnetUri);
    if (magnet == null) {
      setState(() => _metadataError = 'Invalid magnet link');
      return;
    }

    final downloader = MetadataDownloader.fromMagnet(widget.magnetUri);
    _metadataDownloader = downloader;
    final listener = downloader.createListener();
    _metadataListener = listener;
    listener
      ..on<MetaDataDownloadProgress>((event) {
        if (!mounted) return;
        setState(() => _metadataProgress = event.progress.toDouble());
      })
      ..on<MetaDataDownloadComplete>((event) {
        try {
          final decoded = decode(Uint8List.fromList(event.data));
          final torrentMap = <String, dynamic>{'info': decoded};
          final model = TorrentParser.parseFromMap(torrentMap);
          if (!mounted) return;
          _selectedIndices
            ..clear()
            ..addAll(List<int>.generate(model.files.length, (i) => i));
          setState(() {
            _model = model;
            _metadataError = null;
            _metadataProgress = 1;
          });
        } catch (e) {
          if (!mounted) return;
          setState(() => _metadataError = 'Failed to parse metadata');
        }
      })
      ..on<MetaDataDownloadFailed>((event) {
        if (!mounted) return;
        setState(() => _metadataError = event.error);
      });
    downloader.startDownload();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.download_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Download File!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Magnet Link
                  _buildSection(
                    'Link:',
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.magnetUri,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontSize: 10,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () {
                            // Copy to clipboard
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Magnet link copied'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, size: 20),
                          onPressed: () {
                            // Share magnet link
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Save As
                  _buildSection(
                    'Save as:',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.movieTitle} [${widget.torrent.quality}] ${widget.torrent.type?.toUpperCase() ?? ""}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Extension',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // File Info
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          'Files: ${_model?.files.length ?? '--'}',
                          icon: Icons.folder_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          'Size: ${_formatBytes(_totalSize())}',
                          icon: Icons.storage_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_metadataError != null) ...[
                    Text(
                      _metadataError!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _retryMetadata,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry metadata'),
                    ),
                    const SizedBox(height: 12),
                  ] else if (_model == null) ...[
                    Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Loading metadata ${(_metadataProgress * 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    _buildFileSelection(theme),
                    const SizedBox(height: 12),
                  ],

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _editTrackers,
                          child: const Text('EDIT TRACKERS'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Storage Path
                  _buildSection(
                    'Storage:',
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 20,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatStorageInfo(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _savePath,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.folder_open, size: 20),
                          onPressed: _changeSavePath,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Options
                  CheckboxListTile(
                    title: const Text('Wifi only'),
                    value: _wifiOnly,
                    onChanged: (value) =>
                        setState(() => _wifiOnly = value ?? false),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Sequential download'),
                    value: _sequentialDownload,
                    onChanged: (value) =>
                        setState(() => _sequentialDownload = value ?? false),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Advanced Options
                  CheckboxListTile(
                    title: const Text('Advance option'),
                    value: _showAdvanced,
                    onChanged: (value) =>
                        setState(() => _showAdvanced = value ?? false),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),

                  if (_showAdvanced) ...[
                    const Divider(),
                    _buildSpeedLimitSlider(
                      'Download speed limit:',
                      _downloadSpeedLimit,
                      (value) => setState(() => _downloadSpeedLimit = value),
                    ),
                    const SizedBox(height: 12),
                    _buildSpeedLimitSlider(
                      'Upload speed limit:',
                      _uploadSpeedLimit,
                      (value) => setState(() => _uploadSpeedLimit = value),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('CANCEL'),
                  ),
                  FilledButton(
                    onPressed: _model == null ? null : _startDownload,
                    child: const Text('START'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildInfoChip(String label, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedLimitSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ${value == 0 ? "MAX" : "${value.toStringAsFixed(1)}MB/s"}',
          style: theme.textTheme.bodyMedium,
        ),
        Row(
          children: [
            Text(
              _formatSpeed(value),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            Expanded(
              child: Slider(
                value: value,
                min: 0,
                max: 10,
                divisions: 100,
                onChanged: onChanged,
              ),
            ),
            Text(
              'MAX',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatSpeed(double mbPerSecond) {
    if (mbPerSecond == 0) return '0B/s';
    final kbps = mbPerSecond * 1024;
    return '${kbps.toStringAsFixed(1)}KB/s';
  }

  String _formatStorageInfo() {
    // Mock storage info - replace with actual implementation
    return '7.60GB/103.56GB, 7.3% free';
  }

  int _totalSize() {
    final model = _model;
    if (model == null) return 0;
    return model.length ?? model.files.fold<int>(0, (sum, f) => sum + f.length);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  void _retryMetadata() {
    _metadataListener?.dispose();
    _metadataDownloader?.stop();
    setState(() {
      _metadataError = null;
      _metadataProgress = 0;
      _model = null;
      _selectedIndices.clear();
    });
    _loadMetadata();
  }

  Widget _buildFileSelection(ThemeData theme) {
    final model = _model;
    if (model == null) return const SizedBox.shrink();
    final total = model.files.length;
    final selectedCount = _selectedIndices.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$selectedCount / $total selected',
                style: theme.textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIndices
                    ..clear()
                    ..addAll(List<int>.generate(total, (i) => i));
                });
              },
              child: const Text('Select all'),
            ),
            TextButton(
              onPressed: () {
                setState(_selectedIndices.clear);
              },
              child: const Text('Select none'),
            ),
          ],
        ),
        const Divider(height: 1),
        SizedBox(
          height: 220,
          child: ListView.separated(
            itemCount: total,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final file = model.files[index];
              final name = file.path.isEmpty ? file.name : file.path;
              final selected = _selectedIndices.contains(index);
              return CheckboxListTile(
                value: selected,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedIndices.add(index);
                    } else {
                      _selectedIndices.remove(index);
                    }
                  });
                },
                title: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                subtitle: Text(
                  _formatBytes(file.length),
                  style: theme.textTheme.labelSmall,
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _changeSavePath() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      setState(() => _savePath = path);
    }
  }

  Future<void> _editTrackers() async {
    final controller = TextEditingController(text: _trackers.join('\n'));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit trackers(1 per line)'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            maxLines: 10,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              _trackers.clear();
              _trackers.addAll(
                controller.text.split('\n').where((t) => t.isNotEmpty),
              );
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startDownload() {
    final model = _model;
    if (model == null) return;
    final selected = _selectedIndices.toList()..sort();
    widget.onDownloadStart?.call();
    Navigator.of(context).pop({
      'savePath': _savePath,
      'wifiOnly': _wifiOnly,
      'sequentialDownload': _sequentialDownload,
      'downloadSpeedLimit': _downloadSpeedLimit,
      'uploadSpeedLimit': _uploadSpeedLimit,
      'trackers': _trackers,
      'selectedIndices': selected,
    });
  }
}
