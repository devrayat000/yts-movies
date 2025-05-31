import 'dart:async';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retrofit/retrofit.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/index.dart' hide Query;

part 'movies.g.dart';

@RestApi(
  baseUrl: "https://yts.mx/api/v2",
  parser: Parser.FlutterCompute,
)
abstract class MoviesClient {
  factory MoviesClient(Dio dio, {String baseUrl}) = _MoviesClient;

  @GET('/list_movies.json')
  @CancelRequest()
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
    @Queries() Map<String, dynamic>? queries,
    @CancelRequest() CancelToken? token,
  });

  @GET('/movie_details.json')
  @CacheControl(maxAge: 864000) // 10 days
  Future<MovieResponse> getMovieByid(
    @Query('movie_id') String id, {
    @Query('with_image') bool? image,
    @Query('with_cast') bool? cast,
    @CancelRequest() CancelToken? token,
  });

  @GET('/movie_suggestions.json')
  Future<MovieSuggestionResponse> getMovieSuggestions(
      @Query('movie_id') String id,
      {@CancelRequest() CancelToken? token});
}

class MoviesClientCubit extends Cubit<MoviesClient> {
  MoviesClientCubit() : super(MoviesClient(Dio())) {
    if (kDebugMode) {
      debugPrint('MoviesClientCubit initialized');
    }
  }

  void setClient(MoviesClient client) {
    if (kDebugMode) {
      debugPrint('Setting new MoviesClient');
    }
    emit(client);
  }

  @override
  Future<void> close() {
    if (kDebugMode) {
      debugPrint('MoviesClientCubit closed');
    }
    return super.close();
  }
}
