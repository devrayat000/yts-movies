// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieListData _$MovieListDataFromJson(Map<String, dynamic> json) =>
    MovieListData(
      limit: json['limit'] as int,
      movieCount: json['movie_count'] as int,
      movies: (json['movies'] as List<dynamic>?)
          ?.map((e) => Movie.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: json['page_number'] as int,
    );

Map<String, dynamic> _$MovieListDataToJson(MovieListData instance) =>
    <String, dynamic>{
      'movie_count': instance.movieCount,
      'limit': instance.limit,
      'page_number': instance.pageNumber,
      'movies': instance.movies?.map((e) => e.toJson()).toList(),
    };

MovieData _$MovieDataFromJson(Map<String, dynamic> json) => MovieData(
      movie: Movie.fromJson(json['movie'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MovieDataToJson(MovieData instance) => <String, dynamic>{
      'movie': instance.movie.toJson(),
    };

MovieListResponse _$MovieListResponseFromJson(Map<String, dynamic> json) =>
    MovieListResponse(
      status: json['status'] as String,
      statusMessage: json['status_message'] as String,
      data: MovieListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MovieListResponseToJson(MovieListResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'status_message': instance.statusMessage,
      'data': instance.data.toJson(),
    };

MovieResponse _$MovieResponseFromJson(Map<String, dynamic> json) =>
    MovieResponse(
      status: json['status'] as String,
      statusMessage: json['status_message'] as String,
      data: MovieData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MovieResponseToJson(MovieResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'status_message': instance.statusMessage,
      'data': instance.data.toJson(),
    };
