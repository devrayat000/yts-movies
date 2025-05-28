import 'package:flutter/material.dart';
import 'package:ytsmovies/src/services/connectivity_service.dart';

/// Widget that displays network connectivity status
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  final bool showWhenConnected;

  const ConnectivityBanner({
    super.key,
    required this.child,
    this.showWhenConnected = false,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Listen to connectivity changes
    _isConnected = ConnectivityService.instance.isConnected;
    ConnectivityService.instance.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });

        if (!isConnected) {
          _animationController.forward();
        } else {
          if (widget.showWhenConnected) {
            _animationController.forward();
            // Hide after showing briefly when reconnected
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                _animationController.reverse();
              }
            });
          } else {
            _animationController.reverse();
          }
        }
      }
    });

    // Show banner initially if offline
    if (!_isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _heightAnimation,
          builder: (context, child) {
            return SizeTransition(
              sizeFactor: _heightAnimation,
              child: Container(
                width: double.infinity,
                color: _isConnected ? Colors.green : Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isConnected
                            ? 'Connection restored'
                            : 'No internet connection',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!_isConnected)
                      TextButton(
                        onPressed: () async {
                          // Trigger a connectivity check
                          await ConnectivityService.instance
                              .hasInternetConnection();
                        },
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Widget that shows an offline placeholder when there's no internet
class OfflineWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const OfflineWidget({
    super.key,
    this.title = 'No Internet Connection',
    this.subtitle = 'Please check your network settings and try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
