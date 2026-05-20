part of 'index.dart';

class DownloadButton extends StatelessWidget {
  final m.Torrent _torrent;
  final String title;
  final Movie? movie;

  const DownloadButton({
    super.key,
    required this.title,
    required m.Torrent torrent,
    this.movie,
  }) : _torrent = torrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha((0.25 * 255).toInt()),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () => _download(context),
        splashColor: Colors.white.withAlpha((0.1 * 255).toInt()),
        highlightColor: Colors.white.withAlpha((0.05 * 255).toInt()),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.download_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                _downloadLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _downloadLabel {
    var label = _torrent.quality;
    if (_torrent.type != null) {
      label += ' ${_torrent.type!.toUpperCase()}';
    }
    return label;
  }

  void _download(BuildContext context) async {
    // Show dialog to choose download method
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _DownloadMethodDialog(
        torrent: _torrent,
        movieTitle: title,
      ),
    );

    if (result == null || !context.mounted) return;

    if (result == 'internal') {
      await _downloadInternal(context);
    } else {
      await _downloadExternal(context);
    }
  }

  Future<void> _downloadInternal(BuildContext context) async {
    try {
      if (movie == null) {
        throw Exception('Movie information not available');
      }

      // Default save path is public Downloads (Android). Needs MANAGE_EXTERNAL_STORAGE.
      // Prompt before starting the download so failure mode is clear.
      if (!await ensurePublicStorageWrite()) {
        if (context.mounted) {
          await showStoragePermissionDeniedDialog(context);
        }
        return;
      }
      await getIt<ForegroundDownloadService>().ensureSavePathExists();

      final magnetUri = _torrent.magnet(movie!.title).toString();
      final taskId = urlToUniqueInt(magnetUri);

      final advanced = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) => AdvancedDownloadDialog(
          torrent: _torrent,
          movieTitle: movie!.title,
          magnetUri: magnetUri,
        ),
      );
      if (advanced == null) return;

      final savePath = (advanced['savePath'] as String?) ??
          getIt<ForegroundDownloadService>().downloadPath;
      final sequentialDownload = advanced['sequentialDownload'] == true;
      final trackers =
          (advanced['trackers'] as List?)?.map((e) => e.toString()).toList() ??
              const <String>[];
      final selectedIndices = (advanced['selectedIndices'] as List?)
          ?.map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();

      final dlLimitMb =
          (advanced['downloadSpeedLimit'] as num?)?.toDouble() ?? 0;
      final ulLimitMb = (advanced['uploadSpeedLimit'] as num?)?.toDouble() ?? 0;
      final downloadLimit =
          dlLimitMb <= 0 ? null : (dlLimitMb * 1024 * 1024).round();
      final uploadLimit =
          ulLimitMb <= 0 ? null : (ulLimitMb * 1024 * 1024).round();

      try {
        final dir = Directory(savePath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } catch (_) {}

      // Check if already downloading
      if (!context.mounted) return;
      final bloc = context.read<DownloadManagerBloc>();
      if (bloc.state.downloads.containsKey(taskId)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This movie is already in your downloads'),
              duration: Duration(seconds: 2),
            ),
          );
          // Navigate to downloads page
          context.pushNamed('downloads');
        }
        return;
      }

      // Create download task
      final task = DownloadTask(
        taskId: taskId,
        movieId: movie!.id,
        movieTitle: movie!.title,
        torrentHash: _torrent.hash,
        magnetUri: magnetUri,
        quality: _torrent.quality,
        type: _torrent.type,
        size: _torrent.size,
        coverImage: movie!.mediumCoverImage,
        filePath: savePath,
        downloadSpeedLimit: downloadLimit,
        uploadSpeedLimit: uploadLimit,
        sequentialDownload: sequentialDownload,
        trackers: trackers
            .map(
              (url) => TrackerInfo(
                url: url,
                status: TrackerStatus.connecting,
                userAdded: true,
              ),
            )
            .toList(),
      );

      // Add to download manager
      bloc.add(DownloadManagerAddDownload(
        task: task,
        selectedIndices: selectedIndices,
      ));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Download started'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                context.pushNamed('downloads');
              },
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      if (context.mounted) {
        context.errorNotificationService.showError(
          context,
          e,
          customMessage: 'Failed to start download',
        );
      }
    }
  }

  Future<void> _downloadExternal(BuildContext context) async {
    try {
      var downloadUri = _torrent.magnet(title);
      if (!(await canLaunchUrl(downloadUri))) {
        throw const TorrentClientException('No torrent client found');
      }
      await launchUrl(downloadUri, mode: LaunchMode.externalApplication);
    } on TorrentClientException catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      if (context.mounted) {
        context.errorNotificationService.showError(
          context,
          e,
          customMessage: 'Unable to download torrent',
        );
      }
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      if (context.mounted) {
        context.errorNotificationService.showError(
          context,
          e,
          customMessage: 'Download failed',
        );
      }
    }
  }
}

class _DownloadMethodDialog extends StatelessWidget {
  final m.Torrent torrent;
  final String movieTitle;

  const _DownloadMethodDialog({
    required this.torrent,
    required this.movieTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final downloadPath = getIt<ForegroundDownloadService>().downloadPath;
    final customPath = getIt<PreferencesService>().customDownloadPath;
    final isUsingCustomPath = customPath != null;

    return AlertDialog(
      title: const Text('Download Method'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How would you like to download this torrent?'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Download Location',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isUsingCustomPath) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'Custom',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  downloadPath,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DownloadSettingsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings, size: 14),
                  label: const Text('Change Location'),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withAlpha(77),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.secondary.withAlpha(77),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All files in the torrent will be downloaded. File selection is available in the external torrent client option.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quality: ${torrent.quality}${torrent.type != null ? " ${torrent.type!.toUpperCase()}" : ""}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            'Size: ${torrent.size}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop('external'),
          icon: const Icon(Icons.open_in_new),
          label: const Text('Open External'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop('internal'),
          icon: const Icon(Icons.download),
          label: const Text('Download'),
        ),
      ],
    );
  }
}
