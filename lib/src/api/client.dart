import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';

Future<MoviesClient> initClient() async {
  final tempDir = await getTemporaryDirectory();
  final options = CacheOptions(
    store: HiveCacheStore(tempDir.path),
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(hours: 1),
    priority: CachePriority.normal,
    cipher: null,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
  );
  final dio = Dio()
    ..interceptors.add(DioCacheInterceptor(options: options))
    ..interceptors.add(LogInterceptor(
      responseBody: false,
      requestBody: false,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  return MoviesClient(dio);
}
