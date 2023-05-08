import 'package:go_router/go_router.dart';
import 'package:ytsmovies/src/pages/home-2.dart';
import 'package:ytsmovies/src/pages/others.dart';

final router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage2(),
      routes: [
        GoRoute(
          path: 'latest',
          name: "latest",
          builder: (context, state) => LatestMoviesPage(),
        ),
        GoRoute(
          path: '4k',
          name: "4k",
          builder: (context, state) => HD4KMoviesPage(),
        ),
        GoRoute(
          path: 'rated',
          name: "rated",
          builder: (context, state) => RatedMoviesPage(),
        ),
        // GoRoute(
        //   path: 'favourites',
        //   builder: (context, state) => FavouratesPage(),
        // ),
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
