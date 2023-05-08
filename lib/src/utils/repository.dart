import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/index.dart';

abstract class Repository {
  Apis get api;

  void dispose();
}

class MovieRepository extends Repository {
  late final MovieApi api;
  late final Urls urls;
  final Box<Movie> _favouritesBox;

  MovieRepository(this._favouritesBox) {
    urls = Urls();
    api = MovieApi(urls);
  }

  Future<MovieListData> listMovies(Uri url) async {
    try {
      final response = await api.listMovies(url);
      final data = await compute(Spawn.parseRawBody, response.body);
      if (data.movies == null) {
        throw const CustomException('No movies found 😥');
      }
      return data;
    } catch (e, s) {
      return errorHandler(e, s);
    }
  }

  Future<MovieListData> favouriteMovies([int? page]) async {
    try {
      final movies = _favouritesBox.values;

      if (movies.length == 0 || movies == null) {
        throw const CustomException('No movies found 😥');
      }
      return SynchronousFuture(MovieListData(
        limit: 1,
        movieCount: 1,
        movies: movies.toList(),
        pageNumber: 1,
      ));
    } catch (e, s) {
      return errorHandler(e, s);
    }
  }

  Future<MovieListData> listRawMovies([
    int? page,
    Map<String, dynamic>? params,
  ]) async {
    try {
      final response = await api.listMovieByrawParams(page, params);
      final data = await compute(Spawn.parseRawBody, response.body);
      if (data.movies == null) {
        throw const CustomException('No movies found 😥');
      }
      return data;
    } catch (e, s) {
      return errorHandler(e, s);
    }
  }

  Future<MovieListData> latestMovies([int? page, int? limit]) {
    return listMovies(urls.listMovies(limit: limit, page: page));
  }

  Future<MovieListData> hd4kMovies([int? page, int? limit]) {
    return listMovies(urls.listMovies(
      limit: limit,
      page: page,
      quality: Quality.$2160,
    ));
  }

  Future<MovieListData> ratedMovies([int? page, int? limit]) {
    return listMovies(urls.listMovies(
      limit: limit,
      page: page,
      sortBy: Sort.RATING,
      minimumRating: 5,
    ));
  }

  Future<MovieListData> mostDownloadedMovies([int? page, int? limit]) {
    return listMovies(urls.listMovies(
      limit: limit,
      page: page,
      sortBy: Sort.DOWNLOAD_COUNT,
    ));
  }

  Future<MovieListData> mostLikedMovies([int? page, int? limit]) {
    return listMovies(urls.listMovies(
      limit: limit,
      page: page,
      sortBy: Sort.LIKE_COUNT,
    ));
  }

  Future<MovieListData> thisYearMovies([int? page, int? limit]) {
    return listMovies(urls.listMovies(
      limit: limit,
      page: page,
      sortBy: Sort.YEAR,
    ));
  }

  Future<List<Movie>> movieSuggestions(String id) async {
    try {
      final response = await api.movieSuggestions(id);
      final movies = await compute(Spawn.parseResponseData, response.body);
      if (movies == null || movies.length == 0) {
        throw const CustomException('No movie found! 😥');
      }
      return movies;
    } catch (e, s) {
      return errorHandler(e, s);
    }
  }

  Future<Map<Query, MovieListData>> homePageMovies() async {
    try {
      final latest = await api.listMovies(urls.listMovies(limit: 10, page: 1));
      final hd = await api.listMovies(urls.listMovies(
        limit: 10,
        page: 1,
        quality: Quality.$2160,
      ));
      final year = await api.listMovies(urls.listMovies(
        limit: 10,
        page: 1,
        sortBy: Sort.YEAR,
      ));

      final Map<Query, String> params = {
        Query.latest: latest.body,
        Query.hd: hd.body,
        Query.year: year.body,
      };

      return await compute(_parseHomePageMovies, params);
    } catch (e, s) {
      return errorHandler(e, s);
    }
  }

  Future<Movie> movieDetails(int id) async {
    try {
      final response = await api.movieDetails('$id');
      final movie = await compute(Spawn.parseSingleMovie, response.body);
      return movie;
    } catch (e, s) {
      return errorHandler(e, s);
    }
  }

  static Map<Query, MovieListData> _parseHomePageMovies(
      Map<Query, String> param) {
    return param.map((key, body) {
      return MapEntry(key, Spawn.parseRawBody(body));
    });
  }

  @override
  void dispose() {
    api.dispose();
  }
}
