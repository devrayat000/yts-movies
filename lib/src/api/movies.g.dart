// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movies.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _MoviesClient implements MoviesClient {
  _MoviesClient(
    this._dio, {
    this.baseUrl,
  }) {
    baseUrl ??= 'https://yts.mx/api/v2';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<MovieListResponse> getMovieList({
    int? limit = 10,
    int? page = 1,
    Quality? quality,
    int? minimumRating,
    String? queryTerm,
    String? genre,
    Sort? sortBy,
    Order? orderBy,
    bool? withRtRatings,
  }) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'limit': limit,
      r'page': page,
      r'quality': await compute(serializeQuality, quality),
      r'minimum_rating': minimumRating,
      r'query_term': queryTerm,
      r'genre': genre,
      r'sort_by': await compute(serializeSort, sortBy),
      r'order_by': await compute(serializeOrder, orderBy),
      r'with_rt_ratings': withRtRatings,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<MovieListResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/list_movies.json',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = await compute(deserializeMovieListResponse, _result.data!);
    return value;
  }

  @override
  Future<MovieResponse> getMovieByid(
    String id, {
    bool? image,
    bool? cast,
  }) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'movie_id': id,
      r'with_image': image,
      r'with_cast': cast,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<MovieResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/movie_details.json',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = await compute(deserializeMovieResponse, _result.data!);
    return value;
  }

  @override
  Future<MovieListResponse> getMovieSuggestions(String id) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'movie_id': id};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio
        .fetch<Map<String, dynamic>>(_setStreamType<MovieListResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/movie_suggestions.json',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = await compute(deserializeMovieListResponse, _result.data!);
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
