// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_MovieListResponse _$$_MovieListResponseFromJson(Map<String, dynamic> json) =>
    _$_MovieListResponse(
      status: json['status'] as String,
      statusMessage: json['status_message'] as String,
      data: MovieListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_MovieListResponseToJson(
        _$_MovieListResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'status_message': instance.statusMessage,
      'data': instance.data.toJson(),
    };

_$_MovieListData _$$_MovieListDataFromJson(Map<String, dynamic> json) =>
    _$_MovieListData(
      movieCount: json['movie_count'] as int,
      limit: json['limit'] as int,
      pageNumber: json['page_number'] as int,
      movies: (json['movies'] as List<dynamic>?)
              ?.map((e) => Movie.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_MovieListDataToJson(_$_MovieListData instance) =>
    <String, dynamic>{
      'movie_count': instance.movieCount,
      'limit': instance.limit,
      'page_number': instance.pageNumber,
      'movies': instance.movies?.map((e) => e.toJson()).toList(),
    };

_$_MovieSuggestionResponse _$$_MovieSuggestionResponseFromJson(
        Map<String, dynamic> json) =>
    _$_MovieSuggestionResponse(
      status: json['status'] as String,
      statusMessage: json['status_message'] as String,
      data: MovieSuggestionData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_MovieSuggestionResponseToJson(
        _$_MovieSuggestionResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'status_message': instance.statusMessage,
      'data': instance.data.toJson(),
    };

_$_MovieSuggestionData _$$_MovieSuggestionDataFromJson(
        Map<String, dynamic> json) =>
    _$_MovieSuggestionData(
      movieCount: json['movie_count'] as int,
      movies: (json['movies'] as List<dynamic>?)
              ?.map((e) => Movie.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_MovieSuggestionDataToJson(
        _$_MovieSuggestionData instance) =>
    <String, dynamic>{
      'movie_count': instance.movieCount,
      'movies': instance.movies?.map((e) => e.toJson()).toList(),
    };

_$_MovieResponse _$$_MovieResponseFromJson(Map<String, dynamic> json) =>
    _$_MovieResponse(
      status: json['status'] as String,
      statusMessage: json['status_message'] as String,
      data: MovieData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_MovieResponseToJson(_$_MovieResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'status_message': instance.statusMessage,
      'data': instance.data.toJson(),
    };

_$_MovieData _$$_MovieDataFromJson(Map<String, dynamic> json) => _$_MovieData(
      movie: Movie.fromJson(json['movie'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_MovieDataToJson(_$_MovieData instance) =>
    <String, dynamic>{
      'movie': instance.movie.toJson(),
    };
