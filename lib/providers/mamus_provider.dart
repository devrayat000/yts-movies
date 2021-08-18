import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/api.dart';
import '../utils/isolates.dart';
// import '../database/mamu_db.dart';
import '../mock/movie.dart';
import '../utils/exceptions.dart';

typedef Resolver = Future<http.Response> Function([int? page]);

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
      print(e);
    }
  }

  Future<void> like(Movie movie) async {
    _fabouriteMoviesId.add(movie.id.toString());
    notifyListeners();
    try {
      await db.insert(movie);
    } catch (e) {
      print(e);
    }
  }

  Future<void> unlike(String id) async {
    _fabouriteMoviesId.remove(id);
    notifyListeners();
    try {
      await db.delete(id);
    } catch (e) {
      print(e);
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
    try {
      await db.close();
      super.dispose();
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteDB() => db.deleteDB();
}

class SearchMamus extends Mamus {
  bool _searchInitiated = false;
  void search(Map<String, dynamic> params) {
    this._resolver = ([int? page]) => Api.listMovieByrawParams(page, params);
    _searchInitiated = true;
  }

  @override
  Future<void> pageRequesthandler(int page) async {
    if (!_searchInitiated) {
      _controller.add(PageState(list: [], nextPage: 0));
      return;
    }
    try {
      await super.pageRequesthandler(page);
    } catch (e) {
      _controller.addError(e);
    }
  }
}

class HDMamus extends Mamus {
  HDMamus()
      : _resolver = Api.hd4kMovies,
        super();

  @override
  final Resolver _resolver;
}

class RatedMamus extends Mamus {
  RatedMamus() : super();

  @override
  Resolver get _resolver => Api.ratedMovies;
}

class LatestMamus extends Mamus {
  LatestMamus() : super();

  @override
  Resolver get _resolver => Api.latestMovies;
}

abstract class Mamus {
  final _controller = StreamController<PageState>();
  Resolver _resolver = Api.latestMovies;

  // Public methods
  Future<void> pageRequesthandler(int page) async {
    print(page);
    try {
      final data = await listMoviesSearch(page);
      final movieCount = data['movie_count'] as int;
      final limit = data['limit'] as int;
      final pages = (movieCount / limit).ceil();
      final isLastPage = page >= pages;

      final jsonMovies = data['movies'] as List?;

      if (jsonMovies == null) {
        throw NotFoundException('No movies were found');
      }

      final movies = await compute(Spawn.parseMovies, jsonMovies);
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

  Future<Map<String, dynamic>> listMoviesSearch([int? page]) async {
    try {
      final response = await this._resolver(page);
      final respData = await compute(Spawn.decodeJson, response.body);
      return respData['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
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
