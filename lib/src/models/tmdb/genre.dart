import 'package:freezed_annotation/freezed_annotation.dart';

part 'genre.g.dart';
part 'genre.freezed.dart';

@Freezed(
    equal: true,
    toStringOverride: true,
    copyWith: false,
    fromJson: true,
    toJson: true)
sealed class Genre with _$Genre {
  const factory Genre({
    required int id,
    required String name,
  }) = _Genre;

  factory Genre.fromJson(Map<String, dynamic> data) => _$GenreFromJson(data);
}

@Freezed(toStringOverride: true, fromJson: true, toJson: true)
sealed class GenreListResponse with _$GenreListResponse {
  const factory GenreListResponse({
    required List<Genre> genres,
  }) = _GenreListResponse;

  factory GenreListResponse.fromJson(Map<String, dynamic> data) =>
      _$GenreListResponseFromJson(data);
}

// Movie Suggestion
GenreListResponse deserializeGenreListResponse(Map<String, dynamic> json) =>
    GenreListResponse.fromJson(json);
Map<String, dynamic> serializeGenreListResponse(GenreListResponse object) =>
    object.toJson();
