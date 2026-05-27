import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// True on Windows/macOS/Linux when not running on the web.
bool get isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

/// True on Windows specifically (excluded on web).
bool get isWindowsDesktop => !kIsWeb && Platform.isWindows;
