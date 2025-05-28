import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:ytsmovies/src/utils/exceptions.dart';

/// Service for reporting and tracking errors
class ErrorReportingService {
  static final ErrorReportingService _instance =
      ErrorReportingService._internal();
  static ErrorReportingService get instance => _instance;

  ErrorReportingService._internal();

  final List<ErrorReport> _errorHistory = [];
  final StreamController<ErrorReport> _errorController =
      StreamController<ErrorReport>.broadcast();

  /// Stream of error reports
  Stream<ErrorReport> get errorStream => _errorController.stream;

  /// Get error history
  List<ErrorReport> get errorHistory => List.unmodifiable(_errorHistory);

  /// Report an error with context
  void reportError({
    required Object error,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? metadata,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    final report = ErrorReport(
      error: error,
      stackTrace: stackTrace,
      context: context,
      metadata: metadata,
      severity: severity,
      timestamp: DateTime.now(),
    );

    // Add to history (keep last 100 errors)
    _errorHistory.add(report);
    if (_errorHistory.length > 100) {
      _errorHistory.removeAt(0);
    }

    // Log the error
    _logError(report);

    // Emit to stream
    _errorController.add(report);

    // In a real app, you would send this to your analytics/crash reporting service
    // For example: Firebase Crashlytics, Sentry, Bugsnag, etc.
    if (kReleaseMode) {
      _sendToAnalytics(report);
    }
  }

  /// Log error with appropriate level based on severity
  void _logError(ErrorReport report) {
    final message =
        'Error in ${report.context ?? 'unknown context'}: ${report.error}';

    switch (report.severity) {
      case ErrorSeverity.low:
        log(message, name: 'YTSMovies', level: 800); // Info level
        break;
      case ErrorSeverity.medium:
        log(message,
            name: 'YTSMovies',
            level: 900,
            error: report.error,
            stackTrace: report.stackTrace); // Warning level
        break;
      case ErrorSeverity.high:
        log(message,
            name: 'YTSMovies',
            level: 1000,
            error: report.error,
            stackTrace: report.stackTrace); // Error level
        break;
      case ErrorSeverity.critical:
        log(message,
            name: 'YTSMovies',
            level: 1200,
            error: report.error,
            stackTrace: report.stackTrace); // Severe level
        break;
    }
  }

  /// Send error report to analytics service (placeholder implementation)
  void _sendToAnalytics(ErrorReport report) {
    // TODO: Implement actual analytics reporting
    // Examples:
    // - Firebase Crashlytics: FirebaseCrashlytics.instance.recordError(...)
    // - Sentry: Sentry.captureException(...)
    // - Custom analytics endpoint

    debugPrint('Analytics: Error reported - ${report.error.runtimeType}');
  }

  /// Get error statistics
  ErrorStatistics getStatistics() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final lastWeek = now.subtract(const Duration(days: 7));

    final recentErrors =
        _errorHistory.where((e) => e.timestamp.isAfter(last24Hours)).toList();
    final weeklyErrors =
        _errorHistory.where((e) => e.timestamp.isAfter(lastWeek)).toList();

    final severityCount = <ErrorSeverity, int>{};
    for (final error in _errorHistory) {
      severityCount[error.severity] = (severityCount[error.severity] ?? 0) + 1;
    }

    return ErrorStatistics(
      totalErrors: _errorHistory.length,
      recentErrors: recentErrors.length,
      weeklyErrors: weeklyErrors.length,
      severityBreakdown: severityCount,
      mostCommonErrors: _getMostCommonErrors(),
    );
  }

  /// Get most common error types
  List<String> _getMostCommonErrors() {
    final errorTypes = <String, int>{};

    for (final error in _errorHistory) {
      final type = error.error.runtimeType.toString();
      errorTypes[type] = (errorTypes[type] ?? 0) + 1;
    }

    final sorted = errorTypes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => '${e.key} (${e.value})').toList();
  }

  /// Clear error history
  void clearHistory() {
    _errorHistory.clear();
  }

  /// Dispose of the service
  void dispose() {
    _errorController.close();
  }
}

/// Represents an error report with metadata
class ErrorReport {
  final Object error;
  final StackTrace? stackTrace;
  final String? context;
  final Map<String, dynamic>? metadata;
  final ErrorSeverity severity;
  final DateTime timestamp;

  const ErrorReport({
    required this.error,
    this.stackTrace,
    this.context,
    this.metadata,
    required this.severity,
    required this.timestamp,
  });

  /// Get a user-friendly error message
  String get userMessage {
    if (error is CustomException) {
      return (error as CustomException).message;
    }
    return error.toString();
  }

  /// Get error type name
  String get errorType => error.runtimeType.toString();
}

/// Error severity levels
enum ErrorSeverity {
  low, // Minor issues, informational
  medium, // Standard errors that don't break functionality
  high, // Serious errors that impact functionality
  critical, // Critical errors that break core functionality
}

/// Error statistics data
class ErrorStatistics {
  final int totalErrors;
  final int recentErrors;
  final int weeklyErrors;
  final Map<ErrorSeverity, int> severityBreakdown;
  final List<String> mostCommonErrors;

  const ErrorStatistics({
    required this.totalErrors,
    required this.recentErrors,
    required this.weeklyErrors,
    required this.severityBreakdown,
    required this.mostCommonErrors,
  });
}
