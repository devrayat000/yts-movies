// flutter pub global run devtools --appSizeBase=C:\Users\rayat\.flutter-devtools\apk-code-size-analysis_02.json

import 'package:flutter/cupertino.dart' show CupertinoScrollBehavior;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/router.dart';
import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/widgets.dart';

class YTSApp extends StatelessWidget {
  const YTSApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Unfocus(
      child: PageStorage(
        bucket: MyGlobals.bucket,
        child: MaterialApp.router(
          title: 'YTS Movies',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          scrollBehavior: const CupertinoScrollBehavior(),
          // restorationScopeId: 'com.movies.yts',
          builder: (BuildContext context, Widget? widget) {
            Widget error = const Text('...Unexpected error occurred...');
            if (widget is Scaffold || widget is Navigator) {
              error = Scaffold(body: Center(child: error));
            }
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) => error;

            return _Screen(child: widget!);
          },
        ),
      ),
    );
  }
}

class _Screen extends StatelessWidget {
  final Widget child;
  const _Screen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    context.read<ThemeCubit>().sync(brightness);

    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return AnimatedTheme(
          data: theme,
          curve: Curves.easeOutCirc,
          child: child,
        );
      },
      buildWhen: (prev, current) => prev != current,
    );
  }
}
// TODO: change to go_router
//  keytool -genkey -v -keystore c:\Users\rayat\yts-movies-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

