import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/movie.dart';
import '../../pages/movie.dart';
import '../../providers/view_provider.dart';
import '../buttons/grid_list_toggle.dart';
import '../cards/actionbar.dart';
import '../cards/movie_card.dart';
import '../image.dart';

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  final _controller = PagingController<int, Movie>(firstPageKey: 1);
  final _scrollController = ScrollController();
  final _prefs = SharedPreferences.getInstance();

  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  // Iterable<Movie> _cachedMovies = [];

  static const _historyKey = 'search-history';

  MovieSearchDelegate() {
    // _controller.addPageRequestListener((pageKey) async {
    //   try {
    //     final _movies = await _moviesFuture(pageKey);
    //     _controller.appendPage(_movies.toList(), ++pageKey);
    //   } catch (e) {
    //     _controller.error = e;
    //   }
    // });
  }

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
          duration: Duration(milliseconds: 200),
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
      _controller.addPageRequestListener((pageKey) async {
        try {
          final _movies = await _moviesFuture(pageKey);
          _controller.appendPage(_movies.toList(), ++pageKey);
        } catch (e) {
          _controller.error = e;
        }
      });
      await _setHistory(query);
      super.showResults(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoScrollbar(
        controller: _scrollController,
        child: CustomScrollView(
          slivers: [
            SliverActionBar(
              floating: true,
              snap: true,
              actions: [
                IconButton(
                  onPressed: () {
                    context
                        .findAncestorStateOfType<ScaffoldState>()
                        ?.openEndDrawer();
                  },
                  icon: const Icon(Icons.filter_alt_outlined),
                  splashRadius: 20,
                ),
                GridListToggle(controller: _scrollController),
              ],
            ),
            Builder(
              builder: (context) => PagedSliverGrid<int, Movie>(
                pagingController: _controller,
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (context, movie, i) => MovieCard(
                    movie: movie,
                  ),
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.watch<GridListView>().crossAxis,
                  childAspectRatio: context.watch<GridListView>().aspectRatio,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Object>?>(
      future: query.isEmpty ? _history : _firstMovies,
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            snapshot.error.toString(),
            style: Theme.of(context).textTheme.headline4,
          );
        } else if (snapshot.hasData) {
          final movies = snapshot.data;
          if (movies == null) {
            if (query.isNotEmpty) {
              return Text(
                'No movies found',
                style: Theme.of(context).textTheme.headline4,
              );
            }
            return Text('Search for movies');
          }
          return ListView.separated(
            itemBuilder: (context, i) {
              final _movie = movies[i];
              if (_movie is Movie) {
                return ListTile(
                  leading: MovieImage(src: _movie.coverImg.small),
                  title: Text(_movie.title),
                  subtitle: Text(
                      LocaleNames.of(context)?.nameOf(_movie.language) ??
                          'English'),
                  trailing: Text(_runtimeFormat(_movie)),
                  onTap: () {
                    Navigator.pushNamed(context, MoviePage.routeName);
                  },
                );
              }
              return ListTile(
                key: ValueKey(_movie as String),
                leading: Icon(Icons.history),
                title: Text(_movie),
                trailing: Icon(Icons.find_in_page),
                onTap: () {
                  try {
                    query = _movie;
                    showResults(context);
                  } catch (e) {
                    print(e);
                  }
                },
              );
            },
            separatorBuilder: (context, i) => Divider(),
            itemCount: movies.length,
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<Iterable<Movie>> _moviesFuture(int page) {
    final uri = Uri.https('yts.mx', '/api/v2/list_movies.json', {
      'query_term': query,
      'page': page.toString(),
    });
    return http.get(uri).then<Iterable<Movie>>((response) {
      final respData = jsonDecode(response.body);
      final movies = respData['data']['movies'] as List;
      return movies.map((e) => Movie.fromJSON(e));
    });
  }

  Future<List<Movie>> get _firstMovies {
    return _moviesFuture(1).then<List<Movie>>((parsedMovies) {
      // _cachedMovies = parsedMovies;
      return parsedMovies.take(10).toList();
    });
  }

  Future<List<String>?> get _history async {
    try {
      final prefs = await _prefs;
      return prefs.getStringList(_historyKey);
    } catch (e) {
      throw e;
    }
  }

  Future<void> _setHistory(String searchHistory) async {
    try {
      final prefs = await _prefs;
      final prevHistory = prefs.getStringList(_historyKey) ?? [];
      prefs.setStringList(_historyKey, [searchHistory, ...prevHistory]);
    } catch (e) {
      throw e;
    }
  }

  String _runtimeFormat(Movie _movie) {
    final _duration = Duration(minutes: _movie.runtime);
    final hour = _duration.inHours;
    final mins = _duration.inMinutes.remainder(60);
    return '$hour h $mins min';
  }
}
