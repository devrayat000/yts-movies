import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';

import 'package:ytsmovies/src/services/desktop_window_service.dart';

enum AdaptiveButtonKind { standard, filled, text, outlined }

/// Button that maps to fluent_ui Button/FilledButton/HyperlinkButton on
/// Windows desktop and Material variants on mobile.
class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.kind = AdaptiveButtonKind.standard,
  });

  const AdaptiveButton.filled({
    super.key,
    required this.onPressed,
    required this.child,
  }) : kind = AdaptiveButtonKind.filled;

  const AdaptiveButton.text({
    super.key,
    required this.onPressed,
    required this.child,
  }) : kind = AdaptiveButtonKind.text;

  const AdaptiveButton.outlined({
    super.key,
    required this.onPressed,
    required this.child,
  }) : kind = AdaptiveButtonKind.outlined;

  final VoidCallback? onPressed;
  final Widget child;
  final AdaptiveButtonKind kind;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      switch (kind) {
        case AdaptiveButtonKind.filled:
          return fluent.FilledButton(onPressed: onPressed, child: child);
        case AdaptiveButtonKind.text:
          return fluent.HyperlinkButton(onPressed: onPressed, child: child);
        case AdaptiveButtonKind.outlined:
        case AdaptiveButtonKind.standard:
          return fluent.Button(onPressed: onPressed, child: child);
      }
    }
    switch (kind) {
      case AdaptiveButtonKind.filled:
        return material.FilledButton(onPressed: onPressed, child: child);
      case AdaptiveButtonKind.text:
        return material.TextButton(onPressed: onPressed, child: child);
      case AdaptiveButtonKind.outlined:
        return material.OutlinedButton(onPressed: onPressed, child: child);
      case AdaptiveButtonKind.standard:
        return material.ElevatedButton(onPressed: onPressed, child: child);
    }
  }
}
