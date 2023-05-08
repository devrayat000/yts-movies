// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movies.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$MoviesListService extends MoviesListService {
  _$MoviesListService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = MoviesListService;

  @override
  Future<Response<MovieListResponse>> getMovieList({
    int? limit = 10,
    int? page = 1,
    Quality? quality,
    int? minimumRating,
    String? queryTerm,
    String? genre,
    Sort? sortBy,
    Order? orderBy,
    bool? withRtRatings,
  }) {
    final Uri $url = Uri.parse('/api/v2/list_movies.json');
    final Map<String, dynamic> $params = <String, dynamic>{
      'limit': limit,
      'page': page,
      'quality': quality,
      'minimum_rating': minimumRating,
      'query_term': queryTerm,
      'genre': genre,
      'sort_by': sortBy,
      'order_by': orderBy,
      'with_rt_ratings': withRtRatings,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<MovieListResponse, MovieListResponse>($request);
  }

  @override
  Future<Response<MovieResponse>> getMovieByid(
    String id, {
    bool? image,
    bool? cast,
  }) {
    final Uri $url = Uri.parse('/api/v2/movie_details.json');
    final Map<String, dynamic> $params = <String, dynamic>{
      'movie_id': id,
      'with_image': image,
      'with_cast': cast,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<MovieResponse, MovieResponse>($request);
  }

  @override
  Future<Response<MovieListResponse>> getMovieSuggestions(String id) {
    final Uri $url = Uri.parse('/api/v2/movie_suggestions.json');
    final Map<String, dynamic> $params = <String, dynamic>{'movie_id': id};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<MovieListResponse, MovieListResponse>($request);
  }
}
