import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';

import 'package:ytsmovies/src/services/desktop_window_service.dart';

/// Page<T> that renders a FluentPageRoute on Windows desktop and a
/// MaterialPage on mobile. Use as `pageBuilder:` in go_router routes
/// so navigation gets native chrome on each platform.
class AdaptivePage<T> extends Page<T> {
  const AdaptivePage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final bool maintainState;
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    if (isDesktop) {
      return fluent.FluentPageRoute<T>(
        settings: this,
        builder: (_) => child,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      );
    }
    return material.MaterialPageRoute<T>(
      settings: this,
      builder: (_) => child,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }
}
