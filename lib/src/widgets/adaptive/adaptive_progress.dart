import 'package:flutter/material.dart';

/// Circular spinner.
class AdaptiveProgressRing extends StatelessWidget {
  const AdaptiveProgressRing({super.key, this.value, this.strokeWidth});

  final double? value;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      value: value,
      strokeWidth: strokeWidth ?? 4.0,
    );
  }
}

/// Linear progress bar.
class AdaptiveProgressBar extends StatelessWidget {
  const AdaptiveProgressBar({super.key, this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(value: value);
  }
}
