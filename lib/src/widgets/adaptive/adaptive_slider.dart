import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';

import 'package:ytsmovies/src/services/desktop_window_service.dart';

class AdaptiveSlider extends StatelessWidget {
  const AdaptiveSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return fluent.Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
      );
    }
    return material.Slider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      divisions: divisions,
      label: label,
    );
  }
}
