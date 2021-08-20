import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:ytsmovies/utils/exceptions.dart';

Future<T> errorHandler<T>(Object? error, StackTrace stackTrace) {
  String message;

  if (error is SocketException) {
    message = 'No internet connection!';
  } else if (error is HttpException) {
    message = error.message;
  } else if (error is TimeoutException) {
    message = 'The request timed out!';
  } else if (error is PlatformException) {
    message = error.message ?? 'Unknown platfor exception!';
    if (error.stacktrace != null) {
      stackTrace = StackTrace.fromString(error.stacktrace!);
    }
  } else if (error is IsolateSpawnException) {
    message = error.message;
  } else if (error is TypeError) {
    message = 'Unfortunate type error!';
    stackTrace = error.stackTrace ?? stackTrace;
  } else if (error is HiveError) {
    message = error.message;
    stackTrace = error.stackTrace ?? stackTrace;
  } else {
    message = 'Unknown error occured!';
  }
  print(error);
  print(stackTrace);

  return Future.error(
    CustomException(message, stackTrace),
    stackTrace,
  );
}
