// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class TorrentAdapter extends TypeAdapter<Torrent> {
  @override
  final typeId = 3;

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
      seeds: (fields[3] as num).toInt(),
      peers: (fields[4] as num).toInt(),
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

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final typeId = 4;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      id: (fields[20] as num).toInt(),
      title: fields[21] as String,
      year: (fields[22] as num?)?.toInt(),
      backgroundImage: fields[23] as String,
      url: fields[24] as String,
      imdbCode: fields[25] as String,
      language: fields[26] as String,
      mpaRating: fields[27] as String?,
      descriptionFull: fields[28] as String,
      descriptionIntro: fields[29] as String?,
      synopsis: fields[30] as String?,
      runtime: (fields[31] as num).toInt(),
      genres: (fields[32] as List).cast<String>(),
      torrents: (fields[33] as List).cast<Torrent>(),
      smallCoverImage: fields[34] as String,
      mediumCoverImage: fields[35] as String,
      largeCoverImage: fields[36] as String?,
      dateUploaded: fields[37] as DateTime?,
      trailer: fields[38] as String?,
      rating: (fields[39] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(20)
      ..writeByte(20)
      ..write(obj.id)
      ..writeByte(21)
      ..write(obj.title)
      ..writeByte(22)
      ..write(obj.year)
      ..writeByte(23)
      ..write(obj.backgroundImage)
      ..writeByte(24)
      ..write(obj.url)
      ..writeByte(25)
      ..write(obj.imdbCode)
      ..writeByte(26)
      ..write(obj.language)
      ..writeByte(27)
      ..write(obj.mpaRating)
      ..writeByte(28)
      ..write(obj.descriptionFull)
      ..writeByte(29)
      ..write(obj.descriptionIntro)
      ..writeByte(30)
      ..write(obj.synopsis)
      ..writeByte(31)
      ..write(obj.runtime)
      ..writeByte(32)
      ..write(obj.genres)
      ..writeByte(33)
      ..write(obj.torrents)
      ..writeByte(34)
      ..write(obj.smallCoverImage)
      ..writeByte(35)
      ..write(obj.mediumCoverImage)
      ..writeByte(36)
      ..write(obj.largeCoverImage)
      ..writeByte(37)
      ..write(obj.dateUploaded)
      ..writeByte(38)
      ..write(obj.trailer)
      ..writeByte(39)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
