import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/utils/enums.dart';
import 'package:ytsmovies/src/widgets/movies_list.dart';

class LatestMoviesPage extends StatelessWidget {
  static const routeName = '/latest-movies';
  const LatestMoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MoviesList(
      label: 'latest',
      handler: (page) => context.read<MoviesClient>().getMovieList(page: page),
      appBar: AppBar(
        title: Text(
          'Latest Movies',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }
}

class HD4KMoviesPage extends StatelessWidget {
  static const routeName = '/hd4k-movies';
  const HD4KMoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MoviesList(
      label: '4k',
      handler: (page) => context.read<MoviesClient>().getMovieList(
            page: page,
            quality: Quality.$2160,
          ),
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
  const RatedMoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MoviesList(
      label: 'rated',
      handler: (page) => context.read<MoviesClient>().getMovieList(
            page: page,
            minimumRating: 5,
          ),
      appBar: AppBar(
        title: Text(
          'Highly Rated Movies',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }
}
