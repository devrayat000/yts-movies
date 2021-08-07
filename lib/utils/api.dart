import 'package:http/http.dart' as http;

import 'enums.dart';
import 'urls.dart';

class Api {
  static final client = http.Client();

  static Future<http.Response> listMovies(Uri url) => client.get(url);

  static Future<http.Response> movieDetails(Uri url) => client.get(url);

  static Future<http.Response> movieSuggestions(String id) =>
      client.get(Urls.movieSuggestions(id));

  //
  static Future<http.Response> latestMovies([int? page, int? limit]) =>
      client.get(Urls.listMovies(limit: limit, page: page));

  static Future<http.Response> hd4kMovies([int? page, int? limit]) => client
      .get(Urls.listMovies(limit: limit, page: page, quality: Quality.$2160));

  static Future<http.Response> ratedMovies([int? page, int? limit]) =>
      client.get(Urls.listMovies(
          limit: limit, page: page, sortBy: Sort.RATING, minimumRating: 5));

  static Future<http.Response> mostDownloadedMovies([int? page, int? limit]) =>
      client.get(Urls.listMovies(
          limit: limit, page: page, sortBy: Sort.DOWNLOAD_COUNT));
          
  static Future<http.Response> mostLikedMovies([int? page, int? limit]) =>
      client.get(
          Urls.listMovies(limit: limit, page: page, sortBy: Sort.LIKE_COUNT));

  static Future<http.Response> listMovieByrawParams([
    int? page,
    Map<String, dynamic>? params,
  ]) =>
      client.get(Urls.listMoviesWithRawParams({
        'page': '$page',
        ...(params ?? {}),
      }));
}
