import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';

import 'package:ytsmovies/src/services/desktop_window_service.dart';

/// Indeterminate or determinate circular spinner. ProgressRing on
/// desktop, CircularProgressIndicator on mobile.
class AdaptiveProgressRing extends StatelessWidget {
  const AdaptiveProgressRing({super.key, this.value, this.strokeWidth});

  final double? value;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return fluent.ProgressRing(
        value: value == null ? null : value! * 100,
        strokeWidth: strokeWidth ?? 4.5,
      );
    }
    return material.CircularProgressIndicator(
      value: value,
      strokeWidth: strokeWidth ?? 4.0,
    );
  }
}

/// Linear progress bar. fluent ProgressBar on desktop,
/// LinearProgressIndicator on mobile.
class AdaptiveProgressBar extends StatelessWidget {
  const AdaptiveProgressBar({super.key, this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return fluent.ProgressBar(value: value == null ? null : value! * 100);
    }
    return material.LinearProgressIndicator(value: value);
  }
}
