import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytsmovies/mock/movie.dart';

part 'movie_data.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@immutable
class MovieData with EquatableMixin {
  final int movieCount;
  final int limit;
  final int pageNumber;
  final List<Movie>? movies;

  MovieData({
    required this.limit,
    required this.movieCount,
    required this.movies,
    required this.pageNumber,
  });

  factory MovieData.fromJson(Map<String, dynamic> json) =>
      _$MovieDataFromJson(json);

  Map<String, dynamic> toJson() => _$MovieDataToJson(this);

  int get lastPage => (movieCount / limit).ceil();

  bool get isLastPage => pageNumber >= lastPage;

  @override
  List<Object?> get props => [movieCount, limit, pageNumber, movies];

  @override
  bool? get stringify => true;
}
