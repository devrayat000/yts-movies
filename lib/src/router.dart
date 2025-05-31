import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/app.dart';
import 'package:ytsmovies/src/bloc/filter/index.dart';
import 'package:ytsmovies/src/models/movie.dart';
import 'package:ytsmovies/src/pages/home.dart';
import 'package:ytsmovies/src/pages/movie.dart';
import 'package:ytsmovies/src/pages/others.dart';
import 'package:ytsmovies/src/pages/favourites.dart';
import 'package:ytsmovies/src/pages/app_info.dart';
import 'package:ytsmovies/src/pages/search.dart';
import 'package:ytsmovies/src/widgets.dart';
import 'package:ytsmovies/src/utils/index.dart';

extension RouterExtension on YTSApp {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  GoRouter get router => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: "/splash",
        routes: [
          GoRoute(
            path: '/splash',
            name: "splash",
            builder: (context, state) => const InitializationSplashScreen(),
          ),
          ShellRoute(
            navigatorKey: _shellNavigatorKey,
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state, child) => MultiProvider(
              providers: [
                RepositoryProvider(
                  create: (context) => context.read<MoviesClientCubit>().state,
                  lazy: false,
                ),
                Provider<Filter>(
                  create: (_) => Filter(),
                  dispose: (_, filter) => filter.reset(),
                ),
              ],
              child: Unfocus(
                child: PageStorage(
                  bucket: MyGlobals.bucket,
                  child: child,
                ),
              ),
            ),
            routes: [
              GoRoute(
                path: '/',
                name: "home",
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
          ),
        ],
      );
}
