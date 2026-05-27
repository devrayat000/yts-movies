import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/bloc/filter/index.dart';
import 'package:ytsmovies/src/injection.dart';
import 'package:ytsmovies/src/models/movie.dart';
import 'package:ytsmovies/src/pages/home.dart';
import 'package:ytsmovies/src/pages/movie.dart';
import 'package:ytsmovies/src/pages/others.dart';
import 'package:ytsmovies/src/pages/favourites.dart';
import 'package:ytsmovies/src/pages/app_info.dart';
import 'package:ytsmovies/src/pages/search.dart';
import 'package:ytsmovies/src/pages/downloads.dart';
import 'package:ytsmovies/src/pages/download_details.dart';
import 'package:ytsmovies/src/services/desktop_window_service.dart';
import 'package:ytsmovies/src/widgets.dart';
import 'package:ytsmovies/src/widgets/adaptive/adaptive_page.dart';
import 'package:ytsmovies/src/widgets/desktop_shell.dart';
import 'package:ytsmovies/src/utils/index.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Public getter for root navigator key
GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/',
      name: "splash",
      builder: (context, state) => const InitializationSplashScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state, child) {
        final content = Unfocus(
          child: PageStorage(
            bucket: MyGlobals.bucket,
            child: child,
          ),
        );
        return MultiProvider(
          providers: [
            RepositoryProvider(
              create: (context) => getIt.get<MoviesClient>(),
              lazy: true,
            ),
            Provider<Filter>(
              create: (_) => Filter(),
              dispose: (_, filter) => filter.reset(),
            ),
          ],
          child: isDesktop
              ? DesktopShell(
                  location: state.uri.toString(),
                  child: content,
                )
              : content,
        );
      },
      routes: [
        GoRoute(
          path: "/home",
          name: "home",
          pageBuilder: (context, state) =>
              AdaptivePage(key: state.pageKey, child: const HomePage()),
          routes: [
            GoRoute(
              path: 'search',
              name: "search",
              pageBuilder: (context, state) {
                final query = state.uri.queryParameters['q'];
                return AdaptivePage(
                  key: state.pageKey,
                  child: SearchPage(initialQuery: query),
                );
              },
            ),
            GoRoute(
              path: 'latest',
              name: "latest",
              pageBuilder: (context, state) => AdaptivePage(
                key: state.pageKey,
                child: const LatestMoviesPage(),
              ),
            ),
            GoRoute(
              path: '4k',
              name: "4k",
              pageBuilder: (context, state) => AdaptivePage(
                key: state.pageKey,
                child: const HD4KMoviesPage(),
              ),
            ),
            GoRoute(
              path: 'rated',
              name: "rated",
              pageBuilder: (context, state) => AdaptivePage(
                key: state.pageKey,
                child: const RatedMoviesPage(),
              ),
            ),
            GoRoute(
              path: 'favourites',
              name: "favourites",
              pageBuilder: (context, state) => AdaptivePage(
                key: state.pageKey,
                child: const FavouritesPage(),
              ),
            ),
            GoRoute(
              path: 'downloads',
              name: "downloads",
              pageBuilder: (context, state) => AdaptivePage(
                key: state.pageKey,
                child: const DownloadsPage(),
              ),
              routes: [
                GoRoute(
                  path: 'details/:taskId',
                  name: "download-details",
                  pageBuilder: (context, state) {
                    final taskIdStr = state.pathParameters['taskId']!;
                    final taskId = int.parse(taskIdStr);
                    return AdaptivePage(
                      key: state.pageKey,
                      child: DownloadDetailsPage(taskId: taskId),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'app-info',
              name: "app-info",
              pageBuilder: (context, state) => AdaptivePage(
                key: state.pageKey,
                child: const AppInfoPage(),
              ),
            ),
            GoRoute(
              path: 'movie/:id',
              name: "details",
              pageBuilder: (context, state) {
                if (state.extra != null && state.extra is Movie) {
                  return AdaptivePage(
                    key: state.pageKey,
                    child: MoviePage.withMovie(item: state.extra as Movie),
                  );
                }
                final id = int.parse(state.pathParameters['id']!);
                return AdaptivePage(
                  key: state.pageKey,
                  child: MoviePage(id: id),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
