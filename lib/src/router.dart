import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ytsmovies/src/pages/latest.dart';

final router = GoRouter(
  initialLocation: "/latest",
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Center(),
      routes: [
        GoRoute(
          path: 'latest',
          builder: (context, state) => LatestMoviesPage(),
        ),
        GoRoute(
          path: '4k',
          builder: (context, state) => HD4KMoviesPage(),
        ),
        GoRoute(
          path: 'rated',
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
