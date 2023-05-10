import 'dart:async';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheInterceptop implements RequestInterceptor, ResponseInterceptor {
  @override
  FutureOr<Request> onRequest(Request request) async {
    final info =
        await DefaultCacheManager().getFileFromCache(request.url.toString());
    if (info != null && await info.file.exists()) {
      // Return the cached response if available and not forced to refresh

      return applyHeader(
          request, HttpHeaders.ifNoneMatchHeader, info.file.basename);
    } else {
      // Add the cache control headers to the request
      return applyHeader(
          request, HttpHeaders.cacheControlHeader, 'max-age=3600');
    }
  }

  @override
  FutureOr<Response> onResponse(Response response) async {
    // Use the URL as the cache key
    // final key = response.request.url;
    final key = response.base.request!.url.toString();
    // Save the response to the cache
    await DefaultCacheManager().putFile(
      key,
      response.bodyBytes,
      eTag: response.headers[HttpHeaders.etagHeader],
      key: key,
    );
    return response;
  }
}
