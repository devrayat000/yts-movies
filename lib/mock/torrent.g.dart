// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'torrent.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TorrentAdapter extends TypeAdapter<Torrent> {
  @override
  final int typeId = 2;

  @override
  Torrent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Torrent(
      url: fields[0] as String,
      hash: fields[1] as String,
      quality: fields[2] as String,
      seeds: fields[3] as int,
      peers: fields[4] as int,
      size: fields[5] as String,
      dateUploaded: fields[6] as DateTime,
      type: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Torrent obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.hash)
      ..writeByte(2)
      ..write(obj.quality)
      ..writeByte(3)
      ..write(obj.seeds)
      ..writeByte(4)
      ..write(obj.peers)
      ..writeByte(5)
      ..write(obj.size)
      ..writeByte(6)
      ..write(obj.dateUploaded)
      ..writeByte(7)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TorrentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Torrent _$TorrentFromJson(Map<String, dynamic> json) {
  return Torrent(
    url: json['url'] as String,
    hash: json['hash'] as String,
    quality: json['quality'] as String,
    seeds: json['seeds'] as int,
    peers: json['peers'] as int,
    size: json['size'] as String,
    dateUploaded: DateTime.parse(json['date_uploaded'] as String),
    type: json['type'] as String?,
  );
}

Map<String, dynamic> _$TorrentToJson(Torrent instance) => <String, dynamic>{
      'url': instance.url,
      'hash': instance.hash,
      'quality': instance.quality,
      'seeds': instance.seeds,
      'peers': instance.peers,
      'size': instance.size,
      'date_uploaded': instance.dateUploaded.toIso8601String(),
      'type': instance.type,
    };
