import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytsmovies/src/models/cover_image.dart';
import 'package:ytsmovies/src/models/torrent.dart';

part 'movie.g.dart';
part 'movie.freezed.dart';

@Freezed(equal: true, toStringOverride: true, copyWith: false)
sealed class Movie with _$Movie {
  const Movie._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Movie({
    required int id,
    required String title,
    int? year,
    required String backgroundImage,
    required String url,
    required String imdbCode,
    required String language,
    String? mpaRating,
    required String descriptionFull,
    String? descriptionIntro,
    String? synopsis,
    required int runtime,
    required List<String> genres,
    required List<Torrent> torrents,
    required String smallCoverImage,
    required String mediumCoverImage,
    String? largeCoverImage,
    DateTime? dateUploaded,
    @JsonKey(name: 'yt_trailer_code') String? trailer,
    required double rating,
  }) = _Movie;

  factory Movie.fromJson(Map<String, dynamic> data) => _$MovieFromJson(data);

  CoverImage get coverImage => CoverImage(
        small: smallCoverImage,
        medium: mediumCoverImage,
        large: largeCoverImage,
      );

  List<String> get quality {
    return torrents.map((e) => e.quality).toSet().toList(growable: false);
  }
}
