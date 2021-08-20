import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:ytsmovies/mock/cover_image.dart';
import 'package:ytsmovies/mock/torrent.dart';
import 'package:ytsmovies/utils/constants.dart';

part 'movie.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 1, adapterName: 'MovieAdapter')
class Movie with EquatableMixin, HiveObjectMixin {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int year;

  @HiveField(18)
  final double rating;

  @HiveField(3)
  final String backgroundImage;

  @HiveField(4)
  final String url;

  @HiveField(5)
  final String imdbCode;

  @HiveField(6)
  final String language;

  @HiveField(7)
  final String mpaRating;

  @HiveField(8)
  final String descriptionFull;

  @HiveField(9)
  final String synopsis;

  @HiveField(10)
  final int runtime;

  @HiveField(11)
  final List<String> genres;

  @HiveField(12)
  final List<Torrent> torrents;

  @HiveField(13)
  final String smallCoverImage;

  @HiveField(14)
  final String mediumCoverImage;

  @HiveField(15)
  final String? largeCoverImage;

  @HiveField(16)
  final DateTime? dateUploaded;

  @HiveField(17)
  @JsonKey(name: 'yt_trailer_code')
  final String? trailer;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.backgroundImage,
    required this.url,
    required this.imdbCode,
    required this.language,
    required this.mpaRating,
    required this.descriptionFull,
    required this.synopsis,
    required this.runtime,
    required this.genres,
    required this.torrents,
    required this.smallCoverImage,
    required this.mediumCoverImage,
    this.largeCoverImage,
    this.trailer,
    DateTime? dateUploaded,
  }) : this.dateUploaded = dateUploaded ?? DateTime.now();

  factory Movie.fromJson(Map<String, dynamic> data) => _$MovieFromJson(data);

  Map<String, dynamic> toJson() => _$MovieToJson(this);

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
