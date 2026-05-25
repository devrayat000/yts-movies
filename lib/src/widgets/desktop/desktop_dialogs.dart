import 'package:fluent_ui/fluent_ui.dart';

/// Fluent-styled confirmation dialog for desktop. Returns true if the
/// destructive action was confirmed.
Future<bool> showFluentConfirm({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'OK',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => ContentDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        Button(
          child: Text(cancelLabel),
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        FilledButton(
          style: destructive
              ? ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.red),
                )
              : null,
          child: Text(confirmLabel),
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}
