import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:ytsmovies/src/models/cover_image.dart';
import 'package:ytsmovies/src/models/torrent.dart';
import 'package:ytsmovies/src/utils/constants.dart';

part 'movie.g.dart';
part 'movie.freezed.dart';

@Freezed(equal: false, toStringOverride: false)
class Movie with _$Movie, EquatableMixin, HiveObjectMixin {
  Movie._();

  @HiveType(typeId: 1, adapterName: 'MovieAdapter')
  @JsonSerializable(fieldRename: FieldRename.snake)
  factory Movie({
    @HiveField(0) required int id,
    @HiveField(1) required String title,
    @HiveField(18) required double rating,
    @HiveField(3) required String backgroundImage,
    @HiveField(4) required String url,
    @HiveField(5) required String imdbCode,
    @HiveField(6) required String language,
    @HiveField(8) required String descriptionFull,
    @HiveField(10) required int runtime,
    @HiveField(11) required List<String> genres,
    @HiveField(12) required List<Torrent> torrents,
    @HiveField(13) required String smallCoverImage,
    @HiveField(14) required String mediumCoverImage,
    @HiveField(2) int? year,
    @HiveField(9) @JsonKey(name: 'description_intro') String? synopsis,
    @HiveField(7) String? mpaRating,
    @HiveField(15) String? largeCoverImage,
    @HiveField(17) @JsonKey(name: 'yt_trailer_code') String? trailer,
    @HiveField(16) DateTime? dateUploaded,
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

  @override
  List<Object?> get props => [
        id,
        title,
        year,
        rating,
        backgroundImage,
        dateUploaded,
        url,
        imdbCode,
        language,
        mpaRating,
        descriptionFull,
        synopsis,
        runtime,
        genres,
        torrents,
        coverImage,
        trailer,
      ];

  @override
  bool? get stringify => true;

  @override
  BoxBase<Movie>? get box => Hive.box(MyBoxs.favouriteBox);

  @override
  int get key => id;
}

class MovieArg {
  final Movie movie;
  MovieArg(this.movie);
}
