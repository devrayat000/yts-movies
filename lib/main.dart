import 'dart:async';
import 'dart:developer';
import 'dart:io';

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
import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/theme/index.dart';

void main() {
  runZonedGuarded(
    _initializeApp,
    (Object error, StackTrace stack) {
      log(error.toString(), error: error, stackTrace: stack);
    },
  );
}

Future<void> _initializeApp() async {
  Timeline.startSync('init');
  WidgetsFlutterBinding.ensureInitialized();

  // Set error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };

  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Initialize Hive
  await _initializeHive();

  // Initialize HydratedBloc storage
  await _initializeHydratedStorage();

  try {
    // Open Hive boxes
    await Future.wait([
      Hive.openBox<Movie>(MyBoxs.favouriteBox),
      Hive.openBox<String>(MyBoxs.searchHistoryBox),
    ]);

    Timeline.finishSync();

    // Initialize API client
    final client = await initClient();

    // Run the app
    runApp(_buildApp(client));
  } catch (e, s) {
    log(e.toString(), error: e, stackTrace: s);
    rethrow;
  }
}

Future<void> _initializeHive() async {
  await Hive.initFlutter();
  Hive
    ..registerAdapter(MovieAdapter())
    ..registerAdapter(TorrentAdapter());
}

Future<void> _initializeHydratedStorage() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
}

Widget _buildApp(MoviesClient client) {
  return MultiProvider(
    providers: [
      RepositoryProvider<MoviesClient>(
        create: (_) => client,
      ),
      Provider<Filter>(
        create: (_) => Filter(),
        dispose: (_, filter) => filter.reset(),
      ),
      BlocProvider<ThemeCubit>(
        create: (_) => ThemeCubit(theme: AppTheme()),
      ),
    ],
    child: const YTSApp(),
  );
}
