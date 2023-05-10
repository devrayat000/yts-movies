import 'package:go_router/go_router.dart';

import 'package:ytsmovies/src/models/movie.dart';
import 'package:ytsmovies/src/pages/home.dart';
import 'package:ytsmovies/src/pages/movie.dart';
import 'package:ytsmovies/src/pages/others.dart';
import 'package:ytsmovies/src/pages/favourites.dart';

final router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'latest',
          name: "latest",
          builder: (context, state) => const LatestMoviesPage(),
        ),
        GoRoute(
          path: '4k',
          name: "4k",
          builder: (context, state) => const HD4KMoviesPage(),
        ),
        GoRoute(
          path: 'rated',
          name: "rated",
          builder: (context, state) => const RatedMoviesPage(),
        ),
        GoRoute(
          path: 'favourites',
          name: "favourites",
          builder: (context, state) => const FavouritesPage(),
        ),
        GoRoute(
          path: 'movie/:id',
          name: "details",
          builder: (context, state) {
            if (state.extra != null && state.extra is Movie) {
              return MoviePage.withMovie(item: state.extra as Movie);
            }
            final id = int.parse(state.pathParameters['id']!);
            return MoviePage(id: id);
          },
        ),
      ],
    ),
  ],
);
