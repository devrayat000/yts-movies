import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytsmovies/src/models/movie.dart';

part 'movie_data.g.dart';
part 'movie_data.freezed.dart';

@Freezed(equal: false, toStringOverride: false)
class MovieListData with _$MovieListData, EquatableMixin {
  const MovieListData._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MovieListData({
    required int movieCount,
    required int limit,
    required int pageNumber,
    @Default([]) List<Movie>? movies,
  }) = _MovieListData;

  factory MovieListData.fromJson(Map<String, dynamic> json) =>
      _$MovieListDataFromJson(json);

  int get lastPage => (movieCount / limit).ceil();

  bool get isLastPage => pageNumber >= lastPage;

  @override
  List<Object?> get props => [movieCount, limit, pageNumber, movies];

  @override
  bool? get stringify => true;
}

@Freezed(equal: false, toStringOverride: false)
class MovieData with _$MovieData, EquatableMixin {
  const MovieData._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MovieData({required Movie movie}) = _MovieData;

  factory MovieData.fromJson(Map<String, dynamic> json) =>
      _$MovieDataFromJson(json);

  @override
  List<Object?> get props => [movie];

  @override
  bool? get stringify => true;
}

MovieListResponse deserializeMovieListResponse(Map<String, dynamic> json) =>
    MovieListResponse.fromJson(json);
Map<String, dynamic> serializeMovieListResponse(MovieListResponse object) =>
    object.toJson();

@Freezed(equal: false, toStringOverride: false)
class MovieListResponse with _$MovieListResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MovieListResponse({
    required String status,
    required String statusMessage,
    required MovieListData data,
  }) = _MovieListResponse;

  factory MovieListResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieListResponseFromJson(json);
}

MovieResponse deserializeMovieResponse(Map<String, dynamic> json) =>
    MovieResponse.fromJson(json);
Map<String, dynamic> serializeMovieResponse(MovieResponse object) =>
    object.toJson();

@Freezed(equal: false, toStringOverride: false)
class MovieResponse with _$MovieResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MovieResponse({
    required String status,
    required String statusMessage,
    required MovieData data,
  }) = _MovieResponse;

  factory MovieResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieResponseFromJson(json);
}
