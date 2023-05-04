import 'dart:developer';

import 'package:chopper/chopper.dart';
import 'package:ytsmovies/src/api/converter.dart';
import 'package:ytsmovies/src/api/decoder.dart';

import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/api/trim_request_interceptop.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:squadron/squadron.dart';

void initSquadron(String id) {
  Squadron.setId(id);
  Squadron.setLogger(ConsoleSquadronLogger());
  Squadron.logLevel = SquadronLogLevel.all;
  Squadron.debugMode = true;
}

Future<ChopperClient> initClient() async {
  initSquadron('yts_worker_pool');
  final jsonDecodeServiceWorkerPool = JsonDecodeServiceWorkerPool(
    // Set whatever you want here
    concurrencySettings: ConcurrencySettings.oneCpuThread,
  );

  /// start the Worker Pool
  await jsonDecodeServiceWorkerPool.start();

  /// Instantiate the JsonConverter from above
  final converter = JsonSerializableWorkerPoolConverter(
    const {
      MovieListResponse: MovieListResponse.fromJson,
      MovieResponse: MovieResponse.fromJson,
    },
    jsonDecodeServiceWorkerPool,
  );

  return ChopperClient(
    baseUrl: Uri.parse('https://yts.mx'),
    converter: converter,
    errorConverter: converter,
    services: [
      MoviesListService.create(),
    ],
    interceptors: [
      HttpLoggingInterceptor(),
      TrimRequestInterceptop(),
      (Response res) {
        log(res.body.toString());
        return res;
      }
    ],
  );
}
