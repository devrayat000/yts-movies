import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/src/bloc/api/index.dart';

import '../widgets/gas_page.dart';

class LatestMoviesPage extends StatelessWidget {
  static const routeName = '/latest-movies';
  const LatestMoviesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MamuMovieListpage<LatestApiCubit>(
      label: 'latest',
      handler: context.read<ApiProvider>().latestMovies,
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
    return MamuMovieListpage<HDApiCubit>(
      label: '4k',
      handler: context.read<ApiProvider>().hdMovies,
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
    return MamuMovieListpage<RatedApiCubit>(
      label: 'rated',
      handler: context.read<ApiProvider>().ratedMovies,
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
