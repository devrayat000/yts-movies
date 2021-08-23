// import 'package:async/async.dart';
import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:ytsmovies/src/bloc/filter/index.dart';
import 'package:ytsmovies/src/utils/constants.dart';
import 'package:ytsmovies/src/utils/error_handler.dart';
import 'package:ytsmovies/src/utils/exceptions.dart';
import 'package:ytsmovies/src/utils/repository.dart';
import 'package:ytsmovies/src/widgets/search/animation.dart';
import 'package:ytsmovies/src/widgets/search/suggestions.dart';
import 'package:ytsmovies/src/mock/movie_data.dart';
import 'package:ytsmovies/src/mock/movie.dart';

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  final MovieRepository _repo;
  MovieSearchDelegate(this._repo);

  final _controller = PagingController<int, Movie>(firstPageKey: 1);
  final _box = Hive.box<String>(MyBoxs.searchHistoryBox);
  // final _prefs = SharedPreferences.getInstance();

  Map<String, dynamic> _params = {};
  CancelableOperation<MovieData>? _subscriber;
  CancelableOperation<List<Movie>>? _subscriber2;
  Timer? _debouncer;

  List<String> get _history => _box.values.toSet().toList().reversed.toList();

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
          duration: Duration(milliseconds: 300),
          child: query.trim().isEmpty ? null : Icon(Icons.clear),
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
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  Future<void> showResults(BuildContext context) async {
    // _controller.appendPage(_cachedMovies.toList(), 2);
    try {
      _controller.removePageRequestListener(_pagehandler);
      _params = context.read<Filter>().values;
      print(_params);
      _controller.addPageRequestListener(_pagehandler);
      await _setHistory();
      super.showResults(context);
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  void _pagehandler(int pageKey) async {
    try {
      final _data = await _moviesFuture(pageKey);
      print(_data.movies);
      if (_data.isLastPage) {
        _controller.appendLastPage(_data.movies!.toList());
      } else {
        _controller.appendPage(_data.movies!.toList(), ++pageKey);
      }
    } catch (e) {
      _controller.error = e;
    }
  }

  @override
  void showSuggestions(BuildContext context) async {
    try {
      _subscriber2?.cancel();
      _debouncer?.cancel();
      // _debouncer = null;
      _subscriber2 = CancelableOperation.fromFuture(_firstMovies, onCancel: () {
        print('cancelled');
      });
      print('fun');
    } catch (e) {
      print(e);
    } finally {
      // _debouncer = Timer(Duration(milliseconds: 500), () {
      super.showSuggestions(context);
      // });
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchResultPage(
      controller: _controller,
      onFiltered: () async {
        try {
          _params = context.read<Filter>().values;
          print(_params);
          _controller.refresh();
          await showResults(context);
        } catch (e) {
          print(e);
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _subscriber2?.cancel();
    _subscriber2 = CancelableOperation.fromFuture(_firstMovies, onCancel: () {
      print('cancelled');
    });
    print(_subscriber2.runtimeType);
    return SearchSuggestions(
      future: query.trim().isEmpty
          ? Future.value(_history)
          : (_subscriber2?.value ?? Future.value(_history)),
      onShowHistory: (i) async {
        try {
          query = _history[i];
          await showResults(context);
        } catch (e) {
          print(e);
        }
      },
      onTap: () => _setHistory(),
    );
  }

  Future<MovieData> _moviesFuture(int page) async {
    try {
      final _movieData = await _repo.listRawMovies(page, {
        'query_term': query.trim(),
        ..._params,
      });
      return _movieData;
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
      final _newHistory = query.trim();
      if (_history.contains(_newHistory)) {
        await Future.wait([
          _box.deleteAt(_history.indexOf(_newHistory)),
          _box.add(_newHistory),
        ]);
      } else {
        await _box.add(_newHistory);
      }
    } on HiveError catch (e, s) {
      print(e);
      print(s);
      throw CustomException(e.message, e.stackTrace);
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
}
