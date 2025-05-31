// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Movie {
  int get id;
  String get title;
  int? get year;
  String get backgroundImage;
  String get url;
  String get imdbCode;
  String get language;
  String? get mpaRating;
  String get descriptionFull;
  String? get descriptionIntro;
  String? get synopsis;
  int get runtime;
  List<String> get genres;
  List<Torrent> get torrents;
  String get smallCoverImage;
  String get mediumCoverImage;
  String? get largeCoverImage;
  DateTime? get dateUploaded;
  @JsonKey(name: 'yt_trailer_code')
  String? get trailer;
  double get rating;

  /// Serializes this Movie to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Movie &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.backgroundImage, backgroundImage) ||
                other.backgroundImage == backgroundImage) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.imdbCode, imdbCode) ||
                other.imdbCode == imdbCode) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.mpaRating, mpaRating) ||
                other.mpaRating == mpaRating) &&
            (identical(other.descriptionFull, descriptionFull) ||
                other.descriptionFull == descriptionFull) &&
            (identical(other.descriptionIntro, descriptionIntro) ||
                other.descriptionIntro == descriptionIntro) &&
            (identical(other.synopsis, synopsis) ||
                other.synopsis == synopsis) &&
            (identical(other.runtime, runtime) || other.runtime == runtime) &&
            const DeepCollectionEquality().equals(other.genres, genres) &&
            const DeepCollectionEquality().equals(other.torrents, torrents) &&
            (identical(other.smallCoverImage, smallCoverImage) ||
                other.smallCoverImage == smallCoverImage) &&
            (identical(other.mediumCoverImage, mediumCoverImage) ||
                other.mediumCoverImage == mediumCoverImage) &&
            (identical(other.largeCoverImage, largeCoverImage) ||
                other.largeCoverImage == largeCoverImage) &&
            (identical(other.dateUploaded, dateUploaded) ||
                other.dateUploaded == dateUploaded) &&
            (identical(other.trailer, trailer) || other.trailer == trailer) &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        year,
        backgroundImage,
        url,
        imdbCode,
        language,
        mpaRating,
        descriptionFull,
        descriptionIntro,
        synopsis,
        runtime,
        const DeepCollectionEquality().hash(genres),
        const DeepCollectionEquality().hash(torrents),
        smallCoverImage,
        mediumCoverImage,
        largeCoverImage,
        dateUploaded,
        trailer,
        rating
      ]);

  @override
  String toString() {
    return 'Movie(id: $id, title: $title, year: $year, backgroundImage: $backgroundImage, url: $url, imdbCode: $imdbCode, language: $language, mpaRating: $mpaRating, descriptionFull: $descriptionFull, descriptionIntro: $descriptionIntro, synopsis: $synopsis, runtime: $runtime, genres: $genres, torrents: $torrents, smallCoverImage: $smallCoverImage, mediumCoverImage: $mediumCoverImage, largeCoverImage: $largeCoverImage, dateUploaded: $dateUploaded, trailer: $trailer, rating: $rating)';
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Movie extends Movie {
  const _Movie(
      {required this.id,
      required this.title,
      this.year,
      required this.backgroundImage,
      required this.url,
      required this.imdbCode,
      required this.language,
      this.mpaRating,
      required this.descriptionFull,
      this.descriptionIntro,
      this.synopsis,
      required this.runtime,
      required final List<String> genres,
      required final List<Torrent> torrents,
      required this.smallCoverImage,
      required this.mediumCoverImage,
      this.largeCoverImage,
      this.dateUploaded,
      @JsonKey(name: 'yt_trailer_code') this.trailer,
      required this.rating})
      : _genres = genres,
        _torrents = torrents,
        super._();
  factory _Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final int? year;
  @override
  final String backgroundImage;
  @override
  final String url;
  @override
  final String imdbCode;
  @override
  final String language;
  @override
  final String? mpaRating;
  @override
  final String descriptionFull;
  @override
  final String? descriptionIntro;
  @override
  final String? synopsis;
  @override
  final int runtime;
  final List<String> _genres;
  @override
  List<String> get genres {
    if (_genres is EqualUnmodifiableListView) return _genres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_genres);
  }

  final List<Torrent> _torrents;
  @override
  List<Torrent> get torrents {
    if (_torrents is EqualUnmodifiableListView) return _torrents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_torrents);
  }

  @override
  final String smallCoverImage;
  @override
  final String mediumCoverImage;
  @override
  final String? largeCoverImage;
  @override
  final DateTime? dateUploaded;
  @override
  @JsonKey(name: 'yt_trailer_code')
  final String? trailer;
  @override
  final double rating;

  @override
  Map<String, dynamic> toJson() {
    return _$MovieToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Movie &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.backgroundImage, backgroundImage) ||
                other.backgroundImage == backgroundImage) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.imdbCode, imdbCode) ||
                other.imdbCode == imdbCode) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.mpaRating, mpaRating) ||
                other.mpaRating == mpaRating) &&
            (identical(other.descriptionFull, descriptionFull) ||
                other.descriptionFull == descriptionFull) &&
            (identical(other.descriptionIntro, descriptionIntro) ||
                other.descriptionIntro == descriptionIntro) &&
            (identical(other.synopsis, synopsis) ||
                other.synopsis == synopsis) &&
            (identical(other.runtime, runtime) || other.runtime == runtime) &&
            const DeepCollectionEquality().equals(other._genres, _genres) &&
            const DeepCollectionEquality().equals(other._torrents, _torrents) &&
            (identical(other.smallCoverImage, smallCoverImage) ||
                other.smallCoverImage == smallCoverImage) &&
            (identical(other.mediumCoverImage, mediumCoverImage) ||
                other.mediumCoverImage == mediumCoverImage) &&
            (identical(other.largeCoverImage, largeCoverImage) ||
                other.largeCoverImage == largeCoverImage) &&
            (identical(other.dateUploaded, dateUploaded) ||
                other.dateUploaded == dateUploaded) &&
            (identical(other.trailer, trailer) || other.trailer == trailer) &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        year,
        backgroundImage,
        url,
        imdbCode,
        language,
        mpaRating,
        descriptionFull,
        descriptionIntro,
        synopsis,
        runtime,
        const DeepCollectionEquality().hash(_genres),
        const DeepCollectionEquality().hash(_torrents),
        smallCoverImage,
        mediumCoverImage,
        largeCoverImage,
        dateUploaded,
        trailer,
        rating
      ]);

  @override
  String toString() {
    return 'Movie(id: $id, title: $title, year: $year, backgroundImage: $backgroundImage, url: $url, imdbCode: $imdbCode, language: $language, mpaRating: $mpaRating, descriptionFull: $descriptionFull, descriptionIntro: $descriptionIntro, synopsis: $synopsis, runtime: $runtime, genres: $genres, torrents: $torrents, smallCoverImage: $smallCoverImage, mediumCoverImage: $mediumCoverImage, largeCoverImage: $largeCoverImage, dateUploaded: $dateUploaded, trailer: $trailer, rating: $rating)';
  }
}

// dart format on
