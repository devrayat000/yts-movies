import 'package:flutter/material.dart';

/// Custom splash screen for app initialization
class InitializationSplashScreen extends StatelessWidget {
  final String currentStep;
  final VoidCallback? onRetry;
  final String? errorMessage;

  const InitializationSplashScreen({
    super.key,
    required this.currentStep,
    this.onRetry,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF111827),
                    const Color(0xFF1F2937),
                  ]
                : [
                    const Color(0xFFFAFAFA),
                    const Color(0xFFF5F5F5),
                    const Color(0xFFE5E7EB),
                  ],
          ),
        ),
        child: SafeArea(
          child: errorMessage != null
              ? _buildErrorView(context, colorScheme)
              : _buildLoadingView(context, colorScheme),
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),

        // YTS Logo
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1500),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'images/logo-YTS.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
        ),

        // Animated Progress Indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            children: [
              // Continuous progress animation
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 4,
                        width: MediaQuery.of(context).size.width * value * 0.7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Restart animation for continuous effect
                  if (errorMessage == null) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        (context as Element).markNeedsBuild();
                      }
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // Current step text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  currentStep,
                  key: ValueKey(currentStep),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        letterSpacing: 0.3,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        const Spacer(flex: 3),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),

        // Error Icon
        Icon(
          Icons.error_outline,
          size: 80,
          color: colorScheme.error,
        ),

        const SizedBox(height: 30),

        // Error Title
        Text(
          'Initialization Failed',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 20),

        // Error Message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            errorMessage ?? 'An unexpected error occurred',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 40),

        // Retry Button
        if (onRetry != null)
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),

        const Spacer(),
      ],
    );
  }
}
