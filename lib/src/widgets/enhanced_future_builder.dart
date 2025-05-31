part of 'index.dart';

class MyFutureBuilder<T> extends StatelessWidget {
  final Future<T>? future;
  final T? initialData;
  final Widget Function(BuildContext, Object?) errorBuilder;
  final Widget Function(BuildContext, T?) successBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? idleBuilder;
  final VoidCallback? onRetry;
  final String? loadingMessage;
  final bool showFullPageError;
  final String? errorMessage;
  final bool checkConnectivity;

  const MyFutureBuilder({
    super.key,
    this.future,
    this.initialData,
    this.loadingBuilder,
    this.idleBuilder,
    this.onRetry,
    this.loadingMessage,
    this.showFullPageError = true,
    this.errorMessage,
    this.checkConnectivity = true,
    required this.errorBuilder,
    required this.successBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return idleBuilder?.call(context) ??
                _defaultLoadingBuilder(context);
          case ConnectionState.waiting:
          case ConnectionState.active:
            return loadingBuilder?.call(context) ??
                _defaultLoadingBuilder(context);
          case ConnectionState.done:
            if (snapshot.hasError) {
              // Check if it's a connectivity issue
              if (checkConnectivity &&
                  !ConnectivityService.instance.isConnected) {
                return OfflineWidget(
                  onRetry: onRetry,
                );
              }

              // Enhanced error handling with better UX
              if (showFullPageError) {
                return ErrorDisplayWidget(
                  error: snapshot.error!,
                  onRetry: onRetry,
                  customMessage: errorMessage,
                );
              } else {
                return CompactErrorWidget(
                  error: snapshot.error!,
                  onRetry: onRetry,
                  customMessage: errorMessage,
                );
              }
            } else if (snapshot.hasData) {
              return successBuilder(context, snapshot.data);
            } else {
              return EmptyStateWidget(
                title: 'No Data Available',
                subtitle: 'There seems to be no data to display.',
                icon: Icons.inbox_outlined,
                onAction: onRetry,
                actionLabel: onRetry != null ? 'Retry' : null,
              );
            }
        }
      },
    );
  }

  Widget _defaultLoadingBuilder(BuildContext context) {
    return LoadingStateWidget(
      message: loadingMessage ?? 'Loading...',
    );
  }
}
