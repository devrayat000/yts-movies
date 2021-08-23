import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'torrent.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 2, adapterName: 'TorrentAdapter')
class Torrent with EquatableMixin, HiveObjectMixin {
  @HiveField(0)
  final String url;

  @HiveField(1)
  final String hash;

  @HiveField(2)
  final String quality;

  @HiveField(3)
  final int seeds;

  @HiveField(4)
  final int peers;

  @HiveField(5)
  final String size;

  @HiveField(6)
  final DateTime dateUploaded;

  @HiveField(7)
  final String? type;

  Torrent({
    required this.url,
    required this.hash,
    required this.quality,
    required this.seeds,
    required this.peers,
    required this.size,
    required this.dateUploaded,
    this.type,
  });

  factory Torrent.fromJson(Map<String, dynamic> json) =>
      _$TorrentFromJson(json);

  Map<String, dynamic> toJson() => _$TorrentToJson(this);

  Uri magnet(String _title) {
    return Uri(
      scheme: 'magnet',
      queryParameters: {
        'xt': 'urn:btih:$hash',
        'dn': '$_title [$quality] [YTS.MX]',
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
