import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../database/mamu_db.dart';
import '../models/movie.dart';
import '../utils/exceptions.dart';

class FavouriteMamus extends Mamus with ChangeNotifier {
  final db = MamuDB();
  List<String> _fabouriteMoviesId = [];

  // Public methods
  @mustCallSuper
  Future<void> init() async {
    try {
      await db.open();
      final ids = await db.getMovieIds;
      print(ids);
      _fabouriteMoviesId = [...ids];
    } catch (e) {
      throw e;
    }
  }

  Future<void> like(Movie movie) async {
    _fabouriteMoviesId.add(movie.id);
    notifyListeners();
    try {
      await db.insert(movie);
    } catch (e) {
      throw e;
    }
  }

  Future<void> unlike(String id) async {
    _fabouriteMoviesId.remove(id);
    notifyListeners();
    try {
      await db.delete(id);
    } catch (e) {
      throw e;
    }
  }

  bool isLiked(String id) {
    return _fabouriteMoviesId.contains(id);
  }

  @override
  Future<void> pageRequesthandler(int page) async {
    try {
      print(page);
      await db.open();
      final movies = await db.getAll;
      _controller.add(PageState(
        list: movies,
        nextPage: ++page,
        isLast: true,
      ));
    } catch (e) {
      _controller.addError(e);
      print(e);
    }
  }

  @override
  Future<void> dispose() async {
    // await db.close();
    super.dispose();
  }

  Future<void> deleteDB() => db.deleteDB();
}

class SearchMamus extends Mamus {
  bool _searchInitiates = false;
  void search(Map<String, dynamic> params) {
    this._params = params;
    _searchInitiates = true;
  }

  @override
  Future<void> pageRequesthandler(int page) async {
    if (!_searchInitiates) {
      _controller.add(PageState(list: [], nextPage: 0));
      return;
    }
    await super.pageRequesthandler(page);
  }
}

class HDMamus extends Mamus {
  HDMamus()
      : _params = {'quality': '2160p'},
        super();

  @override
  final Map<String, dynamic> _params;
}

class LatestMamus extends Mamus {}

abstract class Mamus {
  final _controller = StreamController<PageState>();
  Map<String, dynamic> _params = {};

  // Public methods
  Future<void> pageRequesthandler(int page) async {
    print(this._params);
    print(page);
    try {
      final uri = Uri.https('yts.mx', '/api/v2/list_movies.json', {
        'page': page.toString(),
        ...this._params,
      });
      final data = await listMoviesSearch(uri);
      final movieCount = data['movie_count'] as int;
      final limit = data['limit'] as int;
      final pages = (movieCount / limit).ceil();
      final isLastPage = page >= pages;

      final jsonMovies = data['movies'] as List?;

      if (jsonMovies == null) {
        throw NotFoundException('No movies were found');
      }

      final movies = await compute(parseMovies, jsonMovies);
      _controller.add(PageState(
        list: movies,
        nextPage: ++page,
        isLast: isLastPage,
      ));
    } catch (e) {
      _controller.addError(e);
      print(e);
    }
  }

  Future<Map<String, dynamic>> listMoviesSearch(Uri url) async {
    try {
      final response = await http.get(url);
      final respData = await compute(decodeJson, response.body);
      return respData['data'] as Map<String, dynamic>;
    } catch (e) {
      throw e;
    }
  }

  void dispose() {
    _controller.close();
  }

  // Public getters
  Stream<PageState> get state => _controller.stream.distinct();
}

class PageState {
  final List<Movie> list;
  final int nextPage;
  final bool isLast;
  const PageState(
      {required this.list, required this.nextPage, this.isLast = false});
}

List<Movie> parseMovies(List movies) {
  return movies.map((e) => Movie.fromJSON(e)).toList();
}

dynamic decodeJson(String body) => jsonDecode(body);
