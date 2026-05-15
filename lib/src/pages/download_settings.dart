import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ytsmovies/src/services/foreground_download_service.dart';
import 'package:ytsmovies/src/services/preferences_service.dart';
import 'package:ytsmovies/src/injection.dart';

class DownloadSettingsPage extends StatefulWidget {
  const DownloadSettingsPage({super.key});

  @override
  State<DownloadSettingsPage> createState() => _DownloadSettingsPageState();
}

class _DownloadSettingsPageState extends State<DownloadSettingsPage> {
  String? _currentPath;
  bool _isLoading = false;

  late final TextEditingController _dlLimitCtrl;
  late final TextEditingController _ulLimitCtrl;
  late int _maxConcurrent;
  late List<String> _defaultTrackers;

  ForegroundDownloadService get _svc => getIt<ForegroundDownloadService>();
  PreferencesService get _prefs => getIt<PreferencesService>();

  @override
  void initState() {
    super.initState();
    _currentPath = _svc.downloadPath;
    _dlLimitCtrl = TextEditingController(
      text: _prefs.globalDownloadLimit == null
          ? ''
          : (_prefs.globalDownloadLimit! / 1024).toStringAsFixed(0),
    );
    _ulLimitCtrl = TextEditingController(
      text: _prefs.globalUploadLimit == null
          ? ''
          : (_prefs.globalUploadLimit! / 1024).toStringAsFixed(0),
    );
    _maxConcurrent = _prefs.maxConcurrentDownloads;
    _defaultTrackers = List.of(_prefs.defaultTrackers);
  }

  @override
  void dispose() {
    _dlLimitCtrl.dispose();
    _ulLimitCtrl.dispose();
    super.dispose();
  }

  // ---- Location ----
  Future<void> _selectDownloadLocation() async {
    setState(() => _isLoading = true);
    try {
      if (!await _requestPermissions()) {
        if (mounted) _showPermissionDeniedDialog();
        return;
      }
      final selected = await FilePicker.platform.getDirectoryPath();
      if (selected != null) {
        await _svc.updateDownloadPath(selected);
        setState(() => _currentPath = selected);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download location updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isDenied) {
        final status = await Permission.manageExternalStorage.request();
        if (status.isDenied) {
          return (await Permission.storage.request()).isGranted;
        }
        return status.isGranted;
      }
      return true;
    } else if (Platform.isIOS) {
      return (await Permission.photos.request()).isGranted;
    }
    return true;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Storage permission is required to choose a download location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetToDefault() async {
    setState(() => _isLoading = true);
    try {
      await _svc.resetToDefaultPath();
      setState(() => _currentPath = _svc.downloadPath);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---- Speed limits ----
  Future<void> _applyGlobalLimits() async {
    final dl = int.tryParse(_dlLimitCtrl.text.trim());
    final ul = int.tryParse(_ulLimitCtrl.text.trim());
    await _prefs.setGlobalDownloadLimit(dl == null ? null : dl * 1024);
    await _prefs.setGlobalUploadLimit(ul == null ? null : ul * 1024);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Global limits saved (applied to new downloads)')),
      );
    }
  }

  // ---- Concurrency ----
  Future<void> _setMaxConcurrent(int value) async {
    setState(() => _maxConcurrent = value);
    await _svc.setMaxConcurrent(value);
  }

  // ---- Default trackers ----
  Future<void> _addDefaultTracker() async {
    final ctrl = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add default tracker'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Tracker URL',
            hintText: 'udp://tracker.opentrackr.org:1337/announce',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (url != null && url.isNotEmpty) {
      await _prefs.addDefaultTracker(url);
      setState(() => _defaultTrackers = List.of(_prefs.defaultTrackers));
    }
  }

  Future<void> _removeDefaultTracker(String url) async {
    await _prefs.removeDefaultTracker(url);
    setState(() => _defaultTrackers = List.of(_prefs.defaultTrackers));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customPath = _prefs.customDownloadPath;
    final isCustom = customPath != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Download Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Location ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.folder, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Download Location',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _currentPath ?? 'Loading...',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontFamily: 'monospace'),
                            ),
                          ),
                          if (isCustom)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Custom',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _isLoading ? null : _selectDownloadLocation,
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Change Location'),
                          ),
                        ),
                        if (isCustom) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _resetToDefault,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Speed limits ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Global Speed Limits',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Applied to new downloads. Blank = unlimited.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dlLimitCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Download limit (KB/s)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ulLimitCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Upload limit (KB/s)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _applyGlobalLimits,
                      icon: const Icon(Icons.save),
                      label: const Text('Save limits'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Concurrency ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.layers, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Max Concurrent Downloads',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _maxConcurrent.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: '$_maxConcurrent',
                          onChanged: (v) =>
                              setState(() => _maxConcurrent = v.toInt()),
                          onChangeEnd: (v) => _setMaxConcurrent(v.toInt()),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text('$_maxConcurrent',
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Default trackers ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dns, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Default Trackers',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addDefaultTracker,
                        tooltip: 'Add tracker',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Applied to every new download in addition to the magnet trackers.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  if (_defaultTrackers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No default trackers configured.'),
                    )
                  else
                    ..._defaultTrackers.map((url) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.link, size: 18),
                          title: Text(
                            url,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeDefaultTracker(url),
                          ),
                        )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Permissions hint ---
          Card(
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Storage Permissions'),
              subtitle: const Text('Required to save downloads'),
              trailing: TextButton(
                onPressed: openAppSettings,
                child: const Text('Manage'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
