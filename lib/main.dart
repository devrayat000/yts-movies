import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:ytsmovies/pages/latest.dart';
import 'package:ytsmovies/pages/test.dart';

import 'pages/home-2.dart';
import 'providers/filter_provider.dart';
import './providers/mamus_provider.dart';
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

void main() async {
  // The constructor sets global variables.
  MyWidgetsBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exit(1);
  };

  final _apptheme = AppTheme();
  final _favsX = FavouriteMamus();

  try {
    await Future.wait([
      _favsX.init(),
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final stored = await _apptheme.storedTheme;

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _apptheme),
        ChangeNotifierProvider.value(value: _favsX),
        ChangeNotifierProvider(create: (context) => Filter()),
      ],
      child: MyApp(themeMode: stored),
    ));
  } catch (e) {
    print(e);
  }
}

class MyApp extends StatelessWidget {
  final ThemeMode? themeMode;
  const MyApp({Key? key, this.themeMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Unfocus(
      child: MaterialApp(
        title: 'YTS Movies',
        debugShowCheckedModeBanner: false,
        home: ImageAppbar(),
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
          return _Screen(
            child: widget!,
            themeMode: this.themeMode,
          );
        },
      ),
    );
  }
}

class _Screen extends StatefulWidget {
  final Widget child;
  final ThemeMode? themeMode;
  const _Screen({Key? key, required this.child, this.themeMode})
      : super(key: key);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  @override
  void didChangeDependencies() {
    if (widget.themeMode == null) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      if (brightness == Brightness.dark) {
        context.read<AppTheme>().themeMode = ThemeMode.dark;
      } else {
        context.read<AppTheme>().themeMode = ThemeMode.light;
      }
    } else {
      context.read<AppTheme>().themeMode = widget.themeMode!;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppTheme>(
      child: widget.child,
      builder: (context, theme, child) => AnimatedTheme(
        data: theme.isDark ? DarkTheme.dark : LightTheme.light,
        child: child!,
        curve: Curves.easeOutCirc,
      ),
    );
  }
}

//  keytool -genkey -v -keystore c:\Users\rayat\yts-movies-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

