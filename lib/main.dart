import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:ytsmovies/src/app_initializer.dart';

void main() {
  runZonedGuarded(
    _initializeApp,
    (Object error, StackTrace stack) {
      log(error.toString(), error: error, stackTrace: stack);
    },
  );
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // In release mode, log the error but don't exit
      log('Flutter error: ${details.toString()}');
    }
  };

  // Run the app with initialization splash
  runApp(const YTSAppInitializer());
}
