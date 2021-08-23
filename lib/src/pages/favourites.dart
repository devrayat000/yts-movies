import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/src/bloc/api/index.dart';

import '../widgets/gas_page.dart';

class FavouratesPage extends StatelessWidget {
  static const routeName = '/favourites-movies';
  const FavouratesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MamuMovieListpage<FavouriteApiCubit>(
      label: 'favourite',
      handler: context.read<ApiProvider>().favouriteMovies,
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
