// import 'package:async/async.dart';
import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:ytsmovies/bloc/filter/index.dart';
import 'package:ytsmovies/mock/movie_data.dart';
import 'package:ytsmovies/utils/api.dart';
import 'package:ytsmovies/utils/constants.dart';
import 'package:ytsmovies/utils/error_handler.dart';
import 'package:ytsmovies/utils/exceptions.dart';
import 'package:ytsmovies/utils/isolates.dart';
import 'package:ytsmovies/widgets/search/animation.dart';
import 'package:ytsmovies/widgets/search/suggestions.dart';
import '../../mock/movie.dart';

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  MovieSearchDelegate();

  final _controller = PagingController<int, Movie>(firstPageKey: 1);
  // final _prefs = SharedPreferences.getInstance();

  Map<String, dynamic> _params = {};
  CancelableOperation<Response>? _subscriber;
  Timer? _debouncer;

  List<String> get _history =>
      Hive.box<String>(MyBoxs.searchHistoryBox).values.toList();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isNotEmpty) {
            query = '';
          }
        },
        icon: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: query.isEmpty ? null : Icon(Icons.clear),
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
      _debouncer?.cancel();
      _subscriber?.cancel();
    } catch (e) {
      print(e);
    } finally {
      _debouncer = Timer(Duration(seconds: 1), () {
        super.showSuggestions(context);
      });
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
    return SearchSuggestions(
      history: _history,
      future: query.isEmpty ? null : _firstMovies,
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
      _subscriber = CancelableOperation.fromFuture(
          Api.listMovieByrawParams(page, {'query_term': query, ..._params}));
      final response = await _subscriber!.value;
      final data = await compute(Spawn.parseRawBody, response.body);

      if (data.movies == null) {
        throw CustomException('No movie found! 😥');
      } else {
        return data;
      }
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
      await Hive.box<String>(MyBoxs.searchHistoryBox).add(query);
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
