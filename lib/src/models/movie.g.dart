// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 1;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      id: fields[0] as int,
      title: fields[1] as String,
      rating: fields[18] as double,
      backgroundImage: fields[3] as String,
      url: fields[4] as String,
      imdbCode: fields[5] as String,
      language: fields[6] as String,
      descriptionFull: fields[8] as String,
      runtime: fields[10] as int,
      genres: (fields[11] as List).cast<String>(),
      torrents: (fields[12] as List).cast<Torrent>(),
      smallCoverImage: fields[13] as String,
      mediumCoverImage: fields[14] as String,
      year: fields[2] as int?,
      synopsis: fields[9] as String?,
      mpaRating: fields[7] as String?,
      largeCoverImage: fields[15] as String?,
      trailer: fields[17] as String?,
      dateUploaded: fields[16] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(18)
      ..write(obj.rating)
      ..writeByte(3)
      ..write(obj.backgroundImage)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.imdbCode)
      ..writeByte(6)
      ..write(obj.language)
      ..writeByte(7)
      ..write(obj.mpaRating)
      ..writeByte(8)
      ..write(obj.descriptionFull)
      ..writeByte(9)
      ..write(obj.synopsis)
      ..writeByte(10)
      ..write(obj.runtime)
      ..writeByte(11)
      ..write(obj.genres)
      ..writeByte(12)
      ..write(obj.torrents)
      ..writeByte(13)
      ..write(obj.smallCoverImage)
      ..writeByte(14)
      ..write(obj.mediumCoverImage)
      ..writeByte(15)
      ..write(obj.largeCoverImage)
      ..writeByte(16)
      ..write(obj.dateUploaded)
      ..writeByte(17)
      ..write(obj.trailer);
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
      id: json['id'] as int,
      title: json['title'] as String,
      rating: (json['rating'] as num).toDouble(),
      backgroundImage: json['background_image'] as String,
      url: json['url'] as String,
      imdbCode: json['imdb_code'] as String,
      language: json['language'] as String,
      descriptionFull: json['description_full'] as String,
      runtime: json['runtime'] as int,
      genres:
          (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
      torrents: (json['torrents'] as List<dynamic>)
          .map((e) => Torrent.fromJson(e as Map<String, dynamic>))
          .toList(),
      smallCoverImage: json['small_cover_image'] as String,
      mediumCoverImage: json['medium_cover_image'] as String,
      year: json['year'] as int?,
      synopsis: json['description_intro'] as String?,
      mpaRating: json['mpa_rating'] as String?,
      largeCoverImage: json['large_cover_image'] as String?,
      trailer: json['yt_trailer_code'] as String?,
      dateUploaded: json['date_uploaded'] == null
          ? null
          : DateTime.parse(json['date_uploaded'] as String),
    );

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'year': instance.year,
      'rating': instance.rating,
      'background_image': instance.backgroundImage,
      'url': instance.url,
      'imdb_code': instance.imdbCode,
      'language': instance.language,
      'mpa_rating': instance.mpaRating,
      'description_full': instance.descriptionFull,
      'description_intro': instance.synopsis,
      'runtime': instance.runtime,
      'genres': instance.genres,
      'torrents': instance.torrents.map((e) => e.toJson()).toList(),
      'small_cover_image': instance.smallCoverImage,
      'medium_cover_image': instance.mediumCoverImage,
      'large_cover_image': instance.largeCoverImage,
      'date_uploaded': instance.dateUploaded?.toIso8601String(),
      'yt_trailer_code': instance.trailer,
    };
