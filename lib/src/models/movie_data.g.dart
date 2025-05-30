// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MovieListResponse _$MovieListResponseFromJson(Map<String, dynamic> json) =>
    _MovieListResponse(
      status: json['status'] as String,
      statusMessage: json['status_message'] as String,
      data: MovieListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MovieListResponseToJson(_MovieListResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'status_message': instance.statusMessage,
      'data': instance.data.toJson(),
    };

_MovieListData _$MovieListDataFromJson(Map<String, dynamic> json) =>
    _MovieListData(
      movieCount: (json['movie_count'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      pageNumber: (json['page_number'] as num).toInt(),
      movies: (json['movies'] as List<dynamic>?)
              ?.map((e) => Movie.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MovieListDataToJson(_MovieListData instance) =>
    <String, dynamic>{
      'movie_count': instance.movieCount,
      'limit': instance.limit,
      'page_number': instance.pageNumber,
      'movies': instance.movies?.map((e) => e.toJson()).toList(),
    };

_MovieSuggestionResponse _$MovieSuggestionResponseFromJson(
        Map<String, dynamic> json) =>
    _MovieSuggestionResponse(
      status: json['status'] as String,
      statusMessage: json['status_message'] as String,
      data: MovieSuggestionData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MovieSuggestionResponseToJson(
        _MovieSuggestionResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'status_message': instance.statusMessage,
      'data': instance.data.toJson(),
    };

_MovieSuggestionData _$MovieSuggestionDataFromJson(Map<String, dynamic> json) =>
    _MovieSuggestionData(
      movieCount: (json['movie_count'] as num).toInt(),
      movies: (json['movies'] as List<dynamic>?)
              ?.map((e) => Movie.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MovieSuggestionDataToJson(
        _MovieSuggestionData instance) =>
    <String, dynamic>{
      'movie_count': instance.movieCount,
      'movies': instance.movies?.map((e) => e.toJson()).toList(),
    };

_MovieResponse _$MovieResponseFromJson(Map<String, dynamic> json) =>
    _MovieResponse(
      status: json['status'] as String,
      statusMessage: json['status_message'] as String,
      data: MovieData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MovieResponseToJson(_MovieResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'status_message': instance.statusMessage,
      'data': instance.data.toJson(),
    };

_MovieData _$MovieDataFromJson(Map<String, dynamic> json) => _MovieData(
      movie: Movie.fromJson(json['movie'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MovieDataToJson(_MovieData instance) =>
    <String, dynamic>{
      'movie': instance.movie.toJson(),
    };
