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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Download Method'),
        content: const Text('How would you like to download this torrent?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('internal'),
            child: const Text('Download in App'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('external'),
            child: const Text('Open with Torrent Client'),
          ),
        ],
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

      final taskId = '${movie!.id}_${_torrent.hash}';

      // Check if already downloading
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
        magnetUri: _torrent.magnet(movie!.title).toString(),
        quality: _torrent.quality,
        type: _torrent.type,
        size: _torrent.size,
        coverImage: movie!.mediumCoverImage,
      );

      // Add to download manager
      bloc.add(DownloadManagerAddDownload(
        task: task,
        movie: movie!,
        torrent: _torrent,
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
        ErrorNotificationService.instance.showError(
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
        ErrorNotificationService.instance.showError(
          context,
          e,
          customMessage: 'Unable to download torrent',
        );
      }
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      if (context.mounted) {
        ErrorNotificationService.instance.showError(
          context,
          e,
          customMessage: 'Download failed',
        );
      }
    }
  }
}
