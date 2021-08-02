import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import 'utils/constants.dart';
import './models/movie.dart';
import './providers/mamus_provider.dart';
import './pages/home.dart';
import './pages/search.dart';
import './pages/movie.dart';
import './pages/latest.dart';
import './pages/favourites.dart';
import './widgets/unfocus.dart';
import './providers/view_provider.dart';
import './models/theme.dart';

class MyImageCache extends ImageCache {
  @override
  void clear() {
    print('Clearing cache!');
    super.clear();
  }
}

class MyWidgetsBinding extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    imageCache?.maximumSize = 10;
    return MyImageCache();
  }

  static WidgetsBinding ensureInitialized() =>
      WidgetsFlutterBinding.ensureInitialized();
}

void main() async {
  // The constructor sets global variables.
  MyWidgetsBinding();

  MyWidgetsBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exit(1);
  };

  final _view = GridListView();
  final _apptheme = AppTheme();
  final _favsX = FavouriteMamus();

  try {
    await Future.wait([
      _favsX.init(),
      _view.initialize(),
      _apptheme.initialize(),
    ]);

    kCircularLoading = Center(
      child: CircularProgressIndicator.adaptive(),
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _apptheme),
        ChangeNotifierProvider.value(value: _view),
        // ChangeNotifierProvider(create: (_) => Filter()),
        ChangeNotifierProvider.value(value: _favsX),
        Provider<Storage>(create: (_) => Storage()),
      ],
      child: const MyApp(),
    ));
  } catch (e) {
    print(e);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Unfocus(
      child: Consumer<AppTheme>(
        builder: (context, theme, _) => MaterialApp(
          title: 'YTS Movies',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          // animationType: AnimationType.CIRCULAR_ANIMATED_THEME,
          themeMode: theme.current,
          initialRoute: HomePage.routeName,
          routes: _routes,
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
            return widget!;
          },
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> get _routes {
    return {
      HomePage.routeName: (_) => const HomePage(),
      SearchPage.routeName: (_) => const SearchPage(),
      MoviePage.routeName: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as MovieArg<Movie>;
        final _movie = args.movie;
        return MoviePage(
          item: _movie,
        );
      },
      LatestMoviesPage.routeName: (_) =>
          const LatestMoviesPage(),
      HD4KMoviesPage.routeName: (_) => const HD4KMoviesPage(),
      FavouratesPage.routeName: (_) => const FavouratesPage(),
    };
  }
}

//  keytool -genkey -v -keystore c:\Users\rayat\yts-movies-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

