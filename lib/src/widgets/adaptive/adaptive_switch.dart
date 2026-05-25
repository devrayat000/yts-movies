import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';

import 'package:ytsmovies/src/services/desktop_window_service.dart';

/// Toggle switch. fluent_ui ToggleSwitch on Windows, Material Switch on
/// mobile.
class AdaptiveSwitch extends StatelessWidget {
  const AdaptiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return fluent.ToggleSwitch(checked: value, onChanged: onChanged);
    }
    return material.Switch(value: value, onChanged: onChanged);
  }
}
