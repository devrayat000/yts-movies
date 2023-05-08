import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytsmovies/src/models/movie.dart';

part 'movie_data.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@immutable
class MovieListData with EquatableMixin {
  final int movieCount;
  final int limit;
  final int pageNumber;
  final List<Movie>? movies;

  const MovieListData({
    required this.limit,
    required this.movieCount,
    required this.movies,
    required this.pageNumber,
  });

  factory MovieListData.fromJson(Map<String, dynamic> json) =>
      _$MovieListDataFromJson(json);

  Map<String, dynamic> toJson() => _$MovieListDataToJson(this);

  int get lastPage => (movieCount / limit).ceil();

  bool get isLastPage => pageNumber >= lastPage;

  @override
  List<Object?> get props => [movieCount, limit, pageNumber, movies];

  @override
  bool? get stringify => true;
}

@JsonSerializable(fieldRename: FieldRename.snake)
@immutable
class MovieData with EquatableMixin {
  final Movie movie;

  const MovieData({
    required this.movie,
  });

  factory MovieData.fromJson(Map<String, dynamic> json) =>
      _$MovieDataFromJson(json);

  Map<String, dynamic> toJson() => _$MovieDataToJson(this);

  @override
  List<Object?> get props => [movie];

  @override
  bool? get stringify => true;
}

@JsonSerializable(fieldRename: FieldRename.snake)
@immutable
class MovieListResponse {
  final String status;
  final String statusMessage;
  final MovieListData data;

  const MovieListResponse({
    required this.status,
    required this.statusMessage,
    required this.data,
  });

  factory MovieListResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MovieListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
@immutable
class MovieResponse {
  final String status;
  final String statusMessage;
  final MovieData data;

  const MovieResponse({
    required this.status,
    required this.statusMessage,
    required this.data,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MovieResponseToJson(this);
}
