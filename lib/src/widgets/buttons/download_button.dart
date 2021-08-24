part of app_widget.button;

class DownloadButton extends StatefulWidget {
  final m.Torrent _torrent;
  const DownloadButton({Key? key, required m.Torrent torrent})
      : _torrent = torrent,
        super(key: key);

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(8.0),
        textStyle: TextStyle(fontSize: 12),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      icon: Icon(Icons.download, size: 12),
      onPressed: _download,
      label: Text(
          '${widget._torrent.quality}.${widget._torrent.type?.toUpperCase()}'),
    );
  }

  void _download() async {
    try {
      var mg = widget._torrent.magnet.toString();
      if (!(await canLaunch(mg))) {
        throw TorrentClientException('No torrent client found');
      }
      await launch(mg);
    } on TorrentClientException catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        key: widget.key,
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
