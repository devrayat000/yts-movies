import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytsmovies/src/models/tmdb/genre.dart';

part 'movie_details.freezed.dart';
part 'movie_details.g.dart';

@Freezed(toStringOverride: true, fromJson: true, toJson: false)
abstract class MovieDetailsResponse with _$MovieDetailsResponse {
  @JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
  const factory MovieDetailsResponse({
    required int id,
    required String imdbId,
    required String title,
    required bool adult,
    required String backdropPath,
    // Object? belongsToCollection,
    // required int budget,
    required List<Genre> genres,
    // required String homepage,
    required List<String> originCountry,
    required String originalLanguage,
    required String originalTitle,
    required String overview,
    // required double popularity,
    required String posterPath,
    // required List<ProductionCompanie> productionCompanies,
    // required List<ProductionCountrie> productionCountries,
    required String releaseDate,
    // required int revenue,
    required int runtime,
    // required bool softcore,
    // required List<SpokenLanguage> spokenLanguages,
    required String status,
    required String tagline,
    // required bool video,
    // required double voteAverage,
    // required int voteCount,
    Videos? videos,
    ExternalIds? externalIds,
  }) = _MovieDetailsResponse;

  factory MovieDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailsResponseFromJson(json);
}

// @Freezed(fromJson: true, toJson: true)
// abstract class ProductionCompanie with _$ProductionCompanie {
//   @JsonSerializable(fieldRename: FieldRename.snake)
//   const factory ProductionCompanie({
//     required int id,
//     required String logoPath,
//     required String name,
//     required String originCountry,
//   }) = _ProductionCompanie;

//   factory ProductionCompanie.fromJson(Map<String, dynamic> json) =>
//       _$ProductionCompanieFromJson(json);
// }

// @Freezed(fromJson: true, toJson: true)
// abstract class ProductionCountrie with _$ProductionCountrie {
//   @JsonSerializable(fieldRename: FieldRename.snake)
//   const factory ProductionCountrie({
//     required String iso31661,
//     required String name,
//   }) = _ProductionCountrie;

//   factory ProductionCountrie.fromJson(Map<String, dynamic> json) =>
//       _$ProductionCountrieFromJson(json);
// }

// @Freezed(fromJson: true, toJson: true)
// abstract class SpokenLanguage with _$SpokenLanguage {
//   @JsonSerializable(fieldRename: FieldRename.snake)
//   const factory SpokenLanguage({
//     required String englishName,
//     required String iso6391,
//     required String name,
//   }) = _SpokenLanguage;

//   factory SpokenLanguage.fromJson(Map<String, dynamic> json) =>
//       _$SpokenLanguageFromJson(json);
// }

@Freezed(fromJson: true, toJson: false)
abstract class Videos with _$Videos {
  @JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
  const factory Videos({
    required List<VideoResult> results,
  }) = _Videos;

  factory Videos.fromJson(Map<String, dynamic> json) => _$VideosFromJson(json);
}

@Freezed(fromJson: true, toJson: false)
abstract class VideoResult with _$VideoResult {
  @JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
  const factory VideoResult({
    required String iso6391,
    required String iso31661,
    required String name,
    required String key,
    required String site,
    required int size,
    required String type,
    required bool official,
    required String id,
    required String publishedAt,
  }) = _VideoResult;

  factory VideoResult.fromJson(Map<String, dynamic> json) =>
      _$VideoResultFromJson(json);
}

@Freezed(fromJson: true, toJson: false)
abstract class ExternalIds with _$ExternalIds {
  @JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
  const factory ExternalIds({
    String? imdbId,
    String? wikidataId,
    String? facebookId,
    String? instagramId,
    String? twitterId,
  }) = _ExternalIds;

  factory ExternalIds.fromJson(Map<String, dynamic> json) =>
      _$ExternalIdsFromJson(json);
}

// Movie List
MovieDetailsResponse deserializeMovieDetailsResponse(
        Map<String, dynamic> json) =>
    MovieDetailsResponse.fromJson(json);
