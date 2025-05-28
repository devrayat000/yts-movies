library app_widget.search;

import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:ytsmovies/src/api/movies.dart';

import 'package:ytsmovies/src/widgets/index.dart';
import 'package:ytsmovies/src/bloc/filter/index.dart';
import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/models/index.dart';

part 'suggestions.dart';
part 'results.dart';
part 'animation.dart';

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  final MoviesClient repo;
  MovieSearchDelegate({required this.repo});

  // final _controller = PagingController<int, Movie>(firstPageKey: 1);
  Box<String> get _box => Hive.box<String>(MyBoxs.searchHistoryBox);

  Map<String, dynamic> _params = {};
  CancelToken? _cancelToken;

  List<String> get _history => _box.values.toSet().toList().reversed.toList();
  @override
  set query(String value) {
    if (value != super.query) {
      super.query = value;
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.trim().isNotEmpty) {
            query = '';
            showSuggestions(context);
          }
        },
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: query.trim().isEmpty ? null : const Icon(Icons.clear),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  Future<void> showResults(BuildContext context) async {
    try {
      log("Showing search results for query: $query");
      _params = context.read<Filter>().values;
      super.showResults(context);
      await _setHistory();
    } catch (e, s) {
      log("Error showing results: $e", error: e, stackTrace: s);
      log(e.toString(), error: e, stackTrace: s);
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    log("Building search results for query: $query");
    return MoviesPagedView(
      handler: (page) => repo.getMovieList(
        page: page,
        queryTerm: query,
        queries: _params,
      ),
      noItemBuilder: (context) => Center(
        child: Text(
          'No results found for "$query"',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _cancelToken?.cancel();

    return SearchSuggestions(
      history: _history,
      future: query.trim().isEmpty ? null : _firstMovies,
      onShowHistory: (i) async {
        try {
          query = _history[i];
          await showResults(context);
        } catch (e, s) {
          log(e.toString(), error: e, stackTrace: s);
        }
      },
      onTap: () => _setHistory(),
    );
  }

  Future<MovieListData> _moviesFuture(int page) async {
    try {
      _cancelToken = CancelToken();
      final movieData = await repo.getMovieList(
        page: page,
        queryTerm: query,
        queries: _params,
        token: _cancelToken,
      );
      return movieData.data;
    } catch (e, s) {
      return errorHandler(e, s);
    }
  }

  Future<List<Movie>> get _firstMovies {
    return _moviesFuture(1).then<List<Movie>>((parsedMovies) {
      return parsedMovies.movies!.take(10).toList();
    }).catchError((e) => throw e);
  }

  Future<void> _setHistory() async {
    try {
      _box.values.contains(query.trim());
      final newHistory = query.trim();
      if (_history.contains(newHistory)) {
        await Future.wait([
          _box.deleteAt(_history.indexOf(newHistory)),
          _box.add(newHistory),
        ]);
      } else {
        await _box.add(newHistory);
      }
    } on HiveError catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      throw CustomException(e.message, e.stackTrace);
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
    }
  }
}
