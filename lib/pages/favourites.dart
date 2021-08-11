import 'dart:async';

import 'package:flutter/material.dart';

import '../providers/mamus_provider.dart';
import '../widgets/gas_page.dart';

class FavouratesPage extends StatelessWidget {
  static const routeName = '/favourites-movies';
  const FavouratesPage({Key? key}) : super(key: key);

  static final _mamuKey = GlobalKey<MamuMovieListpageState<FavouriteMamus>>();

  @override
  Widget build(BuildContext context) {
    return MamuMovieListpage<FavouriteMamus>(
      key: _mamuKey,
      label: 'favourite',
      handler: FavouriteMamus(),
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
