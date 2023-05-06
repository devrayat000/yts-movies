import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/utils/enums.dart';
import 'package:ytsmovies/src/widgets/index.dart';

class LatestMoviesPage extends StatelessWidget {
  static const routeName = '/latest-movies';
  const LatestMoviesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MamuMovieListpage(
      label: 'latest',
      handler: (page) =>
          context.read<MoviesListService>().getMovieList(page: page),
      appBar: AppBar(
        title: Text(
          'Latest Movies',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      actions: [],
    );
  }
}

class HD4KMoviesPage extends StatelessWidget {
  static const routeName = '/hd4k-movies';
  const HD4KMoviesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MamuMovieListpage(
      label: '4k',
      handler: (page) => context.read<MoviesListService>().getMovieList(
            page: page,
            quality: Quality.$2160,
          ),
      actions: [],
      appBar: AppBar(
        title: Text(
          '4K Movies',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }
}

class RatedMoviesPage extends StatelessWidget {
  static const routeName = '/rated-movies';
  const RatedMoviesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MamuMovieListpage(
      label: 'rated',
      handler: (page) => context.read<MoviesListService>().getMovieList(
            page: page,
            minimumRating: 5,
          ),
      actions: [],
      appBar: AppBar(
        title: Text(
          'Highly Rated Movies',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }
}
