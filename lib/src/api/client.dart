import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/api/error_interceptor.dart';

Future<MoviesClient> initClient() async {
  final tempDir = await getTemporaryDirectory();
  final cacheOptions = CacheOptions(
    store: HiveCacheStore(tempDir.path),
    policy: CachePolicy.request,
    maxStale: const Duration(hours: 1),
    priority: CachePriority.normal,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
    hitCacheOnNetworkFailure: true,
  );
  final dio = Dio()
    ..interceptors.addAll([
      ErrorInterceptor(),
      DioCacheInterceptor(options: cacheOptions),
      if (kDebugMode)
        LogInterceptor(
          responseBody: false,
          requestBody: false,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
    ]);

  return MoviesClient(dio);
}
