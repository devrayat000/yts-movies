import 'package:flutter/material.dart';
import 'package:ytsmovies/src/models/torrent.dart' as m;
import 'package:ytsmovies/src/services/torrent_download_service.dart';
import 'package:file_picker/file_picker.dart';

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

  @override
  void initState() {
    super.initState();
    _savePath = TorrentDownloadService.instance.downloadPath;
    _loadTrackers();
  }

  void _loadTrackers() {
    // Parse trackers from magnet URI
    final uri = Uri.parse(widget.magnetUri);
    final trParams = uri.queryParametersAll['tr'] ?? [];
    _trackers.addAll(trParams);
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
                          'Files: 8/8',
                          icon: Icons.folder_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          'Size: ${widget.torrent.size}',
                          icon: Icons.storage_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _selectFiles,
                          child: const Text('SELECT FILES'),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                    onPressed: _startDownload,
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

  Future<void> _changeSavePath() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      setState(() => _savePath = path);
    }
  }

  Future<void> _selectFiles() async {
    // Show file selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select files!'),
        content: const Text('File selection will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
    widget.onDownloadStart?.call();
    Navigator.of(context).pop({
      'savePath': _savePath,
      'wifiOnly': _wifiOnly,
      'sequentialDownload': _sequentialDownload,
      'downloadSpeedLimit': _downloadSpeedLimit,
      'uploadSpeedLimit': _uploadSpeedLimit,
      'trackers': _trackers,
    });
  }
}
