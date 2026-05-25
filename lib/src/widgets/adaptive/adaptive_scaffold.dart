import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';

import 'package:ytsmovies/src/services/desktop_window_service.dart';

/// Scaffold that picks fluent_ui's ScaffoldPage on Windows desktop and
/// Material's Scaffold on mobile. On desktop the NavigationView already
/// supplies the title bar / sidebar, so the page only needs to provide
/// its body content.
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

  /// Mobile-only app bar. Ignored on desktop (sidebar handles chrome).
  final PreferredSizeWidget? appBar;

  /// Optional page title rendered above the body on desktop. Ignored on
  /// mobile when [appBar] is provided.
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
      return fluent.ScaffoldPage(
        padding: EdgeInsets.zero,
        header: title == null
            ? null
            : fluent.PageHeader(
                title: title!,
                commandBar: actions == null
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      ),
              ),
        content: body,
      );
    }
    return material.Scaffold(
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
