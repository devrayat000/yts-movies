import 'package:flutter/foundation.dart';

/// True on Windows/macOS/Linux when not running on the web.
bool get isDesktop =>
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.linux;

/// True on Windows specifically (excluded on web).
bool get isWindowsDesktop =>
    defaultTargetPlatform == TargetPlatform.windows && !kIsWeb;

bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
