import 'dart:async';
import 'dart:developer';
import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:ytsmovies/src/utils/exceptions.dart';
import 'package:ytsmovies/src/services/connectivity_service.dart';

/// Interceptor for handling API errors and network issues
class NetworkConnectivityInterceptor extends Interceptor {
  final ConnectivityService _conn;
  final Dio _dio;
  final _requestQueue = ListQueue<_QueueRequest>();

  NetworkConnectivityInterceptor({
    required ConnectivityService connectivity,
    required Dio dio,
  })  : _conn = connectivity,
        _dio = dio,
        super() {
    _conn.stream.listen(
      (state) {
        if (state == ConnectivityState.connected) {
          for (final queueReq in _requestQueue) {
            _executeResponse(queueReq.options).then(
              (response) {
                _requestQueue.removeFirst();
                queueReq.completer.complete(response);
              },
              onError: (error) => queueReq.completer.completeError(error),
            );
          }
        }
      },
    );
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra['isRetryAttempt'] == true) {
      return handler.next(options);
    }

    final isDisconnected = await _conn.isDisconnected;
    log("Connectivity: ${!isDisconnected}");
    if (isDisconnected) {
      return handler.reject(
        DioException.connectionError(
          requestOptions: options,
          reason: "No internet connection. Request could not be sent.",
        ),
        true,
      );
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.extra['isRetryAttempt'] == true) {
      return handler.next(err);
    }

    log(
      'API Error: ${err.message}',
      error: err,
      stackTrace: err.stackTrace,
      time: DateTime.now(),
    );

    if (_isNetworkError(err)) {
      final completer = Completer<Response>();
      _requestQueue.add(_QueueRequest(
        completer: completer,
        options: err.requestOptions,
      ));
      log("Added attempt to queue, url: ${err.requestOptions.path}");

      try {
        final response = await completer.future;
        return handler.resolve(response);
      } on DioException catch (err) {
        final customError = _parseError(err);
        return handler.next(err.copyWith(error: customError));
      }
    }

    final customError = _parseError(err);
    return handler.next(err.copyWith(error: customError));
  }

  bool _isNetworkError(DioException err) =>
      err.type == DioExceptionType.connectionError;

  Future<Response> _executeResponse(RequestOptions options) {
    final extra = Map<String, dynamic>.from(options.extra);
    extra['isRetryAttempt'] = true;

    return _dio.fetch(options.copyWith(extra: extra));
  }

  CustomException _parseError(DioException error) {
    // Check connectivity status for network-related errors
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return CustomException('Connection timeout. Please try again.');
      case DioExceptionType.sendTimeout:
        return CustomException('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return CustomException('Server response timeout. Please try again.');
      case DioExceptionType.badCertificate:
        return const CustomException(
          'Certificate verification failed. Please check your connection.',
        );
      case DioExceptionType.badResponse:
        return _parseHttpError(error);
      case DioExceptionType.cancel:
        return const CustomException(
          'Request was cancelled.',
        );
      case DioExceptionType.connectionError:
        return CustomException('Connection failed. Please try again.');
      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException') ||
            error.error.toString().contains('Network is unreachable')) {
          return CustomException('Network error. Please try again.');
        }
        return CustomException(
          error.message ?? 'An unexpected error occurred. Please try again.',
        );
    }
  }

  CustomException _parseHttpError(DioException error) {
    final statusCode = error.response?.statusCode;
    final statusMessage = error.response?.statusMessage;

    switch (statusCode) {
      case 400:
        return const CustomException(
          'Invalid request. Please check your input and try again.',
        );
      case 401:
        return const CustomException(
          'Authentication failed. Please check your credentials.',
        );
      case 403:
        return const CustomException(
          'Access denied. You don\'t have permission to access this resource.',
        );
      case 404:
        return const CustomException(
          'The requested movie or resource was not found.',
        );
      case 408:
        return const CustomException(
          'Request timeout. Please try again.',
        );
      case 429:
        return const CustomException(
          'Too many requests. Please wait a moment and try again.',
        );
      case 500:
        return const CustomException(
          'Internal server error. Please try again later.',
        );
      case 502:
        return const CustomException(
          'Bad gateway. The server is temporarily unavailable.',
        );
      case 503:
        return const CustomException(
          'Service unavailable. Please try again later.',
        );
      case 504:
        return const CustomException(
          'Gateway timeout. The server is taking too long to respond.',
        );
      default:
        return CustomException(
          statusMessage ?? 'HTTP Error $statusCode. Please try again.',
        );
    }
  }
}

class _QueueRequest {
  final RequestOptions options;
  final Completer<Response> completer;

  _QueueRequest({required this.completer, required this.options});
}
