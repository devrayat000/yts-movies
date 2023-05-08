import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'torrent.g.dart';
part 'torrent.freezed.dart';

@Freezed(equal: false, toStringOverride: false)
class Torrent with _$Torrent, EquatableMixin, HiveObjectMixin {
  Torrent._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  @HiveType(typeId: 2, adapterName: 'TorrentAdapter')
  factory Torrent({
    @HiveField(0) required String url,
    @HiveField(1) required String hash,
    @HiveField(2) required String quality,
    @HiveField(3) required int seeds,
    @HiveField(4) required int peers,
    @HiveField(5) required String size,
    @HiveField(6) required DateTime dateUploaded,
    @HiveField(7) String? type,
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

  @override
  List<Object?> get props => [
        url,
        hash,
        quality,
        seeds,
        peers,
        size,
        dateUploaded,
        type,
      ];

  @override
  bool? get stringify => true;
}
