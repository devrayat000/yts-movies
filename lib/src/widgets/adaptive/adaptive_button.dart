import 'package:flutter/material.dart';

enum AdaptiveButtonKind { standard, filled, text, outlined }

/// Button that maps to Material variants on all platforms.
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
    switch (kind) {
      case AdaptiveButtonKind.filled:
        return FilledButton(onPressed: onPressed, child: child);
      case AdaptiveButtonKind.text:
        return TextButton(onPressed: onPressed, child: child);
      case AdaptiveButtonKind.outlined:
        return OutlinedButton(onPressed: onPressed, child: child);
      case AdaptiveButtonKind.standard:
        return ElevatedButton(onPressed: onPressed, child: child);
    }
  }
}
