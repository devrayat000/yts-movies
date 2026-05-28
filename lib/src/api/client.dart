import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/api/error_interceptor.dart';
import 'package:ytsmovies/src/services/connectivity_service.dart';

@module
abstract class ApiModule {
  @singleton
  Future<MoviesClient> initClient({required ConnectivityService conn}) async {
    final tempDir = await getTemporaryDirectory();
    final cacheOptions = CacheOptions(
      store: HiveCacheStore(tempDir.path),
      policy: CachePolicy.request,
      maxStale: const Duration(days: 30),
      priority: CachePriority.normal,
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      allowPostMethod: false,
      hitCacheOnNetworkFailure: true,
      hitCacheOnErrorCodes: const [500],
    );
    final dio = Dio();
    dio
      ..interceptors.addAll([
        if (kDebugMode)
          LogInterceptor(
            responseBody: false,
            requestBody: false,
            logPrint: (obj) => log(obj.toString()),
          ),
        DioCacheInterceptor(options: cacheOptions),
        NetworkConnectivityInterceptor(
          connectivity: conn,
          dio: dio,
        ),
        // ErrorInterceptor(),
        // QueuedInterceptor(),
      ]);

    return MoviesClient(dio);
  }
}
