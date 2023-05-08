import "dart:async";
import 'package:chopper/chopper.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/index.dart' show Quality, Sort, Order;

part 'movies.chopper.dart';

@ChopperApi(baseUrl: "/api/v2")
abstract class MoviesListService extends ChopperService {
  // A helper method that helps instantiating the service. You can omit this method and use the generated class directly instead.
  static MoviesListService create([ChopperClient? client]) =>
      _$MoviesListService(client);

  @Get(path: '/list_movies.json', includeNullQueryVars: false)
  Future<Response<MovieListResponse>> getMovieList({
    @Query() int? limit = 10,
    @Query() int? page = 1,
    @Query() Quality? quality,
    @Query('minimum_rating') int? minimumRating,
    @Query('query_term') String? queryTerm,
    @Query() String? genre,
    @Query('sort_by') Sort? sortBy,
    @Query('order_by') Order? orderBy,
    @Query('with_rt_ratings') bool? withRtRatings,
  });

  @Get(path: '/movie_details.json', includeNullQueryVars: false)
  Future<Response<MovieResponse>> getMovieByid(
    @Query('movie_id') String id, {
    @Query('with_image') bool? image,
    @Query('with_cast') bool? cast,
  });

  @Get(path: '/movie_suggestions.json', includeNullQueryVars: false)
  Future<Response<MovieListResponse>> getMovieSuggestions(
      @Query('movie_id') String id);
}
