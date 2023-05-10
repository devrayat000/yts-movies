import 'package:async/async.dart';
import 'package:http/http.dart' as http;

import 'urls.dart';

abstract class Apis {
  http.Client get client;

  Duration get timeout;

  void dispose();
}

class MovieApi extends Apis {
  final Urls urls;
  MovieApi(this.urls);
  @override
  final client = http.Client();

  @override
  final timeout = const Duration(seconds: 15);

  final _latestCache = AsyncCache<http.Response>(const Duration(hours: 1));
  final _hdCache = AsyncCache<http.Response>(const Duration(hours: 1));
  final _ratedCache = AsyncCache<http.Response>(const Duration(hours: 1));
  final _thisYearCache = AsyncCache<http.Response>(const Duration(hours: 1));

  Future<http.Response> listMovies(Uri url) {
    return client.get(url).timeout(timeout);
  }

  Future<http.Response> movieDetails(String id) =>
      client.get(urls.movieDetails(id)).timeout(timeout);

  Future<http.Response> movieSuggestions(String id) =>
      client.get(urls.movieSuggestions(id)).timeout(timeout);

  Future<http.Response> listMovieByrawParams([
    int? page,
    Map<String, dynamic>? params,
  ]) =>
      client
          .get(urls.listMoviesWithRawParams({
            'page': '$page',
            ...(params ?? {}),
          }))
          .timeout(timeout);

  @override
  void dispose() {
    _hdCache.invalidate();
    _latestCache.invalidate();
    _ratedCache.invalidate();
    _thisYearCache.invalidate();
  }
}
