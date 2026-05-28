import 'package:flutter/material.dart';

/// Breakpoints used across the app for responsive widget rendering.
class Breakpoints {
  static const double compact = 600; // phones
  static const double medium = 900; // small tablets / phablet landscape
  static const double expanded = 1240; // tablets / small desktops
  static const double large = 1600; // large desktops
}

enum ScreenSize { compact, medium, expanded, large }

extension ResponsiveBuildContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ScreenSize get screenSize {
    final w = screenWidth;
    if (w < Breakpoints.compact) return ScreenSize.compact;
    if (w < Breakpoints.medium) return ScreenSize.medium;
    if (w < Breakpoints.expanded) return ScreenSize.expanded;
    return ScreenSize.large;
  }

  /// Returns true when the viewport is wide enough to use desktop-style layouts.
  bool get isWideScreen => screenWidth >= Breakpoints.medium;

  /// Suggested poster grid column count for the current viewport.
  int posterGridColumns({double targetItemWidth = 200}) {
    final w = screenWidth - 16; // account for default 8.0 padding
    final cols = (w / targetItemWidth).floor();
    return cols.clamp(2, 8);
  }

  /// Suggested height for the horizontal intro carousels on home page.
  double get introCarouselHeight {
    switch (screenSize) {
      case ScreenSize.compact:
        return 200;
      case ScreenSize.medium:
        return 240;
      case ScreenSize.expanded:
        return 280;
      case ScreenSize.large:
        return 320;
    }
  }
}
