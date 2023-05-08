// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MovieListResponse _$MovieListResponseFromJson(Map<String, dynamic> json) {
  return _MovieListResponse.fromJson(json);
}

/// @nodoc
mixin _$MovieListResponse {
  String get status => throw _privateConstructorUsedError;
  String get statusMessage => throw _privateConstructorUsedError;
  MovieListData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MovieListResponseCopyWith<MovieListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieListResponseCopyWith<$Res> {
  factory $MovieListResponseCopyWith(
          MovieListResponse value, $Res Function(MovieListResponse) then) =
      _$MovieListResponseCopyWithImpl<$Res, MovieListResponse>;
  @useResult
  $Res call({String status, String statusMessage, MovieListData data});

  $MovieListDataCopyWith<$Res> get data;
}

/// @nodoc
class _$MovieListResponseCopyWithImpl<$Res, $Val extends MovieListResponse>
    implements $MovieListResponseCopyWith<$Res> {
  _$MovieListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? statusMessage = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      statusMessage: null == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as MovieListData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MovieListDataCopyWith<$Res> get data {
    return $MovieListDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_MovieListResponseCopyWith<$Res>
    implements $MovieListResponseCopyWith<$Res> {
  factory _$$_MovieListResponseCopyWith(_$_MovieListResponse value,
          $Res Function(_$_MovieListResponse) then) =
      __$$_MovieListResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String status, String statusMessage, MovieListData data});

  @override
  $MovieListDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$_MovieListResponseCopyWithImpl<$Res>
    extends _$MovieListResponseCopyWithImpl<$Res, _$_MovieListResponse>
    implements _$$_MovieListResponseCopyWith<$Res> {
  __$$_MovieListResponseCopyWithImpl(
      _$_MovieListResponse _value, $Res Function(_$_MovieListResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? statusMessage = null,
    Object? data = null,
  }) {
    return _then(_$_MovieListResponse(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      statusMessage: null == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as MovieListData,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$_MovieListResponse implements _MovieListResponse {
  const _$_MovieListResponse(
      {required this.status, required this.statusMessage, required this.data});

  factory _$_MovieListResponse.fromJson(Map<String, dynamic> json) =>
      _$$_MovieListResponseFromJson(json);

  @override
  final String status;
  @override
  final String statusMessage;
  @override
  final MovieListData data;

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MovieListResponseCopyWith<_$_MovieListResponse> get copyWith =>
      __$$_MovieListResponseCopyWithImpl<_$_MovieListResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MovieListResponseToJson(
      this,
    );
  }
}

abstract class _MovieListResponse implements MovieListResponse {
  const factory _MovieListResponse(
      {required final String status,
      required final String statusMessage,
      required final MovieListData data}) = _$_MovieListResponse;

  factory _MovieListResponse.fromJson(Map<String, dynamic> json) =
      _$_MovieListResponse.fromJson;

  @override
  String get status;
  @override
  String get statusMessage;
  @override
  MovieListData get data;
  @override
  @JsonKey(ignore: true)
  _$$_MovieListResponseCopyWith<_$_MovieListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

MovieListData _$MovieListDataFromJson(Map<String, dynamic> json) {
  return _MovieListData.fromJson(json);
}

/// @nodoc
mixin _$MovieListData {
  int get movieCount => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get pageNumber => throw _privateConstructorUsedError;
  List<Movie>? get movies => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MovieListDataCopyWith<MovieListData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieListDataCopyWith<$Res> {
  factory $MovieListDataCopyWith(
          MovieListData value, $Res Function(MovieListData) then) =
      _$MovieListDataCopyWithImpl<$Res, MovieListData>;
  @useResult
  $Res call({int movieCount, int limit, int pageNumber, List<Movie>? movies});
}

/// @nodoc
class _$MovieListDataCopyWithImpl<$Res, $Val extends MovieListData>
    implements $MovieListDataCopyWith<$Res> {
  _$MovieListDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? movieCount = null,
    Object? limit = null,
    Object? pageNumber = null,
    Object? movies = freezed,
  }) {
    return _then(_value.copyWith(
      movieCount: null == movieCount
          ? _value.movieCount
          : movieCount // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      pageNumber: null == pageNumber
          ? _value.pageNumber
          : pageNumber // ignore: cast_nullable_to_non_nullable
              as int,
      movies: freezed == movies
          ? _value.movies
          : movies // ignore: cast_nullable_to_non_nullable
              as List<Movie>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MovieListDataCopyWith<$Res>
    implements $MovieListDataCopyWith<$Res> {
  factory _$$_MovieListDataCopyWith(
          _$_MovieListData value, $Res Function(_$_MovieListData) then) =
      __$$_MovieListDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int movieCount, int limit, int pageNumber, List<Movie>? movies});
}

/// @nodoc
class __$$_MovieListDataCopyWithImpl<$Res>
    extends _$MovieListDataCopyWithImpl<$Res, _$_MovieListData>
    implements _$$_MovieListDataCopyWith<$Res> {
  __$$_MovieListDataCopyWithImpl(
      _$_MovieListData _value, $Res Function(_$_MovieListData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? movieCount = null,
    Object? limit = null,
    Object? pageNumber = null,
    Object? movies = freezed,
  }) {
    return _then(_$_MovieListData(
      movieCount: null == movieCount
          ? _value.movieCount
          : movieCount // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      pageNumber: null == pageNumber
          ? _value.pageNumber
          : pageNumber // ignore: cast_nullable_to_non_nullable
              as int,
      movies: freezed == movies
          ? _value._movies
          : movies // ignore: cast_nullable_to_non_nullable
              as List<Movie>?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$_MovieListData extends _MovieListData {
  const _$_MovieListData(
      {required this.movieCount,
      required this.limit,
      required this.pageNumber,
      final List<Movie>? movies = const []})
      : _movies = movies,
        super._();

  factory _$_MovieListData.fromJson(Map<String, dynamic> json) =>
      _$$_MovieListDataFromJson(json);

  @override
  final int movieCount;
  @override
  final int limit;
  @override
  final int pageNumber;
  final List<Movie>? _movies;
  @override
  @JsonKey()
  List<Movie>? get movies {
    final value = _movies;
    if (value == null) return null;
    if (_movies is EqualUnmodifiableListView) return _movies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MovieListDataCopyWith<_$_MovieListData> get copyWith =>
      __$$_MovieListDataCopyWithImpl<_$_MovieListData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MovieListDataToJson(
      this,
    );
  }
}

abstract class _MovieListData extends MovieListData {
  const factory _MovieListData(
      {required final int movieCount,
      required final int limit,
      required final int pageNumber,
      final List<Movie>? movies}) = _$_MovieListData;
  const _MovieListData._() : super._();

  factory _MovieListData.fromJson(Map<String, dynamic> json) =
      _$_MovieListData.fromJson;

  @override
  int get movieCount;
  @override
  int get limit;
  @override
  int get pageNumber;
  @override
  List<Movie>? get movies;
  @override
  @JsonKey(ignore: true)
  _$$_MovieListDataCopyWith<_$_MovieListData> get copyWith =>
      throw _privateConstructorUsedError;
}

MovieSuggestionResponse _$MovieSuggestionResponseFromJson(
    Map<String, dynamic> json) {
  return _MovieSuggestionResponse.fromJson(json);
}

/// @nodoc
mixin _$MovieSuggestionResponse {
  String get status => throw _privateConstructorUsedError;
  String get statusMessage => throw _privateConstructorUsedError;
  MovieSuggestionData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MovieSuggestionResponseCopyWith<MovieSuggestionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieSuggestionResponseCopyWith<$Res> {
  factory $MovieSuggestionResponseCopyWith(MovieSuggestionResponse value,
          $Res Function(MovieSuggestionResponse) then) =
      _$MovieSuggestionResponseCopyWithImpl<$Res, MovieSuggestionResponse>;
  @useResult
  $Res call({String status, String statusMessage, MovieSuggestionData data});

  $MovieSuggestionDataCopyWith<$Res> get data;
}

/// @nodoc
class _$MovieSuggestionResponseCopyWithImpl<$Res,
        $Val extends MovieSuggestionResponse>
    implements $MovieSuggestionResponseCopyWith<$Res> {
  _$MovieSuggestionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? statusMessage = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      statusMessage: null == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as MovieSuggestionData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MovieSuggestionDataCopyWith<$Res> get data {
    return $MovieSuggestionDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_MovieSuggestionResponseCopyWith<$Res>
    implements $MovieSuggestionResponseCopyWith<$Res> {
  factory _$$_MovieSuggestionResponseCopyWith(_$_MovieSuggestionResponse value,
          $Res Function(_$_MovieSuggestionResponse) then) =
      __$$_MovieSuggestionResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String status, String statusMessage, MovieSuggestionData data});

  @override
  $MovieSuggestionDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$_MovieSuggestionResponseCopyWithImpl<$Res>
    extends _$MovieSuggestionResponseCopyWithImpl<$Res,
        _$_MovieSuggestionResponse>
    implements _$$_MovieSuggestionResponseCopyWith<$Res> {
  __$$_MovieSuggestionResponseCopyWithImpl(_$_MovieSuggestionResponse _value,
      $Res Function(_$_MovieSuggestionResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? statusMessage = null,
    Object? data = null,
  }) {
    return _then(_$_MovieSuggestionResponse(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      statusMessage: null == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as MovieSuggestionData,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$_MovieSuggestionResponse implements _MovieSuggestionResponse {
  const _$_MovieSuggestionResponse(
      {required this.status, required this.statusMessage, required this.data});

  factory _$_MovieSuggestionResponse.fromJson(Map<String, dynamic> json) =>
      _$$_MovieSuggestionResponseFromJson(json);

  @override
  final String status;
  @override
  final String statusMessage;
  @override
  final MovieSuggestionData data;

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MovieSuggestionResponseCopyWith<_$_MovieSuggestionResponse>
      get copyWith =>
          __$$_MovieSuggestionResponseCopyWithImpl<_$_MovieSuggestionResponse>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MovieSuggestionResponseToJson(
      this,
    );
  }
}

abstract class _MovieSuggestionResponse implements MovieSuggestionResponse {
  const factory _MovieSuggestionResponse(
      {required final String status,
      required final String statusMessage,
      required final MovieSuggestionData data}) = _$_MovieSuggestionResponse;

  factory _MovieSuggestionResponse.fromJson(Map<String, dynamic> json) =
      _$_MovieSuggestionResponse.fromJson;

  @override
  String get status;
  @override
  String get statusMessage;
  @override
  MovieSuggestionData get data;
  @override
  @JsonKey(ignore: true)
  _$$_MovieSuggestionResponseCopyWith<_$_MovieSuggestionResponse>
      get copyWith => throw _privateConstructorUsedError;
}

MovieSuggestionData _$MovieSuggestionDataFromJson(Map<String, dynamic> json) {
  return _MovieSuggestionData.fromJson(json);
}

/// @nodoc
mixin _$MovieSuggestionData {
  int get movieCount => throw _privateConstructorUsedError;
  List<Movie>? get movies => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MovieSuggestionDataCopyWith<MovieSuggestionData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieSuggestionDataCopyWith<$Res> {
  factory $MovieSuggestionDataCopyWith(
          MovieSuggestionData value, $Res Function(MovieSuggestionData) then) =
      _$MovieSuggestionDataCopyWithImpl<$Res, MovieSuggestionData>;
  @useResult
  $Res call({int movieCount, List<Movie>? movies});
}

/// @nodoc
class _$MovieSuggestionDataCopyWithImpl<$Res, $Val extends MovieSuggestionData>
    implements $MovieSuggestionDataCopyWith<$Res> {
  _$MovieSuggestionDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? movieCount = null,
    Object? movies = freezed,
  }) {
    return _then(_value.copyWith(
      movieCount: null == movieCount
          ? _value.movieCount
          : movieCount // ignore: cast_nullable_to_non_nullable
              as int,
      movies: freezed == movies
          ? _value.movies
          : movies // ignore: cast_nullable_to_non_nullable
              as List<Movie>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MovieSuggestionDataCopyWith<$Res>
    implements $MovieSuggestionDataCopyWith<$Res> {
  factory _$$_MovieSuggestionDataCopyWith(_$_MovieSuggestionData value,
          $Res Function(_$_MovieSuggestionData) then) =
      __$$_MovieSuggestionDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int movieCount, List<Movie>? movies});
}

/// @nodoc
class __$$_MovieSuggestionDataCopyWithImpl<$Res>
    extends _$MovieSuggestionDataCopyWithImpl<$Res, _$_MovieSuggestionData>
    implements _$$_MovieSuggestionDataCopyWith<$Res> {
  __$$_MovieSuggestionDataCopyWithImpl(_$_MovieSuggestionData _value,
      $Res Function(_$_MovieSuggestionData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? movieCount = null,
    Object? movies = freezed,
  }) {
    return _then(_$_MovieSuggestionData(
      movieCount: null == movieCount
          ? _value.movieCount
          : movieCount // ignore: cast_nullable_to_non_nullable
              as int,
      movies: freezed == movies
          ? _value._movies
          : movies // ignore: cast_nullable_to_non_nullable
              as List<Movie>?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$_MovieSuggestionData extends _MovieSuggestionData {
  const _$_MovieSuggestionData(
      {required this.movieCount, final List<Movie>? movies = const []})
      : _movies = movies,
        super._();

  factory _$_MovieSuggestionData.fromJson(Map<String, dynamic> json) =>
      _$$_MovieSuggestionDataFromJson(json);

  @override
  final int movieCount;
  final List<Movie>? _movies;
  @override
  @JsonKey()
  List<Movie>? get movies {
    final value = _movies;
    if (value == null) return null;
    if (_movies is EqualUnmodifiableListView) return _movies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MovieSuggestionDataCopyWith<_$_MovieSuggestionData> get copyWith =>
      __$$_MovieSuggestionDataCopyWithImpl<_$_MovieSuggestionData>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MovieSuggestionDataToJson(
      this,
    );
  }
}

abstract class _MovieSuggestionData extends MovieSuggestionData {
  const factory _MovieSuggestionData(
      {required final int movieCount,
      final List<Movie>? movies}) = _$_MovieSuggestionData;
  const _MovieSuggestionData._() : super._();

  factory _MovieSuggestionData.fromJson(Map<String, dynamic> json) =
      _$_MovieSuggestionData.fromJson;

  @override
  int get movieCount;
  @override
  List<Movie>? get movies;
  @override
  @JsonKey(ignore: true)
  _$$_MovieSuggestionDataCopyWith<_$_MovieSuggestionData> get copyWith =>
      throw _privateConstructorUsedError;
}

MovieResponse _$MovieResponseFromJson(Map<String, dynamic> json) {
  return _MovieResponse.fromJson(json);
}

/// @nodoc
mixin _$MovieResponse {
  String get status => throw _privateConstructorUsedError;
  String get statusMessage => throw _privateConstructorUsedError;
  MovieData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MovieResponseCopyWith<MovieResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieResponseCopyWith<$Res> {
  factory $MovieResponseCopyWith(
          MovieResponse value, $Res Function(MovieResponse) then) =
      _$MovieResponseCopyWithImpl<$Res, MovieResponse>;
  @useResult
  $Res call({String status, String statusMessage, MovieData data});

  $MovieDataCopyWith<$Res> get data;
}

/// @nodoc
class _$MovieResponseCopyWithImpl<$Res, $Val extends MovieResponse>
    implements $MovieResponseCopyWith<$Res> {
  _$MovieResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? statusMessage = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      statusMessage: null == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as MovieData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MovieDataCopyWith<$Res> get data {
    return $MovieDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_MovieResponseCopyWith<$Res>
    implements $MovieResponseCopyWith<$Res> {
  factory _$$_MovieResponseCopyWith(
          _$_MovieResponse value, $Res Function(_$_MovieResponse) then) =
      __$$_MovieResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String status, String statusMessage, MovieData data});

  @override
  $MovieDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$_MovieResponseCopyWithImpl<$Res>
    extends _$MovieResponseCopyWithImpl<$Res, _$_MovieResponse>
    implements _$$_MovieResponseCopyWith<$Res> {
  __$$_MovieResponseCopyWithImpl(
      _$_MovieResponse _value, $Res Function(_$_MovieResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? statusMessage = null,
    Object? data = null,
  }) {
    return _then(_$_MovieResponse(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      statusMessage: null == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as MovieData,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$_MovieResponse implements _MovieResponse {
  const _$_MovieResponse(
      {required this.status, required this.statusMessage, required this.data});

  factory _$_MovieResponse.fromJson(Map<String, dynamic> json) =>
      _$$_MovieResponseFromJson(json);

  @override
  final String status;
  @override
  final String statusMessage;
  @override
  final MovieData data;

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MovieResponseCopyWith<_$_MovieResponse> get copyWith =>
      __$$_MovieResponseCopyWithImpl<_$_MovieResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MovieResponseToJson(
      this,
    );
  }
}

abstract class _MovieResponse implements MovieResponse {
  const factory _MovieResponse(
      {required final String status,
      required final String statusMessage,
      required final MovieData data}) = _$_MovieResponse;

  factory _MovieResponse.fromJson(Map<String, dynamic> json) =
      _$_MovieResponse.fromJson;

  @override
  String get status;
  @override
  String get statusMessage;
  @override
  MovieData get data;
  @override
  @JsonKey(ignore: true)
  _$$_MovieResponseCopyWith<_$_MovieResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

MovieData _$MovieDataFromJson(Map<String, dynamic> json) {
  return _MovieData.fromJson(json);
}

/// @nodoc
mixin _$MovieData {
  Movie get movie => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MovieDataCopyWith<MovieData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieDataCopyWith<$Res> {
  factory $MovieDataCopyWith(MovieData value, $Res Function(MovieData) then) =
      _$MovieDataCopyWithImpl<$Res, MovieData>;
  @useResult
  $Res call({Movie movie});

  $MovieCopyWith<$Res> get movie;
}

/// @nodoc
class _$MovieDataCopyWithImpl<$Res, $Val extends MovieData>
    implements $MovieDataCopyWith<$Res> {
  _$MovieDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? movie = null,
  }) {
    return _then(_value.copyWith(
      movie: null == movie
          ? _value.movie
          : movie // ignore: cast_nullable_to_non_nullable
              as Movie,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MovieCopyWith<$Res> get movie {
    return $MovieCopyWith<$Res>(_value.movie, (value) {
      return _then(_value.copyWith(movie: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_MovieDataCopyWith<$Res> implements $MovieDataCopyWith<$Res> {
  factory _$$_MovieDataCopyWith(
          _$_MovieData value, $Res Function(_$_MovieData) then) =
      __$$_MovieDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Movie movie});

  @override
  $MovieCopyWith<$Res> get movie;
}

/// @nodoc
class __$$_MovieDataCopyWithImpl<$Res>
    extends _$MovieDataCopyWithImpl<$Res, _$_MovieData>
    implements _$$_MovieDataCopyWith<$Res> {
  __$$_MovieDataCopyWithImpl(
      _$_MovieData _value, $Res Function(_$_MovieData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? movie = null,
  }) {
    return _then(_$_MovieData(
      movie: null == movie
          ? _value.movie
          : movie // ignore: cast_nullable_to_non_nullable
              as Movie,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$_MovieData extends _MovieData {
  const _$_MovieData({required this.movie}) : super._();

  factory _$_MovieData.fromJson(Map<String, dynamic> json) =>
      _$$_MovieDataFromJson(json);

  @override
  final Movie movie;

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MovieDataCopyWith<_$_MovieData> get copyWith =>
      __$$_MovieDataCopyWithImpl<_$_MovieData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MovieDataToJson(
      this,
    );
  }
}

abstract class _MovieData extends MovieData {
  const factory _MovieData({required final Movie movie}) = _$_MovieData;
  const _MovieData._() : super._();

  factory _MovieData.fromJson(Map<String, dynamic> json) =
      _$_MovieData.fromJson;

  @override
  Movie get movie;
  @override
  @JsonKey(ignore: true)
  _$$_MovieDataCopyWith<_$_MovieData> get copyWith =>
      throw _privateConstructorUsedError;
}
