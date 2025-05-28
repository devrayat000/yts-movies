import 'package:flutter/cupertino.dart' show CupertinoScrollBehavior;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/router.dart';
import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/widgets.dart';

class YTSApp extends StatelessWidget {
  const YTSApp({super.key});
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
          builder: (context, widget) => _AppShell(child: widget!),
        ),
      ),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget errorWidget = const Text('Unexpected error occurred');
    if (child is Scaffold || child is Navigator) {
      errorWidget = Scaffold(body: Center(child: errorWidget));
    }
    ErrorWidget.builder = (_) => errorWidget;

    return _ThemeProvider(child: child);
  }
}

class _ThemeProvider extends StatelessWidget {
  const _ThemeProvider({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    context.read<ThemeCubit>().sync(brightness);

    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) => AnimatedTheme(
        data: theme,
        curve: Curves.easeOutCirc,
        child: child,
      ),
      buildWhen: (previous, current) => previous != current,
    );
  }
}
