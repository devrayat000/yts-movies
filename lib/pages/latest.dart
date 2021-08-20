import 'package:flutter/material.dart';
import 'package:ytsmovies/bloc/api/index.dart';

import '../widgets/gas_page.dart';

class LatestMoviesPage extends StatelessWidget {
  static const routeName = '/latest-movies';
  const LatestMoviesPage({Key? key}) : super(key: key);

  static final _mamuKey = GlobalKey<MamuMovieListpageState<LatestApiBloc>>();

  @override
  Widget build(BuildContext context) {
    return MamuMovieListpage<LatestApiBloc>(
      key: _mamuKey,
      label: 'latest',
      handler: LatestApiBloc(),
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

  static final _mamuKey = GlobalKey<MamuMovieListpageState<HDApiBloc>>();

  @override
  Widget build(BuildContext context) {
    return MamuMovieListpage<HDApiBloc>(
      key: _mamuKey,
      label: '4k',
      handler: HDApiBloc(),
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

  static final _mamuKey = GlobalKey<MamuMovieListpageState<RatedApiBloc>>();

  @override
  Widget build(BuildContext context) {
    return MamuMovieListpage<RatedApiBloc>(
      key: _mamuKey,
      label: 'rated',
      handler: RatedApiBloc(),
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
