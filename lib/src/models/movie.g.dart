// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Movie _$MovieFromJson(Map<String, dynamic> json) => _Movie(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      year: (json['year'] as num?)?.toInt(),
      backgroundImage: json['background_image'] as String,
      url: json['url'] as String,
      imdbCode: json['imdb_code'] as String,
      language: json['language'] as String,
      mpaRating: json['mpa_rating'] as String?,
      descriptionFull: json['description_full'] as String,
      descriptionIntro: json['description_intro'] as String?,
      synopsis: json['synopsis'] as String?,
      runtime: (json['runtime'] as num).toInt(),
      genres:
          (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
      torrents: (json['torrents'] as List<dynamic>)
          .map((e) => Torrent.fromJson(e as Map<String, dynamic>))
          .toList(),
      smallCoverImage: json['small_cover_image'] as String,
      mediumCoverImage: json['medium_cover_image'] as String,
      largeCoverImage: json['large_cover_image'] as String?,
      dateUploaded: json['date_uploaded'] == null
          ? null
          : DateTime.parse(json['date_uploaded'] as String),
      trailer: json['yt_trailer_code'] as String?,
      rating: (json['rating'] as num).toDouble(),
    );

Map<String, dynamic> _$MovieToJson(_Movie instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'year': instance.year,
      'background_image': instance.backgroundImage,
      'url': instance.url,
      'imdb_code': instance.imdbCode,
      'language': instance.language,
      'mpa_rating': instance.mpaRating,
      'description_full': instance.descriptionFull,
      'description_intro': instance.descriptionIntro,
      'synopsis': instance.synopsis,
      'runtime': instance.runtime,
      'genres': instance.genres,
      'torrents': instance.torrents.map((e) => e.toJson()).toList(),
      'small_cover_image': instance.smallCoverImage,
      'medium_cover_image': instance.mediumCoverImage,
      'large_cover_image': instance.largeCoverImage,
      'date_uploaded': instance.dateUploaded?.toIso8601String(),
      'yt_trailer_code': instance.trailer,
      'rating': instance.rating,
    };
