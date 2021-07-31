import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:ytsmovies/models/movie.dart';
import 'package:ytsmovies/pages/movie.dart';
import 'package:ytsmovies/providers/view_provider.dart';
import 'package:ytsmovies/widgets/buttons/grid_list_toggle.dart';
import 'package:ytsmovies/widgets/cards/actionbar.dart';
import 'package:ytsmovies/widgets/cards/movie_card.dart';
import 'package:ytsmovies/widgets/image.dart';

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  final _controller = PagingController<int, Movie>(firstPageKey: 1);
  final _scrollController = ScrollController();
  Iterable<Movie> _cachedMovies = [];

  MovieSearchDelegate() {
    _controller.addPageRequestListener((pageKey) async {
      try {
        final _movies = await _moviesFuture(pageKey);
        _controller.appendPage(_movies.toList(), ++pageKey);
      } catch (e) {
        _controller.error = e;
      }
    });
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: null,
        icon: Icon(Icons.clear),
      )
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
  void showResults(BuildContext context) {
    _controller.appendPage(_cachedMovies.toList(), 2);
    super.showResults(context);
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
            PagedSliverGrid<int, Movie>(
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
          ],
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<Iterable<Movie>>(
      future: _firstMovies,
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
            Text(
              'No movies found',
              style: Theme.of(context).textTheme.headline4,
            );
          }
          return ListView.separated(
            itemBuilder: (context, i) {
              final _movie = movies!.toList()[i];
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
            },
            separatorBuilder: (context, i) => Divider(),
            itemCount: movies!.length,
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

  Future<Iterable<Movie>> get _firstMovies {
    return _moviesFuture(1).then<Iterable<Movie>>((parsedMovies) {
      _cachedMovies = parsedMovies;
      return parsedMovies.take(7);
    });
  }

  String _runtimeFormat(Movie _movie) {
    final _duration = Duration(minutes: _movie.runtime);
    final hour = _duration.inHours;
    final mins = _duration.inMinutes.remainder(60);
    return '$hour h $mins min';
  }
}
