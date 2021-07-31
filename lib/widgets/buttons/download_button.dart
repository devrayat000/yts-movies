import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/exceptions.dart';
import '../../models/movie.dart' as m;

class DownloadButton extends StatelessWidget {
  final m.Torrent _torrent;
  const DownloadButton({Key? key, required m.Torrent torrent})
      : _torrent = torrent,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.all(8.0),
        textStyle: TextStyle(fontSize: 12),
      ),
      icon: Icon(Icons.download, size: 12),
      onPressed: () async {
        try {
          var mg = _torrent.magnet.toString();
          if (!(await canLaunch(mg))) {
            throw TorrentClientException('No torrent client found');
          }
          await launch(mg);
        } on TorrentClientException catch (e) {
          print(e.message);
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
        } catch (e) {
          print(e);
        }
      },
      label: Text('${_torrent.quality}.${_torrent.type?.toUpperCase()}'),
    );
  }
}
