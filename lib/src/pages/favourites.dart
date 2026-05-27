import 'package:flutter/material.dart';
import 'package:ytsmovies/src/service_extensions.dart';
import 'package:ytsmovies/src/widgets/movies_list.dart';

class FavouritesPage extends StatelessWidget {
  static const routeName = '/favourites-movies';
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MoviesList(
      label: 'favourite',
      handler: (page, limit) => context.favouritesService.getFavouriteMovies(page),
      title: const Text('Favourite Movies'),
      appBar: AppBar(
        title: Text(
          'Favourite Movies',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      // actions: const [],
    );
  }
}

typedef FavCallback = Future<Map<String, dynamic>> Function(int);
