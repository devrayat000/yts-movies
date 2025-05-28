import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ytsmovies/src/api/movies.dart';

Future<MoviesClient> initClient() async {
  final tempDir = await getTemporaryDirectory();
  final cacheOptions = CacheOptions(
    store: HiveCacheStore(tempDir.path),
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: const [401, 403],
    maxStale: const Duration(hours: 1),
    priority: CachePriority.normal,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
  );

  final dio = Dio()
    ..interceptors.addAll([
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
