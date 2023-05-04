import 'dart:async';

import 'package:chopper/chopper.dart';

class TrimRequestInterceptop implements RequestInterceptor {
  @override
  FutureOr<Request> onRequest(Request request) {
    request.parameters.removeWhere(
        (key, value) => value == null || value == '0' || value == 'null');
    return request;
  }
}
