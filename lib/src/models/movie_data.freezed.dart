// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MovieListResponse {
  String get status;
  String get statusMessage;
  MovieListData get data;

  /// Serializes this MovieListResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MovieListResponse &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, statusMessage, data);

  @override
  String toString() {
    return 'MovieListResponse(status: $status, statusMessage: $statusMessage, data: $data)';
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MovieListResponse implements MovieListResponse {
  const _MovieListResponse(
      {required this.status, required this.statusMessage, required this.data});
  factory _MovieListResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieListResponseFromJson(json);

  @override
  final String status;
  @override
  final String statusMessage;
  @override
  final MovieListData data;

  @override
  Map<String, dynamic> toJson() {
    return _$MovieListResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MovieListResponse &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, statusMessage, data);

  @override
  String toString() {
    return 'MovieListResponse(status: $status, statusMessage: $statusMessage, data: $data)';
  }
}

/// @nodoc
mixin _$MovieListData {
  int get movieCount;
  int get limit;
  int get pageNumber;
  List<Movie>? get movies;

  /// Serializes this MovieListData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MovieListData &&
            (identical(other.movieCount, movieCount) ||
                other.movieCount == movieCount) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            const DeepCollectionEquality().equals(other.movies, movies));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, movieCount, limit, pageNumber,
      const DeepCollectionEquality().hash(movies));

  @override
  String toString() {
    return 'MovieListData(movieCount: $movieCount, limit: $limit, pageNumber: $pageNumber, movies: $movies)';
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MovieListData extends MovieListData {
  const _MovieListData(
      {required this.movieCount,
      required this.limit,
      required this.pageNumber,
      final List<Movie>? movies = const []})
      : _movies = movies,
        super._();
  factory _MovieListData.fromJson(Map<String, dynamic> json) =>
      _$MovieListDataFromJson(json);

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

  @override
  Map<String, dynamic> toJson() {
    return _$MovieListDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MovieListData &&
            (identical(other.movieCount, movieCount) ||
                other.movieCount == movieCount) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            const DeepCollectionEquality().equals(other._movies, _movies));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, movieCount, limit, pageNumber,
      const DeepCollectionEquality().hash(_movies));

  @override
  String toString() {
    return 'MovieListData(movieCount: $movieCount, limit: $limit, pageNumber: $pageNumber, movies: $movies)';
  }
}

/// @nodoc
mixin _$MovieSuggestionResponse {
  String get status;
  String get statusMessage;
  MovieSuggestionData get data;

  /// Serializes this MovieSuggestionResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MovieSuggestionResponse &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, statusMessage, data);

  @override
  String toString() {
    return 'MovieSuggestionResponse(status: $status, statusMessage: $statusMessage, data: $data)';
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MovieSuggestionResponse implements MovieSuggestionResponse {
  const _MovieSuggestionResponse(
      {required this.status, required this.statusMessage, required this.data});
  factory _MovieSuggestionResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieSuggestionResponseFromJson(json);

  @override
  final String status;
  @override
  final String statusMessage;
  @override
  final MovieSuggestionData data;

  @override
  Map<String, dynamic> toJson() {
    return _$MovieSuggestionResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MovieSuggestionResponse &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, statusMessage, data);

  @override
  String toString() {
    return 'MovieSuggestionResponse(status: $status, statusMessage: $statusMessage, data: $data)';
  }
}

/// @nodoc
mixin _$MovieSuggestionData {
  int get movieCount;
  List<Movie>? get movies;

  /// Serializes this MovieSuggestionData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MovieSuggestionData &&
            (identical(other.movieCount, movieCount) ||
                other.movieCount == movieCount) &&
            const DeepCollectionEquality().equals(other.movies, movies));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, movieCount, const DeepCollectionEquality().hash(movies));

  @override
  String toString() {
    return 'MovieSuggestionData(movieCount: $movieCount, movies: $movies)';
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MovieSuggestionData extends MovieSuggestionData {
  const _MovieSuggestionData(
      {required this.movieCount, final List<Movie>? movies = const []})
      : _movies = movies,
        super._();
  factory _MovieSuggestionData.fromJson(Map<String, dynamic> json) =>
      _$MovieSuggestionDataFromJson(json);

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

  @override
  Map<String, dynamic> toJson() {
    return _$MovieSuggestionDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MovieSuggestionData &&
            (identical(other.movieCount, movieCount) ||
                other.movieCount == movieCount) &&
            const DeepCollectionEquality().equals(other._movies, _movies));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, movieCount, const DeepCollectionEquality().hash(_movies));

  @override
  String toString() {
    return 'MovieSuggestionData(movieCount: $movieCount, movies: $movies)';
  }
}

/// @nodoc
mixin _$MovieResponse {
  String get status;
  String get statusMessage;
  MovieData get data;

  /// Serializes this MovieResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MovieResponse &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, statusMessage, data);

  @override
  String toString() {
    return 'MovieResponse(status: $status, statusMessage: $statusMessage, data: $data)';
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MovieResponse implements MovieResponse {
  const _MovieResponse(
      {required this.status, required this.statusMessage, required this.data});
  factory _MovieResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieResponseFromJson(json);

  @override
  final String status;
  @override
  final String statusMessage;
  @override
  final MovieData data;

  @override
  Map<String, dynamic> toJson() {
    return _$MovieResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MovieResponse &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, statusMessage, data);

  @override
  String toString() {
    return 'MovieResponse(status: $status, statusMessage: $statusMessage, data: $data)';
  }
}

/// @nodoc
mixin _$MovieData {
  Movie get movie;

  /// Serializes this MovieData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MovieData &&
            (identical(other.movie, movie) || other.movie == movie));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, movie);

  @override
  String toString() {
    return 'MovieData(movie: $movie)';
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MovieData extends MovieData {
  const _MovieData({required this.movie}) : super._();
  factory _MovieData.fromJson(Map<String, dynamic> json) =>
      _$MovieDataFromJson(json);

  @override
  final Movie movie;

  @override
  Map<String, dynamic> toJson() {
    return _$MovieDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MovieData &&
            (identical(other.movie, movie) || other.movie == movie));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, movie);

  @override
  String toString() {
    return 'MovieData(movie: $movie)';
  }
}

// dart format on
