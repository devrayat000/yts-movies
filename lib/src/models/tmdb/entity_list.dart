import 'package:freezed_annotation/freezed_annotation.dart';

part 'entity_list.freezed.dart';
part 'entity_list.g.dart';

@Freezed(toStringOverride: true, fromJson: true, toJson: false)
abstract class Entity with _$Entity {
  @JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
  const factory Entity({
    required int id,
    required bool adult,
    required String backdropPath,
    required List<int> genreIds,
    required String originalLanguage,
    required String originalTitle,
    required String overview,
    // required double popularity,
    required String posterPath,
    required String releaseDate,
    required String title,
    // required bool video,
    // required double voteAverage,
    // required int voteCount,
  }) = _Entity;

  factory Entity.fromJson(Map<String, dynamic> json) => _$EntityFromJson(json);
}

@Freezed(toStringOverride: true, fromJson: true, toJson: false)
abstract class EntityListResponse with _$EntityListResponse {
  @JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
  const factory EntityListResponse({
    required int page,
    required List<Entity> results,
    required int totalResults,
    required int totalPages,
  }) = _EntityListResponse;

  factory EntityListResponse.fromJson(Map<String, dynamic> json) =>
      _$EntityListResponseFromJson(json);
}

// Entity List
EntityListResponse deserializeEntityListResponse(Map<String, dynamic> json) =>
    EntityListResponse.fromJson(json);
