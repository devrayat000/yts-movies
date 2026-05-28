import 'package:flutter/material.dart';

import 'package:ytsmovies/src/services/desktop_window_service.dart';

/// Scaffold that picks standard Material Scaffold on both desktop and mobile.
/// On desktop, we style it with a custom top page header to feel desktoppy.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.restorationId,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
  });

  /// Mobile-only app bar. Ignored on desktop (custom header handles chrome).
  final PreferredSizeWidget? appBar;

  /// Optional page title rendered above the body on desktop.
  final Widget? title;

  /// Optional desktop header actions rendered to the right of [title].
  final List<Widget>? actions;

  final Widget body;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final String? restorationId;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      final theme = Theme.of(context);
      return Scaffold(
        backgroundColor: backgroundColor ?? theme.colorScheme.surface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DefaultTextStyle.merge(
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      child: title!,
                    ),
                    if (actions != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      ),
                  ],
                ),
              ),
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      );
    }
    return Scaffold(
      appBar: appBar,
      body: body,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
      restorationId: restorationId,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
