import 'package:flutter/material.dart';

/// Page<T> that renders a MaterialPageRoute on all platforms.
/// Use as `pageBuilder:` in go_router routes.
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
    return MaterialPageRoute<T>(
      settings: this,
      builder: (_) => child,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }
}
