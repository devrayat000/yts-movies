import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:ytsmovies/src/utils/exceptions.dart';
import 'package:ytsmovies/src/services/connectivity_service.dart';

/// Interceptor for handling API errors and network issues
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log(
      'API Error: ${err.message}',
      error: err,
      stackTrace: err.stackTrace,
      time: DateTime.now(),
    );

    final customError = _parseError(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: customError,
      response: err.response,
      stackTrace: err.stackTrace,
    ));
  }

  CustomException _parseError(DioException error) {
    // Check connectivity status for network-related errors
    final isConnected = ConnectivityService.instance.isConnected;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return CustomException(
          isConnected
              ? 'Connection timeout. Please try again.'
              : 'No internet connection. Please check your network settings.',
        );
      case DioExceptionType.sendTimeout:
        return CustomException(
          isConnected
              ? 'Request timeout. Please try again.'
              : 'No internet connection. Request could not be sent.',
        );
      case DioExceptionType.receiveTimeout:
        return CustomException(
          isConnected
              ? 'Server response timeout. Please try again.'
              : 'No internet connection. Unable to receive response.',
        );
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
        return CustomException(
          isConnected
              ? 'Connection failed. Please try again.'
              : 'No internet connection. Please check your network settings.',
        );
      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException') ||
            error.error.toString().contains('Network is unreachable')) {
          return CustomException(
            isConnected
                ? 'Network error. Please try again.'
                : 'No internet connection. Please check your network settings.',
          );
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
