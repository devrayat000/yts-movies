part of 'index.dart';

class DownloadButton extends StatelessWidget {
  final m.Torrent _torrent;
  final String title;

  const DownloadButton({
    super.key,
    required this.title,
    required m.Torrent torrent,
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
