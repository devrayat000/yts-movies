import 'package:go_router/go_router.dart';

import 'package:ytsmovies/src/models/movie.dart';
import 'package:ytsmovies/src/pages/home.dart';
import 'package:ytsmovies/src/pages/movie.dart';
import 'package:ytsmovies/src/pages/others.dart';
import 'package:ytsmovies/src/pages/favourites.dart';
import 'package:ytsmovies/src/pages/app_info.dart';
import 'package:ytsmovies/src/pages/search.dart';

final router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'search',
          name: "search",
          builder: (context, state) {
            final query = state.uri.queryParameters['q'];
            return SearchPage(initialQuery: query);
          },
        ),
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
          path: 'app-info',
          name: "app-info",
          builder: (context, state) => const AppInfoPage(),
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
