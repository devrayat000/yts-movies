import 'dart:async';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:ytsmovies/src/models/tmdb/genre.dart';
import 'package:ytsmovies/src/models/tmdb/movie.dart';
import 'package:ytsmovies/src/models/tmdb/movie_details.dart';
import 'package:ytsmovies/src/utils/index.dart' hide Query;

part 'tmdb.g.dart';

const tmdbApiKey = String.fromEnvironment('TMDB_API_KEY', defaultValue: '');

@JsonEnum(valueField: 'value')
enum TMDBMovieType {
  nowPlaying('now_playing'),
  popular('popular'),
  topRated('top_rated'),
  upcoming('upcoming');

  final String value;
  const TMDBMovieType(this.value);

  String toString() => value;
}

String? serializeTMDBSortBy(TMDBSortBy? object) => object?.value;

@JsonEnum(valueField: 'value')
enum TMDBSortBy {
  popularityDesc('popularity.desc'),
  popularityAsc('popularity.asc'),
  releaseDateDesc('primary_release_date.desc'),
  releaseDateAsc('primary_release_date.asc'),
  originalTitleDesc('original_title.desc'),
  originalTitleAsc('original_title.asc'),
  titleDesc('title.desc'),
  titleAsc('title.asc'),
  ;

  final String value;
  const TMDBSortBy(this.value);

  String toString() => value;
}

String? serializeTMDBMovieType(TMDBMovieType? object) => object?.value;

@RestApi(
  baseUrl: "https://api.themoviedb.org/3",
  parser: Parser.FlutterCompute,
  headers: {'authorization': 'Bearer $tmdbApiKey'},
)
abstract class TMDBMovieClient {
  factory TMDBMovieClient(Dio dio, {String baseUrl}) = _TMDBMovieClient;

  @GET('/discover/movie')
  @CacheControl(maxAge: 86400) // 1 day
  Future<MovieListResponse> discover({
    @Query("page") int? page = 1,
    @Query('include_adult') bool? includeAdult,
    @Query('sort_by') TMDBSortBy? sortBy,
    @Query('year') int? year,
    @Queries() Map<String, dynamic>? queries,
    @CancelRequest() CancelToken? token,
  });

  @GET('/movie/{movie_type}')
  @CacheControl(maxAge: 86400) // 1 day
  Future<MovieListResponse> discoverByType(
    @Path('movie_type') TMDBMovieType movieType, {
    @Query("page") int? page = 1,
    @Queries() Map<String, dynamic>? queries,
    @CancelRequest() CancelToken? token,
  });

  @GET('/genre/movie/list')
  Future<GenreListResponse> genres({
    @CancelRequest() CancelToken? token,
  });

  @GET('/movie/{movie_id}')
  Future<MovieDetailsResponse> details(
    @Path('movie_id') int movieId, {
    @CancelRequest() CancelToken? token,
  });
}
