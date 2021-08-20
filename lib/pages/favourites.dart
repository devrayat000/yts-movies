import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ytsmovies/bloc/api/index.dart';

import '../widgets/gas_page.dart';

class FavouratesPage extends StatelessWidget {
  static const routeName = '/favourites-movies';
  const FavouratesPage({Key? key}) : super(key: key);

  static final _mamuKey = GlobalKey<MamuMovieListpageState<FavouriteApiBloc>>();

  @override
  Widget build(BuildContext context) {
    return MamuMovieListpage<FavouriteApiBloc>(
      key: _mamuKey,
      label: 'favourite',
      handler: FavouriteApiBloc(),
      appBar: AppBar(
        title: Text(
          'Favourite Movies',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      actions: [],
    );
  }
}

typedef FavCallback = Future<Map<String, dynamic>> Function(int);
