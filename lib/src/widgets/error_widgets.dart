import 'package:flutter/material.dart';
import 'package:ytsmovies/src/utils/exceptions.dart';

/// Enhanced error widget with better UX
class ErrorDisplayWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final String? customMessage;
  final bool showDetails;
  final EdgeInsetsGeometry? padding;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.customMessage,
    this.showDetails = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = customMessage ?? _getErrorMessage(error);
    final icon = _getErrorIcon(error);
    final color = _getErrorColor(error);

    return Container(
      padding: padding ?? const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              size: 48,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getErrorSubtitle(error),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
          if (showDetails && error.toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Error Details'),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getErrorMessage(Object error) {
    if (error is CustomException) {
      return error.message;
    } else if (error is TorrentClientException) {
      return error.message;
    } else if (error.toString().contains('SocketException')) {
      return 'No Internet Connection';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request Timed Out';
    } else if (error.toString().contains('No movie found')) {
      return 'No Movies Found';
    } else if (error.toString().contains('404')) {
      return 'Movie Not Found';
    } else if (error.toString().contains('500') ||
        error.toString().contains('503')) {
      return 'Server Error';
    } else {
      return 'Something Went Wrong';
    }
  }

  String _getErrorSubtitle(Object error) {
    if (error.toString().contains('SocketException')) {
      return 'Please check your internet connection and try again.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'The request took too long. Please try again.';
    } else if (error.toString().contains('No movie found')) {
      return 'Try adjusting your search terms or browse different categories.';
    } else if (error.toString().contains('404')) {
      return 'This movie is no longer available.';
    } else if (error.toString().contains('500') ||
        error.toString().contains('503')) {
      return 'Our servers are experiencing issues. Please try again later.';
    } else if (error is TorrentClientException) {
      return 'Make sure you have a torrent client installed.';
    } else {
      return 'We encountered an unexpected error. Please try again.';
    }
  }

  IconData _getErrorIcon(Object error) {
    if (error.toString().contains('SocketException')) {
      return Icons.wifi_off_rounded;
    } else if (error.toString().contains('TimeoutException')) {
      return Icons.access_time_rounded;
    } else if (error.toString().contains('No movie found')) {
      return Icons.movie_filter_outlined;
    } else if (error.toString().contains('404')) {
      return Icons.search_off_rounded;
    } else if (error.toString().contains('500') ||
        error.toString().contains('503')) {
      return Icons.dns_rounded;
    } else if (error is TorrentClientException) {
      return Icons.download_rounded;
    } else {
      return Icons.error_outline_rounded;
    }
  }

  Color _getErrorColor(Object error) {
    if (error.toString().contains('SocketException')) {
      return Colors.orange;
    } else if (error.toString().contains('TimeoutException')) {
      return Colors.amber;
    } else if (error.toString().contains('No movie found')) {
      return Colors.blue;
    } else if (error.toString().contains('404')) {
      return Colors.indigo;
    } else if (error.toString().contains('500') ||
        error.toString().contains('503')) {
      return Colors.purple;
    } else if (error is TorrentClientException) {
      return Colors.teal;
    } else {
      return Colors.red;
    }
  }
}

/// Compact error widget for inline usage
class CompactErrorWidget extends StatelessWidget {
  final Object? error;
  final VoidCallback? onRetry;
  final String? customMessage;

  const CompactErrorWidget({
    super.key,
    this.error,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = customMessage ?? _getCompactErrorMessage(error);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  String _getCompactErrorMessage(Object? error) {
    if (error is CustomException) {
      return error.message;
    } else if (error.toString().contains('SocketException')) {
      return 'No internet connection';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out';
    } else if (error.toString().contains('No movie found')) {
      return 'No movies found';
    } else {
      return 'Something went wrong';
    }
  }
}

/// Loading state widget with better UX
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool showProgress;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showProgress) ...[
            CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
          ],
          if (message != null)
            Text(
              message!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

/// Empty state widget for when no data is available
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon ?? Icons.inbox_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
