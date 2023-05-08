// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Movie _$MovieFromJson(Map<String, dynamic> json) {
  return _Movie.fromJson(json);
}

/// @nodoc
mixin _$Movie {
  @HiveField(0)
  int get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get title => throw _privateConstructorUsedError;
  @HiveField(18)
  double get rating => throw _privateConstructorUsedError;
  @HiveField(3)
  String get backgroundImage => throw _privateConstructorUsedError;
  @HiveField(4)
  String get url => throw _privateConstructorUsedError;
  @HiveField(5)
  String get imdbCode => throw _privateConstructorUsedError;
  @HiveField(6)
  String get language => throw _privateConstructorUsedError;
  @HiveField(8)
  String get descriptionFull => throw _privateConstructorUsedError;
  @HiveField(10)
  int get runtime => throw _privateConstructorUsedError;
  @HiveField(11)
  List<String> get genres => throw _privateConstructorUsedError;
  @HiveField(12)
  List<Torrent> get torrents => throw _privateConstructorUsedError;
  @HiveField(13)
  String get smallCoverImage => throw _privateConstructorUsedError;
  @HiveField(14)
  String get mediumCoverImage => throw _privateConstructorUsedError;
  @HiveField(2)
  int? get year => throw _privateConstructorUsedError;
  @HiveField(9)
  @JsonKey(name: 'description_intro')
  String? get synopsis => throw _privateConstructorUsedError;
  @HiveField(7)
  String? get mpaRating => throw _privateConstructorUsedError;
  @HiveField(15)
  String? get largeCoverImage => throw _privateConstructorUsedError;
  @HiveField(17)
  @JsonKey(name: 'yt_trailer_code')
  String? get trailer => throw _privateConstructorUsedError;
  @HiveField(16)
  DateTime? get dateUploaded => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MovieCopyWith<Movie> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieCopyWith<$Res> {
  factory $MovieCopyWith(Movie value, $Res Function(Movie) then) =
      _$MovieCopyWithImpl<$Res, Movie>;
  @useResult
  $Res call(
      {@HiveField(0) int id,
      @HiveField(1) String title,
      @HiveField(18) double rating,
      @HiveField(3) String backgroundImage,
      @HiveField(4) String url,
      @HiveField(5) String imdbCode,
      @HiveField(6) String language,
      @HiveField(8) String descriptionFull,
      @HiveField(10) int runtime,
      @HiveField(11) List<String> genres,
      @HiveField(12) List<Torrent> torrents,
      @HiveField(13) String smallCoverImage,
      @HiveField(14) String mediumCoverImage,
      @HiveField(2) int? year,
      @HiveField(9) @JsonKey(name: 'description_intro') String? synopsis,
      @HiveField(7) String? mpaRating,
      @HiveField(15) String? largeCoverImage,
      @HiveField(17) @JsonKey(name: 'yt_trailer_code') String? trailer,
      @HiveField(16) DateTime? dateUploaded});
}

/// @nodoc
class _$MovieCopyWithImpl<$Res, $Val extends Movie>
    implements $MovieCopyWith<$Res> {
  _$MovieCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? rating = null,
    Object? backgroundImage = null,
    Object? url = null,
    Object? imdbCode = null,
    Object? language = null,
    Object? descriptionFull = null,
    Object? runtime = null,
    Object? genres = null,
    Object? torrents = null,
    Object? smallCoverImage = null,
    Object? mediumCoverImage = null,
    Object? year = freezed,
    Object? synopsis = freezed,
    Object? mpaRating = freezed,
    Object? largeCoverImage = freezed,
    Object? trailer = freezed,
    Object? dateUploaded = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      backgroundImage: null == backgroundImage
          ? _value.backgroundImage
          : backgroundImage // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      imdbCode: null == imdbCode
          ? _value.imdbCode
          : imdbCode // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      descriptionFull: null == descriptionFull
          ? _value.descriptionFull
          : descriptionFull // ignore: cast_nullable_to_non_nullable
              as String,
      runtime: null == runtime
          ? _value.runtime
          : runtime // ignore: cast_nullable_to_non_nullable
              as int,
      genres: null == genres
          ? _value.genres
          : genres // ignore: cast_nullable_to_non_nullable
              as List<String>,
      torrents: null == torrents
          ? _value.torrents
          : torrents // ignore: cast_nullable_to_non_nullable
              as List<Torrent>,
      smallCoverImage: null == smallCoverImage
          ? _value.smallCoverImage
          : smallCoverImage // ignore: cast_nullable_to_non_nullable
              as String,
      mediumCoverImage: null == mediumCoverImage
          ? _value.mediumCoverImage
          : mediumCoverImage // ignore: cast_nullable_to_non_nullable
              as String,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      synopsis: freezed == synopsis
          ? _value.synopsis
          : synopsis // ignore: cast_nullable_to_non_nullable
              as String?,
      mpaRating: freezed == mpaRating
          ? _value.mpaRating
          : mpaRating // ignore: cast_nullable_to_non_nullable
              as String?,
      largeCoverImage: freezed == largeCoverImage
          ? _value.largeCoverImage
          : largeCoverImage // ignore: cast_nullable_to_non_nullable
              as String?,
      trailer: freezed == trailer
          ? _value.trailer
          : trailer // ignore: cast_nullable_to_non_nullable
              as String?,
      dateUploaded: freezed == dateUploaded
          ? _value.dateUploaded
          : dateUploaded // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MovieCopyWith<$Res> implements $MovieCopyWith<$Res> {
  factory _$$_MovieCopyWith(_$_Movie value, $Res Function(_$_Movie) then) =
      __$$_MovieCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) int id,
      @HiveField(1) String title,
      @HiveField(18) double rating,
      @HiveField(3) String backgroundImage,
      @HiveField(4) String url,
      @HiveField(5) String imdbCode,
      @HiveField(6) String language,
      @HiveField(8) String descriptionFull,
      @HiveField(10) int runtime,
      @HiveField(11) List<String> genres,
      @HiveField(12) List<Torrent> torrents,
      @HiveField(13) String smallCoverImage,
      @HiveField(14) String mediumCoverImage,
      @HiveField(2) int? year,
      @HiveField(9) @JsonKey(name: 'description_intro') String? synopsis,
      @HiveField(7) String? mpaRating,
      @HiveField(15) String? largeCoverImage,
      @HiveField(17) @JsonKey(name: 'yt_trailer_code') String? trailer,
      @HiveField(16) DateTime? dateUploaded});
}

/// @nodoc
class __$$_MovieCopyWithImpl<$Res> extends _$MovieCopyWithImpl<$Res, _$_Movie>
    implements _$$_MovieCopyWith<$Res> {
  __$$_MovieCopyWithImpl(_$_Movie _value, $Res Function(_$_Movie) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? rating = null,
    Object? backgroundImage = null,
    Object? url = null,
    Object? imdbCode = null,
    Object? language = null,
    Object? descriptionFull = null,
    Object? runtime = null,
    Object? genres = null,
    Object? torrents = null,
    Object? smallCoverImage = null,
    Object? mediumCoverImage = null,
    Object? year = freezed,
    Object? synopsis = freezed,
    Object? mpaRating = freezed,
    Object? largeCoverImage = freezed,
    Object? trailer = freezed,
    Object? dateUploaded = freezed,
  }) {
    return _then(_$_Movie(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      backgroundImage: null == backgroundImage
          ? _value.backgroundImage
          : backgroundImage // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      imdbCode: null == imdbCode
          ? _value.imdbCode
          : imdbCode // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      descriptionFull: null == descriptionFull
          ? _value.descriptionFull
          : descriptionFull // ignore: cast_nullable_to_non_nullable
              as String,
      runtime: null == runtime
          ? _value.runtime
          : runtime // ignore: cast_nullable_to_non_nullable
              as int,
      genres: null == genres
          ? _value._genres
          : genres // ignore: cast_nullable_to_non_nullable
              as List<String>,
      torrents: null == torrents
          ? _value._torrents
          : torrents // ignore: cast_nullable_to_non_nullable
              as List<Torrent>,
      smallCoverImage: null == smallCoverImage
          ? _value.smallCoverImage
          : smallCoverImage // ignore: cast_nullable_to_non_nullable
              as String,
      mediumCoverImage: null == mediumCoverImage
          ? _value.mediumCoverImage
          : mediumCoverImage // ignore: cast_nullable_to_non_nullable
              as String,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      synopsis: freezed == synopsis
          ? _value.synopsis
          : synopsis // ignore: cast_nullable_to_non_nullable
              as String?,
      mpaRating: freezed == mpaRating
          ? _value.mpaRating
          : mpaRating // ignore: cast_nullable_to_non_nullable
              as String?,
      largeCoverImage: freezed == largeCoverImage
          ? _value.largeCoverImage
          : largeCoverImage // ignore: cast_nullable_to_non_nullable
              as String?,
      trailer: freezed == trailer
          ? _value.trailer
          : trailer // ignore: cast_nullable_to_non_nullable
              as String?,
      dateUploaded: freezed == dateUploaded
          ? _value.dateUploaded
          : dateUploaded // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@HiveType(typeId: 1, adapterName: 'MovieAdapter')
@JsonSerializable(fieldRename: FieldRename.snake)
class _$_Movie extends _Movie {
  _$_Movie(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.title,
      @HiveField(18) required this.rating,
      @HiveField(3) required this.backgroundImage,
      @HiveField(4) required this.url,
      @HiveField(5) required this.imdbCode,
      @HiveField(6) required this.language,
      @HiveField(8) required this.descriptionFull,
      @HiveField(10) required this.runtime,
      @HiveField(11) required final List<String> genres,
      @HiveField(12) required final List<Torrent> torrents,
      @HiveField(13) required this.smallCoverImage,
      @HiveField(14) required this.mediumCoverImage,
      @HiveField(2) this.year,
      @HiveField(9) @JsonKey(name: 'description_intro') this.synopsis,
      @HiveField(7) this.mpaRating,
      @HiveField(15) this.largeCoverImage,
      @HiveField(17) @JsonKey(name: 'yt_trailer_code') this.trailer,
      @HiveField(16) this.dateUploaded})
      : _genres = genres,
        _torrents = torrents,
        super._();

  factory _$_Movie.fromJson(Map<String, dynamic> json) =>
      _$$_MovieFromJson(json);

  @override
  @HiveField(0)
  final int id;
  @override
  @HiveField(1)
  final String title;
  @override
  @HiveField(18)
  final double rating;
  @override
  @HiveField(3)
  final String backgroundImage;
  @override
  @HiveField(4)
  final String url;
  @override
  @HiveField(5)
  final String imdbCode;
  @override
  @HiveField(6)
  final String language;
  @override
  @HiveField(8)
  final String descriptionFull;
  @override
  @HiveField(10)
  final int runtime;
  final List<String> _genres;
  @override
  @HiveField(11)
  List<String> get genres {
    if (_genres is EqualUnmodifiableListView) return _genres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_genres);
  }

  final List<Torrent> _torrents;
  @override
  @HiveField(12)
  List<Torrent> get torrents {
    if (_torrents is EqualUnmodifiableListView) return _torrents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_torrents);
  }

  @override
  @HiveField(13)
  final String smallCoverImage;
  @override
  @HiveField(14)
  final String mediumCoverImage;
  @override
  @HiveField(2)
  final int? year;
  @override
  @HiveField(9)
  @JsonKey(name: 'description_intro')
  final String? synopsis;
  @override
  @HiveField(7)
  final String? mpaRating;
  @override
  @HiveField(15)
  final String? largeCoverImage;
  @override
  @HiveField(17)
  @JsonKey(name: 'yt_trailer_code')
  final String? trailer;
  @override
  @HiveField(16)
  final DateTime? dateUploaded;

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MovieCopyWith<_$_Movie> get copyWith =>
      __$$_MovieCopyWithImpl<_$_Movie>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MovieToJson(
      this,
    );
  }
}

abstract class _Movie extends Movie {
  factory _Movie(
      {@HiveField(0) required final int id,
      @HiveField(1) required final String title,
      @HiveField(18) required final double rating,
      @HiveField(3) required final String backgroundImage,
      @HiveField(4) required final String url,
      @HiveField(5) required final String imdbCode,
      @HiveField(6) required final String language,
      @HiveField(8) required final String descriptionFull,
      @HiveField(10) required final int runtime,
      @HiveField(11) required final List<String> genres,
      @HiveField(12) required final List<Torrent> torrents,
      @HiveField(13) required final String smallCoverImage,
      @HiveField(14) required final String mediumCoverImage,
      @HiveField(2) final int? year,
      @HiveField(9) @JsonKey(name: 'description_intro') final String? synopsis,
      @HiveField(7) final String? mpaRating,
      @HiveField(15) final String? largeCoverImage,
      @HiveField(17) @JsonKey(name: 'yt_trailer_code') final String? trailer,
      @HiveField(16) final DateTime? dateUploaded}) = _$_Movie;
  _Movie._() : super._();

  factory _Movie.fromJson(Map<String, dynamic> json) = _$_Movie.fromJson;

  @override
  @HiveField(0)
  int get id;
  @override
  @HiveField(1)
  String get title;
  @override
  @HiveField(18)
  double get rating;
  @override
  @HiveField(3)
  String get backgroundImage;
  @override
  @HiveField(4)
  String get url;
  @override
  @HiveField(5)
  String get imdbCode;
  @override
  @HiveField(6)
  String get language;
  @override
  @HiveField(8)
  String get descriptionFull;
  @override
  @HiveField(10)
  int get runtime;
  @override
  @HiveField(11)
  List<String> get genres;
  @override
  @HiveField(12)
  List<Torrent> get torrents;
  @override
  @HiveField(13)
  String get smallCoverImage;
  @override
  @HiveField(14)
  String get mediumCoverImage;
  @override
  @HiveField(2)
  int? get year;
  @override
  @HiveField(9)
  @JsonKey(name: 'description_intro')
  String? get synopsis;
  @override
  @HiveField(7)
  String? get mpaRating;
  @override
  @HiveField(15)
  String? get largeCoverImage;
  @override
  @HiveField(17)
  @JsonKey(name: 'yt_trailer_code')
  String? get trailer;
  @override
  @HiveField(16)
  DateTime? get dateUploaded;
  @override
  @JsonKey(ignore: true)
  _$$_MovieCopyWith<_$_Movie> get copyWith =>
      throw _privateConstructorUsedError;
}
