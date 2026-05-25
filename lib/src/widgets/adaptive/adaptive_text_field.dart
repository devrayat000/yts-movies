import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:ytsmovies/src/services/desktop_window_service.dart';

/// Single-line text input that renders fluent_ui TextBox on Windows
/// desktop and Material TextField on mobile. Wraps the common subset
/// the app uses; advanced cases should drop down to the platform widget.
class AdaptiveTextField extends StatelessWidget {
  const AdaptiveTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.style,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return fluent.TextBox(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        prefix: prefix,
        suffix: suffix,
        obscureText: obscureText,
        readOnly: readOnly,
        autofocus: autofocus,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        maxLength: maxLength,
        style: style,
      );
    }
    return material.TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      readOnly: readOnly,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      style: style,
      decoration: material.InputDecoration(
        hintText: placeholder,
        prefixIcon: prefix,
        suffixIcon: suffix,
      ),
    );
  }
}
