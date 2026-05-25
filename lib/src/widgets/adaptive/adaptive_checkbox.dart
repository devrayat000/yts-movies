import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';

import 'package:ytsmovies/src/services/desktop_window_service.dart';

class AdaptiveCheckbox extends StatelessWidget {
  const AdaptiveCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return fluent.Checkbox(
        checked: value,
        onChanged: onChanged,
      );
    }
    return material.Checkbox(
      value: value,
      onChanged: onChanged,
      tristate: tristate,
    );
  }
}
