import 'package:freezed_annotation/freezed_annotation.dart';

part 'series_details.freezed.dart';
part 'series_details.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class SeriesDetails with _$SeriesDetails {
  const factory SeriesDetails({
    required bool adult,
    required String backdropPath,
    required List<CreatedBy> createdBy,
    required List<dynamic> episodeRunTime,
    required String firstAirDate,
    required List<Genre> genres,
    required String homepage,
    required int id,
    required bool inProduction,
    required List<String> languages,
    required String lastAirDate,
    LastEpisodeToAir? lastEpisodeToAir,
    required String name,
    Object? nextEpisodeToAir,
    required List<Network> networks,
    required int numberOfEpisodes,
    required int numberOfSeasons,
    required List<String> originCountry,
    required String originalLanguage,
    required String originalName,
    required String overview,
    required double popularity,
    required String posterPath,
    required List<ProductionCompanie> productionCompanies,
    required List<ProductionCountrie> productionCountries,
    required List<Season> seasons,
    required bool softcore,
    required List<SpokenLanguage> spokenLanguages,
    required String status,
    required String tagline,
    required String type,
    required double voteAverage,
    required int voteCount,
    Videos? videos,
    Images? images,
  }) = _SeriesDetails;

  factory SeriesDetails.fromJson(Map<String, dynamic> json) =>
      _$SeriesDetailsFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class CreatedBy with _$CreatedBy {
  const factory CreatedBy({
    required int id,
    required String creditId,
    required String name,
    required String originalName,
    required int gender,
    required String profilePath,
  }) = _CreatedBy;

  factory CreatedBy.fromJson(Map<String, dynamic> json) =>
      _$CreatedByFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class Genre with _$Genre {
  const factory Genre({
    required int id,
    required String name,
  }) = _Genre;

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class LastEpisodeToAir with _$LastEpisodeToAir {
  const factory LastEpisodeToAir({
    required int id,
    required String name,
    required String overview,
    required double voteAverage,
    required int voteCount,
    required String airDate,
    required int episodeNumber,
    required String episodeType,
    required String productionCode,
    required int runtime,
    required int seasonNumber,
    required int showId,
    required String stillPath,
  }) = _LastEpisodeToAir;

  factory LastEpisodeToAir.fromJson(Map<String, dynamic> json) =>
      _$LastEpisodeToAirFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class Network with _$Network {
  const factory Network({
    required int id,
    required String logoPath,
    required String name,
    required String originCountry,
  }) = _Network;

  factory Network.fromJson(Map<String, dynamic> json) =>
      _$NetworkFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class ProductionCompanie with _$ProductionCompanie {
  const factory ProductionCompanie({
    required int id,
    required String logoPath,
    required String name,
    required String originCountry,
  }) = _ProductionCompanie;

  factory ProductionCompanie.fromJson(Map<String, dynamic> json) =>
      _$ProductionCompanieFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class ProductionCountrie with _$ProductionCountrie {
  const factory ProductionCountrie({
    required String iso31661,
    required String name,
  }) = _ProductionCountrie;

  factory ProductionCountrie.fromJson(Map<String, dynamic> json) =>
      _$ProductionCountrieFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class Season with _$Season {
  const factory Season({
    required String airDate,
    required int episodeCount,
    required int id,
    required String name,
    required String overview,
    required String posterPath,
    required int seasonNumber,
    required int voteAverage,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class SpokenLanguage with _$SpokenLanguage {
  const factory SpokenLanguage({
    required String englishName,
    required String iso6391,
    required String name,
  }) = _SpokenLanguage;

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) =>
      _$SpokenLanguageFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class Videos with _$Videos {
  const factory Videos({
    required List<Result> results,
  }) = _Videos;

  factory Videos.fromJson(Map<String, dynamic> json) => _$VideosFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class Result with _$Result {
  const factory Result({
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
  }) = _Result;

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class Images with _$Images {
  const factory Images({
    required List<Backdrop> backdrops,
    required List<Logo> logos,
    required List<Poster> posters,
  }) = _Images;

  factory Images.fromJson(Map<String, dynamic> json) => _$ImagesFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class Backdrop with _$Backdrop {
  const factory Backdrop({
    required double aspectRatio,
    required int height,
    Object? iso31661,
    Object? iso6391,
    required String filePath,
    required double voteAverage,
    required int voteCount,
    required int width,
  }) = _Backdrop;

  factory Backdrop.fromJson(Map<String, dynamic> json) =>
      _$BackdropFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class Logo with _$Logo {
  const factory Logo({
    required double aspectRatio,
    required int height,
    required String iso31661,
    required String iso6391,
    required String filePath,
    required double voteAverage,
    required int voteCount,
    required int width,
  }) = _Logo;

  factory Logo.fromJson(Map<String, dynamic> json) => _$LogoFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class Poster with _$Poster {
  const factory Poster({
    required double aspectRatio,
    required int height,
    required String iso31661,
    required String iso6391,
    required String filePath,
    required int voteAverage,
    required int voteCount,
    required int width,
  }) = _Poster;

  factory Poster.fromJson(Map<String, dynamic> json) => _$PosterFromJson(json);
}
