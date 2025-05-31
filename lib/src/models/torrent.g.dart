// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'torrent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Torrent _$TorrentFromJson(Map<String, dynamic> json) => _Torrent(
      url: json['url'] as String,
      hash: json['hash'] as String,
      quality: json['quality'] as String,
      seeds: (json['seeds'] as num).toInt(),
      peers: (json['peers'] as num).toInt(),
      size: json['size'] as String,
      dateUploaded: DateTime.parse(json['date_uploaded'] as String),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$TorrentToJson(_Torrent instance) => <String, dynamic>{
      'url': instance.url,
      'hash': instance.hash,
      'quality': instance.quality,
      'seeds': instance.seeds,
      'peers': instance.peers,
      'size': instance.size,
      'date_uploaded': instance.dateUploaded.toIso8601String(),
      'type': instance.type,
    };
