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

  Future<void> _download(BuildContext context) async {
    try {
      if (movie == null) {
        throw Exception('Movie information not available');
      }

      // Default save path is public Downloads (Android). Needs
      // MANAGE_EXTERNAL_STORAGE — prompt before opening the config page so
      // the failure mode is clear and the dialog never opens for a torrent
      // that can't be written.
      if (!await ensurePublicStorageWrite()) {
        if (context.mounted) {
          await showStoragePermissionDeniedDialog(context);
        }
        return;
      }
      await getIt<ForegroundDownloadService>().ensureSavePathExists();
      if (!context.mounted) return;

      final magnetUri = _torrent.magnet(movie!.title).toString();
      final taskId = urlToUniqueInt(magnetUri);

      final bloc = context.read<DownloadManagerBloc>();
      if (bloc.state.downloads.containsKey(taskId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This movie is already in your downloads'),
            duration: Duration(seconds: 2),
          ),
        );
        context.pushNamed('downloads');
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: DownloadConfigPage(
              torrent: _torrent,
              movie: movie!,
              magnetUri: magnetUri,
              taskId: taskId,
            ),
          ),
        ),
      );
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
}
