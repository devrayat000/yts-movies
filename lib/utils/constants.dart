import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
// import 'package:http/http.dart';

import 'package:ytsmovies/mock/movie.dart';
import 'package:ytsmovies/utils/api.dart';
// import 'package:ytsmovies/utils/exceptions.dart';

enum Query {
  latest,
  hd,
  mostDownloaded,
  mostLiked,
  rated,
  year,
}

typedef Resolver = Future<Response> Function(int);

final Map<Query, Resolver> resolvers = {
  Query.latest: (limit) => Api.latestMovies(1, limit),
  Query.hd: (limit) => Api.hd4kMovies(1, limit),
  Query.mostDownloaded: (limit) => Api.mostDownloadedMovies(1, limit),
  Query.mostLiked: (limit) => Api.mostLikedMovies(1, limit),
  Query.rated: (limit) => Api.ratedMovies(1, limit),
  Query.year: (limit) => Api.thisYearMovies(1, limit),
};

final Map<Query, Map<String, dynamic>> parseQuery = {
  Query.latest: {},
  Query.hd: {'quality': '2160p'},
  Query.mostDownloaded: {'sort_by': 'download_count'},
  Query.mostLiked: {'sort_by': 'like_count'},
  Query.rated: {'sort_by': 'rating', 'minimum_rating': '5'},
};

class MyGlobals {
  static final bucket = PageStorageBucket();

  static const Widget kCircularLoading = const Center(
    child: CircularProgressIndicator.adaptive(),
  );

  static List<Movie> parseRawMovies(List<dynamic> data) {
    return data.map((item) => Movie.fromJson(item)).toList();
  }

  static Map<String, dynamic> parseResponse(String body) => jsonDecode(body);

  static List<Map<String, dynamic>> decodeMovies(List<Movie> movies) =>
      movies.map((movie) => movie.toJson()).toList();

  static List<Movie>? parseResponseData(String body) {
    final respData = parseResponse(body);
    final rawMovies = respData['data']['movies'];
    if (rawMovies is List) {
      return rawMovies.map((e) => Movie.fromJson(e)).toList();
    } else {
      return null;
    }
  }
}

class MyBoxs {
  static const favouriteBox = 'favourites';
  static const searchHistoryBox = 'searchHistory';
}

class Col {
  static const id = 'id';
  static const title = 'title';
  static const year = 'year';
  static const rating = 'rating';
  static const dateUploaded = 'date_uploaded';
  static const url = 'url';
  static const imdbCode = 'imdb_code';
  static const language = 'language';
  static const mpaRating = 'mpa_rating';
  static const descriptionFull = 'description_full';
  static const synopsis = 'synopsis';
  static const trailer = 'yt_trailer_code';
  static const runtime = 'runtime';
  static const smallImage = 'small_cover_image';
  static const mediumImage = 'medium_cover_image';
  static const largeImage = 'large_cover_image';
  static const hash = 'hash';
  static const quality = 'quality';
  static const type = 'type';
  static const seeds = 'seeds';
  static const peers = 'peers';
  static const size = 'size';
  static const magnet = 'magnet';
  static const backgroundImage = 'background_image';
}
