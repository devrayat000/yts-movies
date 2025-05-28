import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ytsmovies/src/utils/exceptions.dart';
import './error_reporting_service.dart';

/// Service for handling and displaying errors consistently across the app
class ErrorNotificationService {
  static final ErrorNotificationService _instance =
      ErrorNotificationService._();
  static ErrorNotificationService get instance => _instance;

  ErrorNotificationService._();

  /// Show error notification with proper user-friendly messages
  void showError(
    BuildContext context,
    Object error, {
    String? customMessage,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
    bool isFloating = true,
  }) {
    final message = customMessage ?? _getErrorMessage(error);

    // Report error to analytics/reporting service
    ErrorReportingService.instance.reportError(
      error: error,
      context: 'User notification',
      metadata: {
        'customMessage': customMessage,
        'userFriendlyMessage': message
      },
      severity: _getErrorSeverity(error),
    );

    // Log error for debugging
    log(
      'Error displayed to user: $message',
      error: error,
      time: DateTime.now(),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error),
        duration: duration,
        behavior:
            isFloating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
        shape: isFloating
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            : null,
        margin: isFloating
            ? const EdgeInsets.only(bottom: 16, left: 16, right: 16)
            : null,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry();
                },
              )
            : null,
      ),
    );
  }

  /// Show success notification
  void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      ),
    );
  }

  /// Show loading notification
  void showLoading(
    BuildContext context,
    String message,
  ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        duration: const Duration(seconds: 30), // Long duration for loading
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      ),
    );
  }

  /// Hide current notification
  void hideCurrentNotification(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Get user-friendly error message
  String _getErrorMessage(Object error) {
    if (error is CustomException) {
      return error.message;
    } else if (error is TorrentClientException) {
      return error.message;
    } else if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('FormatException')) {
      return 'Invalid data format received. Please try again.';
    } else if (error.toString().contains('No movie found')) {
      return 'No movies found for your search.';
    } else if (error.toString().contains('404')) {
      return 'Movie not found.';
    } else if (error.toString().contains('500') ||
        error.toString().contains('503')) {
      return 'Server is temporarily unavailable. Please try again later.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Get appropriate icon for error type
  IconData _getErrorIcon(Object error) {
    if (error.toString().contains('SocketException')) {
      return Icons.wifi_off;
    } else if (error.toString().contains('TimeoutException')) {
      return Icons.access_time;
    } else if (error.toString().contains('No movie found')) {
      return Icons.search_off;
    } else if (error is TorrentClientException) {
      return Icons.download;
    } else {
      return Icons.error_outline;
    }
  }

  /// Get appropriate color for error type
  Color _getErrorColor(Object error) {
    if (error.toString().contains('SocketException')) {
      return Colors.orange.shade600;
    } else if (error.toString().contains('No movie found')) {
      return Colors.blue.shade600;
    } else if (error is TorrentClientException) {
      return Colors.purple.shade600;
    } else {
      return Colors.red.shade600;
    }
  }

  /// Get error severity level for analytics/reporting
  ErrorSeverity _getErrorSeverity(Object error) {
    if (error is CustomException) {
      // Custom exceptions are usually business logic issues, medium priority
      return ErrorSeverity.medium;
    } else if (error is TorrentClientException) {
      // Torrent-related errors are functional but not critical
      return ErrorSeverity.medium;
    } else if (error.toString().contains('SocketException')) {
      // Network connectivity issues are high priority as they block functionality
      return ErrorSeverity.high;
    } else if (error.toString().contains('TimeoutException')) {
      // Timeouts are medium priority, could be temporary
      return ErrorSeverity.medium;
    } else if (error.toString().contains('FormatException')) {
      // Data format issues are high priority as they indicate API changes
      return ErrorSeverity.high;
    } else if (error.toString().contains('No movie found')) {
      // Search returning no results is expected behavior, low priority
      return ErrorSeverity.low;
    } else if (error.toString().contains('404')) {
      // Not found errors are medium priority
      return ErrorSeverity.medium;
    } else if (error.toString().contains('500') ||
        error.toString().contains('503')) {
      // Server errors are high priority as they indicate backend issues
      return ErrorSeverity.high;
    } else {
      // Unknown errors are high priority to ensure they get attention
      return ErrorSeverity.high;
    }
  }
}

/// Extension to make error handling easier in widgets
extension ErrorHandling on BuildContext {
  void showError(Object error, {String? customMessage, VoidCallback? onRetry}) {
    ErrorNotificationService.instance.showError(
      this,
      error,
      customMessage: customMessage,
      onRetry: onRetry,
    );
  }

  void showSuccess(String message) {
    ErrorNotificationService.instance.showSuccess(this, message);
  }

  void showLoading(String message) {
    ErrorNotificationService.instance.showLoading(this, message);
  }

  void hideNotification() {
    ErrorNotificationService.instance.hideCurrentNotification(this);
  }
}
