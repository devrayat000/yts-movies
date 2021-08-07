import 'dart:convert';

import 'package:ytsmovies/models/movie.dart';

class Spawn {
  static const _movieId = 'movieId';

  static Future<List<Movie>> parseDatabaseMovies(
      Map<String, dynamic> data) async {
    final movies = data['movies'] as List;
    final torrents = data['torrents'] as List;
    final genres = data['genres'] as List;

    return movies.map((movie) {
      var newMovie = {}..addAll(movie);
      newMovie['torrents'] =
          torrents.where((t) => t[_movieId] == newMovie['id']).toList();
      newMovie['genres'] = genres
          .where((g) => g[_movieId] == newMovie['id'])
          .map((g) => g['genre'])
          .toList();
      return Movie.fromJSON(newMovie);
    }).toList();
  }

  static List<Movie> parseMovies(List movies) {
    return movies.map((e) => Movie.fromJSON(e)).toList();
  }

  static Map<String, dynamic> decodeJson(String body) => jsonDecode(body);

  static List<Movie>? parseRawBody(String body) {
    final respData = jsonDecode(body);
    final movies = respData['data']['movies'] as List?;
    return movies?.map((e) => Movie.fromJSON(e)).toList(growable: false);
  }
}
