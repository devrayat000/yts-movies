import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';

import 'package:ytsmovies/src/services/desktop_window_service.dart';

class AdaptiveDialogAction<T> {
  const AdaptiveDialogAction({
    required this.label,
    required this.value,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  final String label;
  final T value;
  final bool isPrimary;
  final bool isDestructive;
}

/// Shows a fluent ContentDialog on Windows desktop and a Material
/// AlertDialog on mobile. Returns the value of the chosen action or
/// null if dismissed.
Future<T?> showAdaptiveAppDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  required List<AdaptiveDialogAction<T>> actions,
  bool barrierDismissible = true,
}) {
  if (isDesktop) {
    return fluent.showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => fluent.ContentDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          for (final a in actions)
            if (a.isPrimary)
              fluent.FilledButton(
                style: a.isDestructive
                    ? fluent.ButtonStyle(
                        backgroundColor:
                            fluent.WidgetStatePropertyAll(fluent.Colors.red),
                      )
                    : null,
                child: Text(a.label),
                onPressed: () => Navigator.of(ctx).pop(a.value),
              )
            else
              fluent.Button(
                child: Text(a.label),
                onPressed: () => Navigator.of(ctx).pop(a.value),
              ),
        ],
      ),
    );
  }
  return material.showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => material.AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        for (final a in actions)
          material.TextButton(
            style: a.isDestructive
                ? material.TextButton.styleFrom(
                    foregroundColor: material.Colors.red)
                : null,
            onPressed: () => Navigator.of(ctx).pop(a.value),
            child: Text(a.label),
          ),
      ],
    ),
  );
}
