import "dart:async";
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/index.dart' hide Query;

part 'movies.g.dart';

@RestApi(
  baseUrl: "https://yts.mx/api/v2",
  parser: Parser.FlutterCompute,
)
abstract class MoviesClient {
  // A helper method that helps instantiating the service. You can omit this method and use the generated class directly instead.
  factory MoviesClient(Dio dio, {String baseUrl}) = _MoviesClient;

  @GET('/list_movies.json')
  Future<MovieListResponse> getMovieList({
    @Query("limit") int? limit = 10,
    @Query("page") int? page = 1,
    @Query("quality") Quality? quality,
    @Query('minimum_rating') int? minimumRating,
    @Query('query_term') String? queryTerm,
    @Query("genre") String? genre,
    @Query('sort_by') Sort? sortBy,
    @Query('order_by') Order? orderBy,
    @Query('with_rt_ratings') bool? withRtRatings,
  });

  @GET('/movie_details.json')
  Future<MovieResponse> getMovieByid(
    @Query('movie_id') String id, {
    @Query('with_image') bool? image,
    @Query('with_cast') bool? cast,
  });

  @GET('/movie_suggestions.json')
  Future<MovieListResponse> getMovieSuggestions(@Query('movie_id') String id);
}
