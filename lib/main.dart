import 'dart:async';
import 'dart:developer';
import 'dart:io';

// flutter pub global run devtools --appSizeBase=C:\Users\rayat\.flutter-devtools\apk-code-size-analysis_02.json

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ytsmovies/src/api/client.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/app.dart';
import 'package:ytsmovies/src/bloc/filter/index.dart';

// import 'package:ytsmovies/src/bloc/api/index.dart';
// import 'package:ytsmovies/src/bloc/filter/index.dart';
import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/theme/index.dart';

void main() {
  runZonedGuarded(
    () async {
      Timeline.startSync('init');
      // The constructor sets global variables.
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        if (kReleaseMode) exit(1);
      };

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
        ),
      );

      Hive
        ..initFlutter()
        ..registerAdapter(MovieAdapter())
        // ..registerAdapter(MovieAdapter())
        ..registerAdapter(TorrentAdapter());

      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
      );

      try {
        await Hive.openBox<Movie>(MyBoxs.favouriteBox);
        await Hive.openBox<String>(MyBoxs.searchHistoryBox);

        Timeline.finishSync();

        // final repo = MovieRepository(favouriteBox);
        final client = await initClient();

        runApp(MultiProvider(
          providers: [
            // Provider<MovieRepository>(
            //   create: (context) => repo,
            //   dispose: (context, repo) => repo.dispose(),
            // ),
            RepositoryProvider<MoviesClient>(
              create: (context) => client,
            ),
            // Provider<ApiProvider>(create: (context) {
            //   return ApiProvider(repo);
            // }),
            Provider<Filter>(
              create: (context) => Filter(),
              dispose: (context, filter) => filter.reset(),
            ),
            BlocProvider<ThemeCubit>(
              create: (context) => ThemeCubit(theme: AppTheme()),
            ),
          ],
          child: const YTSApp(),
        ));
      } catch (e, s) {
        log(
          e.toString(),
          error: e,
          stackTrace: s,
        );
        rethrow;
      }
    },
    (Object error, StackTrace stack) {
      log(error.toString(), error: error, stackTrace: stack);
      // exit(1);
    },
  );
}
