import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import './models/constants.dart';
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

    kPageStorageBucket = PageStorageBucket();
    kCircularLoading = Center(
      child: CircularProgressIndicator.adaptive(),
    );

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _apptheme),
        ChangeNotifierProvider.value(value: _view),
        // ChangeNotifierProvider(create: (_) => Filter()),
        ChangeNotifierProvider.value(value: _favsX),
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
      child: MaterialApp(
        title: 'YTS Movies',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        // animationType: AnimationType.CIRCULAR_ANIMATED_THEME,
        themeMode:
            context.select<AppTheme, ThemeMode>((theme) => theme.current),
        initialRoute: HomePage.routeName,
        routes: _routes,
        scrollBehavior: const CupertinoScrollBehavior(),
        // onGenerateRoute: _onGenerateRoute,
        localizationsDelegates: [
          const LocaleNamesLocalizationsDelegate(fallbackLocale: 'en'),
        ],
        builder: (BuildContext context, Widget? widget) {
          Widget error = Text('...Unexpected error occurred...');
          if (widget is Scaffold || widget is Navigator)
            error = Scaffold(body: Center(child: error));
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) => error;
          return widget!;
        },
      ),
    );
  }

  // Route<dynamic> _onGenerateRoute(RouteSettings settings) {
  //   switch (settings.name) {
  //     case HomePage.routeName:
  //       return PageTransition(
  //         child: const HomePage(),
  //         type: PageTransitionType.bottomToTop,
  //         settings: settings,
  //       );
  //     case SearchPage.routeName:
  //       return PageTransition(
  //         child: const SearchPage(),
  //         type: PageTransitionType.rightToLeftWithFade,
  //         settings: settings,
  //       );
  //     case MoviePage.routeName:
  //       return PageTransition(
  //         child: const MoviePage(),
  //         type: PageTransitionType.rightToLeftWithFade,
  //         settings: settings,
  //       );
  //     case LatestMoviesPage.routeName:
  //       return PageTransition(
  //         child: const LatestMoviesPage(),
  //         type: PageTransitionType.bottomToTop,
  //         settings: settings,
  //       );
  //     case HD4KMoviesPage.routeName:
  //       return PageTransition(
  //         child: const HD4KMoviesPage(),
  //         type: PageTransitionType.bottomToTop,
  //         settings: settings,
  //       );
  //     case FavouratesPage.routeName:
  //       return PageTransition(
  //         child: const FavouratesPage(),
  //         type: PageTransitionType.bottomToTop,
  //         settings: settings,
  //       );
  //     default:
  //       return PageTransition(
  //         child: const HomePage(),
  //         type: PageTransitionType.bottomToTop,
  //         settings: settings,
  //       );
  //   }
  // }

  Map<String, Widget Function(BuildContext)> get _routes {
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
      LatestMoviesPage.routeName: (context) => const LatestMoviesPage(),
      HD4KMoviesPage.routeName: (_) => const HD4KMoviesPage(),
      FavouratesPage.routeName: (_) => const FavouratesPage(),
    };
  }
}
