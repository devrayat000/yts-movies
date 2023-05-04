import 'package:go_router/go_router.dart';
import 'package:ytsmovies/src/pages/index.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage2(),
      routes: [
        GoRoute(
          path: '/latest',
          builder: (context, state) => LatestMoviesPage(),
        ),
        GoRoute(
          path: '/4k',
          builder: (context, state) => HD4KMoviesPage(),
        ),
        GoRoute(
          path: '/rated',
          builder: (context, state) => RatedMoviesPage(),
        ),
        GoRoute(
          path: '/favourites',
          builder: (context, state) => FavouratesPage(),
        ),
        // GoRoute(
        //   path: '/movie/:id',
        //   pageBuilder: (context, state) => MoviePage(
        //     id: state.params['id']!,
        //   ),
        // ),
      ],
    ),
  ],
);
