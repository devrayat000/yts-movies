import 'package:freezed_annotation/freezed_annotation.dart';

part 'torrent.g.dart';
part 'torrent.freezed.dart';

@Freezed(equal: true, toStringOverride: true, copyWith: false)
sealed class Torrent with _$Torrent {
  const Torrent._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Torrent({
    required String url,
    required String hash,
    required String quality,
    required int seeds,
    required int peers,
    required String size,
    required DateTime dateUploaded,
    String? type,
  }) = _Torrent;

  factory Torrent.fromJson(Map<String, dynamic> json) =>
      _$TorrentFromJson(json);

  Uri magnet(String title) {
    return Uri(
      scheme: 'magnet',
      queryParameters: {
        'xt': 'urn:btih:$hash',
        'dn': '$title [$quality] [YTS.MX]',
        'tr': [
          'udp://glotorrents.pw:6969/announce',
          'udp://tracker.opentrackr.org:1337/announce',
          'udp://torrent.gresille.org:80/announce',
          'udp://tracker.openbittorrent.com:80',
          'udp://tracker.coppersurfer.tk:6969',
          'udp://tracker.leechers-paradise.org:6969',
          'udp://p4p.arenabg.ch:1337',
          'udp://tracker.internetwarriors.net:1337',
        ],
      },
    );
  }
}
