import 'package:flutter/material.dart';

/// Model for a file in a torrent
class TorrentFileInfo {
  final int index;
  final String name;
  final int size;
  final String formattedSize;
  bool isSelected;

  TorrentFileInfo({
    required this.index,
    required this.name,
    required this.size,
    required this.formattedSize,
    this.isSelected = true,
  });

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// Dialog to select which files to download from a torrent
class FileSelectionDialog extends StatefulWidget {
  final List<TorrentFileInfo> files;
  final String movieTitle;

  const FileSelectionDialog({
    super.key,
    required this.files,
    required this.movieTitle,
  });

  @override
  State<FileSelectionDialog> createState() => _FileSelectionDialogState();
}

class _FileSelectionDialogState extends State<FileSelectionDialog> {
  late List<TorrentFileInfo> _files;
  bool _selectAll = true;

  @override
  void initState() {
    super.initState();
    _files = widget.files;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = _files.where((f) => f.isSelected).length;
    final totalSize = _files
        .where((f) => f.isSelected)
        .fold<int>(0, (sum, file) => sum + file.size);

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
                    Icons.folder_open,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Files',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.movieTitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Selection summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected: $selectedCount / ${_files.length}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total Size: ${TorrentFileInfo.formatBytes(totalSize)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectAll = !_selectAll;
                        for (var file in _files) {
                          file.isSelected = _selectAll;
                        }
                      });
                    },
                    child: Text(_selectAll ? 'Deselect All' : 'Select All'),
                  ),
                ],
              ),
            ),

            // File list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return CheckboxListTile(
                    value: file.isSelected,
                    onChanged: (value) {
                      setState(() {
                        file.isSelected = value ?? false;
                        // Update selectAll state
                        _selectAll =
                            _files.every((f) => f.isSelected);
                      });
                    },
                    title: Text(
                      file.name,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      file.formattedSize,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    secondary: Icon(
                      _getFileIcon(file.name),
                      color: theme.colorScheme.primary,
                    ),
                    dense: true,
                  );
                },
              ),
            ),

            // Bottom actions
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
                    onPressed: selectedCount > 0
                        ? () {
                            final selectedIndices = _files
                                .where((f) => f.isSelected)
                                .map((f) => f.index)
                                .toList();
                            Navigator.of(context).pop(selectedIndices);
                          }
                        : null,
                    child: const Text('CONFIRM'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'mp4':
      case 'mkv':
      case 'avi':
      case 'mov':
      case 'wmv':
        return Icons.movie;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audiotrack;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'txt':
      case 'doc':
      case 'pdf':
        return Icons.description;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }
}
