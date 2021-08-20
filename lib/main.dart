import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/single_child_widget.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart' ;

// import 'package:ytsmovies/pages/test.dart';
import 'package:ytsmovies/bloc/filter/index.dart';
import 'package:ytsmovies/bloc/theme_bloc.dart';
import 'package:ytsmovies/mock/movie.dart';
import 'package:ytsmovies/mock/torrent.dart';
import 'package:ytsmovies/pages/home-2.dart';
import 'package:ytsmovies/utils/constants.dart';
import './widgets/unfocus.dart';
import './theme/index.dart';

class MyImageCache extends ImageCache {
  @override
  void clear() {
    print('Clearing cache!');
    super.clear();
  }
}

class MyWidgetsBinding extends WidgetsFlutterBinding {
  @override
  ImageCache? get imageCache => createImageCache();

  @override
  ImageCache createImageCache() {
    imageCache?.maximumSize = 999;
    return MyImageCache();
  }

  static WidgetsBinding ensureInitialized() =>
      WidgetsFlutterBinding.ensureInitialized();
}

void main() {
  runZonedGuarded(
    () async {
      // The constructor sets global variables.
      MyWidgetsBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);
        if (kReleaseMode) exit(1);
      };

      Hive
        ..init((await getTemporaryDirectory()).path)
        ..registerAdapter(MovieAdapter())
        // ..registerAdapter(MovieAdapter())
        ..registerAdapter(TorrentAdapter());

      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getTemporaryDirectory(),
      );

      final _apptheme = AppTheme();
      // final _favsX = FavouriteMamus();

      try {
        await Future.wait([
          Hive.openBox<Movie>(MyBoxs.favouriteBox),
          Hive.openBox<String>(MyBoxs.searchHistoryBox),
          // _favsX.init(),
        ]);

        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark,
          ),
        );

        runApp(MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _apptheme),
            // ChangeNotifierProvider.value(value: _favsX),
            Provider<Filter>(
              create: (_) => Filter(),
              // updateShouldNotify: (old, newI) => old.values != newI.values,
              dispose: (context, filter) => filter.reset(),
            ),
          ],
          child: const MyApp(),
        ));
      } catch (e, s) {
        print(e);
        print(s);
        rethrow;
      }
    },
    (Object error, StackTrace stack) {
      print(error);
      print(stack);
      // exit(1);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final systemTheme =
        brightness == Brightness.dark ? DarkTheme.dark : LightTheme.light;

    return BlocProvider(
      create: (context) => ThemeCubit(systemTheme),
      child: Unfocus(
        child: PageStorage(
          bucket: MyGlobals.bucket,
          child: MaterialApp(
            title: 'YTS Movies',
            debugShowCheckedModeBanner: false,
            home: HomePage2(),
            scrollBehavior: const CupertinoScrollBehavior(),
            localizationsDelegates: [
              const LocaleNamesLocalizationsDelegate(fallbackLocale: 'en'),
            ],
            restorationScopeId: 'com.movies.yts',
            builder: (BuildContext context, Widget? widget) {
              Widget error = Text('...Unexpected error occurred...');
              if (widget is Scaffold || widget is Navigator)
                error = Scaffold(body: Center(child: error));
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) => error;

              return _Screen(child: widget!);
            },
          ),
        ),
      ),
    );
  }
}

class _Screen extends SingleChildStatelessWidget {
  const _Screen({Key? key, required Widget child})
      : super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return AnimatedTheme(
          data: theme,
          child: child!,
          curve: Curves.easeOutCirc,
        );
      },
      buildWhen: (prev, current) => prev != current,
    );
  }
}

//  keytool -genkey -v -keystore c:\Users\rayat\yts-movies-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

