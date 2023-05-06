import 'dart:convert';
import 'dart:isolate';

import 'package:ytsmovies/src/models/movie.dart';
import 'package:ytsmovies/src/models/movie_data.dart';

class Spawn {
  static List<Movie> parseMovies(List movies) {
    return movies.map((e) => Movie.fromJson(e)).toList();
  }

  static Map<String, dynamic> decodeJson(String body) => jsonDecode(body);

  static MovieListData parseRawBody(String body) {
    final respData = jsonDecode(body);
    final data = respData['data'];
    return MovieListData.fromJson(data as Map<String, dynamic>);
  }

  static Movie parseSingleMovie(String body) {
    final respData = jsonDecode(body);
    final data = respData['data'];
    return Movie.fromJson(data['movie'] as Map<String, dynamic>);
  }

  static List<Movie>? parseResponseData(String body) {
    final respData = Spawn.decodeJson(body);
    final rawMovies = respData['data']['movies'];
    if (rawMovies is List) {
      return rawMovies.map((e) => Movie.fromJson(e)).toList();
    } else {
      return null;
    }
  }
}

void iso() async {
  var a = await Isolate.spawn((message) {}, 'message');
  final cap = a.pause(a.pauseCapability);
  a.resume(cap);
}
