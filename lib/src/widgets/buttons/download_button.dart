part of app_widgets.button;

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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () => _download(context),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.download_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_torrent.quality} ${_torrent.type?.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        key: key,
        action: SnackBarAction(
          label: 'Cancel',
          onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar,
        ),
        content: const Text('No torrent client found'),
        duration: const Duration(seconds: 3),
        width: 320.0,
        padding: const EdgeInsets.only(left: 16.0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: Colors.red.shade600,
      ));
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
    }
  }
}
