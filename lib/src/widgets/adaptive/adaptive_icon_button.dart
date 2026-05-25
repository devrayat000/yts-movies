import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';

import 'package:ytsmovies/src/services/desktop_window_service.dart';

/// IconButton that uses fluent_ui's IconButton on desktop and Material's
/// on mobile.
class AdaptiveIconButton extends StatelessWidget {
  const AdaptiveIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      final btn = fluent.IconButton(icon: icon, onPressed: onPressed);
      return tooltip == null
          ? btn
          : fluent.Tooltip(message: tooltip!, child: btn);
    }
    return material.IconButton(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      color: color,
    );
  }
}
