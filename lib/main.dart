import 'dart:async';
import 'dart:developer';
import 'package:logging/logging.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ytsmovies/hive/hive_registrar.g.dart';

import 'package:ytsmovies/src/app_initializer.dart';

void main() {
  Logger.root.level = Level.ALL; // Set root logger level
  Logger.root.onRecord.listen((record) {
    debugPrint(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });
  runZonedGuarded(
    _initializeApp,
    (Object error, StackTrace stack) {
      debugPrint('Error: $error');
      debugPrint('Stack: $stack');
    },
  );
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize critical storage first (before any UI)
  await _initializeCriticalStorage();

  // Set error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // In release mode, log the error but don't exit
      debugPrint('Flutter error: ${details.toString()}');
    }
  };

  // Run the app with initialization splash
  runApp(const YTSAppInitializer());
}

Future<void> _initializeCriticalStorage() async {
  try {
    // Initialize Hive
    await Hive.initFlutter();
    Hive.registerAdapters();

    // Initialize Hydrated Storage
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorageDirectory.web
          : HydratedStorageDirectory(
              (await getApplicationDocumentsDirectory()).path),
    );
  } catch (e) {
    debugPrint('Failed to initialize critical storage: $e');
    // Continue with app startup even if storage fails
  }
}
