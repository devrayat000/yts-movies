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
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        textStyle: const TextStyle(fontSize: 12),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12.0),
        ),
        side: const BorderSide(color: Colors.grey),
      ),
      icon: const Icon(Icons.download, size: 12),
      onPressed: () => _download(context),
      label: Text('${_torrent.quality}.${_torrent.type?.toUpperCase()}'),
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
          borderRadius: BorderRadius.circular(4.0),
        ),
      ));
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
    }
  }
}
