import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import 'package:ytsmovies/src/services/foreground_download_service.dart';
import 'package:ytsmovies/src/services/preferences_service.dart';
import 'package:ytsmovies/src/utils/storage_permission.dart';
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
  }

  @override
  void dispose() {
    _dlLimitCtrl.dispose();
    _ulLimitCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDownloadLocation() async {
    setState(() => _isLoading = true);
    try {
      if (!await ensurePublicStorageWrite()) {
        if (mounted) await showStoragePermissionDeniedDialog(context);
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

  Future<void> _resetToDefault() async {
    setState(() => _isLoading = true);
    try {
      await _svc.resetToDefaultPath();
      setState(() => _currentPath = _svc.downloadPath);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

          // --- Speed limits (session-wide) ---
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
                      Text('Speed Limits',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Applied engine-wide across every download. Blank = unlimited.',
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
