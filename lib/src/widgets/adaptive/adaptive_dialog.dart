import 'package:flutter/material.dart';

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

/// Shows a standard Material 3 AlertDialog on all platforms.
/// Returns the value of the chosen action or null if dismissed.
Future<T?> showAdaptiveAppDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  required List<AdaptiveDialogAction<T>> actions,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            for (final a in actions)
              TextButton(
                style: a.isDestructive
                    ? TextButton.styleFrom(foregroundColor: Colors.red)
                    : a.isPrimary
                        ? TextButton.styleFrom(
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                onPressed: () => Navigator.of(ctx).pop(a.value),
                child: Text(a.label),
              ),
          ],
        ),
      ),
    ),
  );
}
