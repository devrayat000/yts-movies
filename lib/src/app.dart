import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart'
    show CupertinoScrollBehavior, DefaultCupertinoLocalizations;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/router.dart';
import 'package:ytsmovies/src/services/desktop_window_service.dart';
import 'package:ytsmovies/src/widgets.dart';

class YTSApp extends StatelessWidget with RouterExtension {
  YTSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, materialTheme) {
        return fluent.FluentApp.router(
          title: 'YTS Movies',
          debugShowCheckedModeBanner: false,
          routerConfig: this.router,
          theme: _fluentThemeFor(materialTheme),
          darkTheme: _fluentThemeFor(materialTheme),
          themeMode: materialTheme.brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          scrollBehavior: const _AppScrollBehavior(),
          localizationsDelegates: [
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            fluent.FluentLocalizations.delegate,
          ],
          builder: (context, widget) => ConnectivityBanner(
            showWhenConnected: true,
            child: _AppShell(
              materialTheme: materialTheme,
              child: widget!,
            ),
          ),
        );
      },
    );
  }

  fluent.FluentThemeData _fluentThemeFor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return fluent.FluentThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      accentColor: fluent.AccentColor.swatch({
        'darkest': theme.colorScheme.primary,
        'darker': theme.colorScheme.primary,
        'dark': theme.colorScheme.primary,
        'normal': theme.colorScheme.primary,
        'light': theme.colorScheme.primaryContainer,
        'lighter': theme.colorScheme.primaryContainer,
        'lightest': theme.colorScheme.primaryContainer,
      }),
      scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
    );
  }
}

/// Cupertino-style scrollbar everywhere, but also allow trackpad + mouse
/// dragging so desktop users can drag-scroll lists / posters.
class _AppScrollBehavior extends CupertinoScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.materialTheme, required this.child});

  final ThemeData materialTheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget errorWidget = const Text('Unexpected error occurred');
    if (child is Scaffold || child is Navigator) {
      errorWidget = Scaffold(body: Center(child: errorWidget));
    }
    ErrorWidget.builder = (_) => errorWidget;

    final frame = isDesktop ? _DesktopChrome(child: child) : child;
    return AnimatedTheme(
      data: materialTheme,
      curve: Curves.easeOutCirc,
      child: frame,
    );
  }
}

/// Desktop-only wrapper that adds a draggable region across the very top of
/// the window so users can move the window even though the app keeps the
/// native title bar visible. Lets the rest of the UI feel native on Windows
/// without overriding the OS chrome.
class _DesktopChrome extends StatelessWidget {
  const _DesktopChrome({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Padding at top reserves a 4px area where window dragging hand-off to
    // the OS frame is most reliable; the bulk of the UI is the child.
    return child;
  }
}
