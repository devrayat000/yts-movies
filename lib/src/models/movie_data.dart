import 'dart:developer';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytsmovies/src/models/movie.dart';

part 'movie_data.g.dart';
part 'movie_data.freezed.dart';

// Movie List
MovieListResponse deserializeMovieListResponse(Map<String, dynamic> json) =>
    MovieListResponse.fromJson(json);
Map<String, dynamic> serializeMovieListResponse(MovieListResponse object) =>
    object.toJson();

@Freezed(equal: true, toStringOverride: true, copyWith: false)
sealed class MovieListResponse with _$MovieListResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MovieListResponse({
    required String status,
    required String statusMessage,
    required MovieListData data,
  }) = _MovieListResponse;

  factory MovieListResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieListResponseFromJson(json);
}

@Freezed(equal: true, toStringOverride: true, copyWith: false)
sealed class MovieListData with _$MovieListData {
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

  int get lastPage {
    log('Calculating last page for $movieCount movies with limit $limit');
    return (movieCount / limit).ceil();
  }

  bool get isLastPage => pageNumber >= lastPage;
}

// Movie Suggestion
MovieSuggestionResponse deserializeMovieSuggestionResponse(
        Map<String, dynamic> json) =>
    MovieSuggestionResponse.fromJson(json);
Map<String, dynamic> serializeMovieSuggestionResponse(
        MovieSuggestionResponse object) =>
    object.toJson();

@Freezed(equal: true, toStringOverride: true, copyWith: false)
sealed class MovieSuggestionResponse with _$MovieSuggestionResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MovieSuggestionResponse({
    required String status,
    required String statusMessage,
    required MovieSuggestionData data,
  }) = _MovieSuggestionResponse;

  factory MovieSuggestionResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieSuggestionResponseFromJson(json);
}

@Freezed(equal: true, toStringOverride: true, copyWith: false)
sealed class MovieSuggestionData with _$MovieSuggestionData {
  const MovieSuggestionData._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MovieSuggestionData({
    required int movieCount,
    @Default([]) List<Movie>? movies,
  }) = _MovieSuggestionData;

  factory MovieSuggestionData.fromJson(Map<String, dynamic> json) =>
      _$MovieSuggestionDataFromJson(json);
}

// Single Movie
MovieResponse deserializeMovieResponse(Map<String, dynamic> json) =>
    MovieResponse.fromJson(json);
Map<String, dynamic> serializeMovieResponse(MovieResponse object) =>
    object.toJson();

@Freezed(equal: true, toStringOverride: true, copyWith: false)
sealed class MovieResponse with _$MovieResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MovieResponse({
    required String status,
    required String statusMessage,
    required MovieData data,
  }) = _MovieResponse;

  factory MovieResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieResponseFromJson(json);
}

@Freezed(equal: true, toStringOverride: true, copyWith: false)
sealed class MovieData with _$MovieData {
  const MovieData._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MovieData({required Movie movie}) = _MovieData;

  factory MovieData.fromJson(Map<String, dynamic> json) =>
      _$MovieDataFromJson(json);
}
