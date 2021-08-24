import 'dart:async';
import 'dart:developer';
import 'dart:io';

// flutter pub global run devtools --appSizeBase=C:\Users\rayat\.flutter-devtools\apk-code-size-analysis_02.json

import 'package:flutter/cupertino.dart' show CupertinoScrollBehavior;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ytsmovies/src/bloc/api/index.dart';
import 'package:ytsmovies/src/bloc/filter/index.dart';
import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/mock/index.dart';
import 'package:ytsmovies/src/router/index.dart';
import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/widgets.dart';
import 'package:ytsmovies/src/theme/index.dart';

void main() {
  runZonedGuarded(
    () async {
      Timeline.startSync('init');
      // The constructor sets global variables.
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
        if (kReleaseMode) exit(1);
      };

      Hive
        ..initFlutter()
        ..registerAdapter(MovieAdapter())
        // ..registerAdapter(MovieAdapter())
        ..registerAdapter(TorrentAdapter());

      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getTemporaryDirectory(),
      );

      try {
        final favouriteBox = await Hive.openBox<Movie>(MyBoxs.favouriteBox);
        await Hive.openBox<String>(MyBoxs.searchHistoryBox);

        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark,
          ),
        );
        Timeline.finishSync();

        runApp(MultiProvider(
          providers: [
            Provider<MovieRepository>(
              create: (context) => MovieRepository(favouriteBox),
              dispose: (context, repo) => repo.dispose(),
            ),
            Provider<ApiProvider>(create: (context) {
              final repository = context.read<MovieRepository>();
              return ApiProvider(repository);
            }),
            Provider<Filter>(
              create: (context) => Filter(),
              // updateShouldNotify: (old, newI) => old.values != newI.values,
              dispose: (context, filter) => filter.reset(),
            ),
          ],
          child: const MyApp(),
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppTheme appTheme;
  late ThemeData systemTheme;
  late final RootRouteState routeState;
  late final RootRouterDelegate routerDelegate;
  late final RootRouteInfoParser parser;

  @override
  void initState() {
    appTheme = AppTheme();
    systemTheme = appTheme.light;

    routeState = RootRouteState();

    routerDelegate = RootRouterDelegate(
      appState: routeState,
      repository: context.read<MovieRepository>(),
    );
    parser = RootRouteInfoParser();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final brightness = MediaQuery.platformBrightnessOf(context);
    systemTheme =
        brightness == Brightness.dark ? appTheme.dark : appTheme.light;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return RootRouteScope(
      key: ValueKey('route-scope'),
      notifier: routeState,
      child: BlocProvider(
        create: (context) => ThemeCubit(
          initialTheme: systemTheme,
          theme: appTheme,
        ),
        child: Unfocus(
          child: PageStorage(
            bucket: MyGlobals.bucket,
            child: MaterialApp.router(
              title: 'YTS Movies',
              debugShowCheckedModeBanner: false,
              routerDelegate: routerDelegate,
              routeInformationParser: parser,
              scrollBehavior: const CupertinoScrollBehavior(),
              restorationScopeId: 'com.movies.yts',
              builder: (BuildContext context, Widget? widget) {
                Widget error = Text('...Unexpected error occurred...');
                if (widget is Scaffold || widget is Navigator)
                  error = Scaffold(body: Center(child: error));
                ErrorWidget.builder =
                    (FlutterErrorDetails errorDetails) => error;

                return _Screen(child: widget!);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    routerDelegate.dispose();
    super.dispose();
  }
}

class _Screen extends StatelessWidget {
  final Widget child;
  const _Screen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return AnimatedTheme(
          data: theme,
          child: child,
          curve: Curves.easeOutCirc,
        );
      },
      buildWhen: (prev, current) => prev != current,
    );
  }
}

//  keytool -genkey -v -keystore c:\Users\rayat\yts-movies-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

