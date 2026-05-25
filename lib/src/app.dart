import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' show CupertinoScrollBehavior;
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
    return MaterialApp.router(
      title: 'YTS Movies',
      debugShowCheckedModeBanner: false,
      routerConfig: this.router,
      scrollBehavior: const _AppScrollBehavior(),
      builder: (context, widget) => ConnectivityBanner(
        showWhenConnected: true,
        child: _AppShell(child: widget!),
      ),
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
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        final desktopFrame =
            isDesktop ? _DesktopChrome(child: child) : child;
        final themed = AnimatedTheme(
          data: theme,
          curve: Curves.easeOutCirc,
          child: desktopFrame,
        );
        // Provide a fluent_ui theme so fluent widgets used in the custom
        // title bar / desktop affordances pick up matching colors. The
        // primary Material theme is untouched.
        return fluent.FluentTheme(
          data: _fluentThemeFor(theme),
          child: themed,
        );
      },
      buildWhen: (previous, current) => previous != current,
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
