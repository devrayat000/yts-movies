import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:ytsmovies/src/injection.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/services/connectivity_service.dart';

class _InitProgress {
  final String message;
  final double progress; // 0.0 to 1.0

  const _InitProgress(this.message, this.progress);
}

/// A splash screen wrapper that handles app initialization
class InitializationSplashScreen extends StatefulWidget {
  const InitializationSplashScreen({super.key});

  @override
  State<InitializationSplashScreen> createState() =>
      _InitializationSplashScreenState();
}

class _InitializationSplashScreenState
    extends State<InitializationSplashScreen> {
  late Stream<_InitProgress> _stream;

  @override
  void initState() {
    super.initState();
    // Start initialization when splash screen is first loaded
    _start();
  }

  void _start() {
    final stream = _initialize().asBroadcastStream();

    stream.listen(
      (_) {},
      onDone: () {
        if (mounted) context.pushReplacementNamed('home');
      },
      onError: (e, s) {
        log(e.toString(), error: e, stackTrace: s);
      },
    );

    setState(() {
      _stream = stream;
    });
  }

  Stream<_InitProgress> _initialize() async* {
    try {
      Timeline.startSync('init');

      yield const _InitProgress('Initializing Flutter engine...', 0.2);
      await Future.delayed(const Duration(milliseconds: 300));

      yield const _InitProgress('Setting up system UI...', 0.4);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 200));

      yield const _InitProgress('Opening data stores...', 0.6);
      await Future.wait([
        Hive.openBox<Movie>(MyBoxs.favouriteBox),
        Hive.openBox<String>(MyBoxs.searchHistoryBox),
      ]);
      await Future.delayed(const Duration(milliseconds: 300));

      yield const _InitProgress('Checking network connectivity...', 0.8);
      await getIt<ConnectivityService>().initialize();
      await Future.delayed(const Duration(milliseconds: 300));

      yield const _InitProgress('Initializing services...', 0.9);
      // Services are already initialized via dependency injection
      await Future.delayed(const Duration(milliseconds: 300));

      yield const _InitProgress('Finalizing setup...', 1.0);
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      Timeline.finishSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA);

    return Scaffold(
      restorationId: 'initialization_splash_screen',
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
          child: StreamBuilder(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final progress = snapshot.data!;
                return _buildLoadingView(context, colorScheme, progress);
              } else if (snapshot.hasError) {
                return _buildErrorView(context, colorScheme, snapshot.error);
              }
              return _buildLoadingView(context, colorScheme);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context, ColorScheme colorScheme,
      [_InitProgress? progress]) {
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
                opacity: clampDouble(value, 0, 1),
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
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                tween: Tween(
                  begin: 0.0,
                  end: progress?.progress ?? 0.0, // target value from stream
                ),
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
              ),

              const SizedBox(height: 20), // Current step text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  progress?.message ?? 'Starting initialization...',
                  key: ValueKey(progress?.message ?? 'starting'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface
                            .withAlpha((0.7 * 255).toInt()),
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

  Widget _buildErrorView(BuildContext context, ColorScheme colorScheme,
      [Object? error]) {
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

        const SizedBox(height: 20), // Error Message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            error?.toString() ?? 'An unexpected error occurred',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
                ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 40), // Retry Button
        ElevatedButton.icon(
          onPressed: _start,
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
