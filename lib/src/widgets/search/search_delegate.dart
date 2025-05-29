library app_widget.search;

import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
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
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.textTheme.bodyLarge?.color),
        titleTextStyle: theme.textTheme.titleLarge,
        toolbarHeight: 56, // Standard YouTube search bar height
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: Colors.grey[600],
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            width: 0.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            width: 0.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            width: 0.0,
          ),
        ),
        // YouTube-style thin search input with proper vertical padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4, // Reduced vertical padding for thinner appearance
        ),
        isDense: true, // Makes the field more compact
        fillColor: theme.inputDecorationTheme.fillColor,
        filled: true,
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Search movies...';

  @override
  TextStyle get searchFieldStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.2, // Tighter line height for thinner appearance
      );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      // Clear button (YouTube style)
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: const Icon(Icons.clear),
          tooltip: 'Clear',
        ),

      // Filter button (YouTube style)
      IconButton(
        onPressed: () {
          FilterBottomSheet.show(
            context,
            onApplyFilter: () {
              _params = context.read<Filter>().values;
              if (query.trim().isNotEmpty) {
                showResults(context);
              }
            },
          );
        },
        icon: const Icon(Icons.tune),
        tooltip: 'Filter',
      ),

      const SizedBox(width: 8),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Back',
    );
  }

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
      handler: (page) async {
        final response = await repo.getMovieList(
          page: page,
          queryTerm: query,
          queries: _params,
        );
        return response;
      },
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

  Future<MovieListResponse> _moviesFuture(int page) async {
    try {
      _cancelToken = CancelToken();
      final movieData = await repo.getMovieList(
        page: page,
        queryTerm: query,
        queries: _params,
        token: _cancelToken,
      );
      return movieData;
    } catch (e, s) {
      return errorHandler(e, s);
    }
  }

  Future<List<Movie>> get _firstMovies {
    return _moviesFuture(1).then<List<Movie>>((parsedMovies) {
      return parsedMovies.data.movies!.take(10).toList();
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
