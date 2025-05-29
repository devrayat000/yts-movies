import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ytsmovies/src/api/client.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/app.dart';
import 'package:ytsmovies/src/bloc/filter/index.dart';
import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/theme/index.dart';
import 'package:ytsmovies/src/services/connectivity_service.dart';

/// App initialization states
enum AppInitState {
  initializing,
  ready,
  error,
}

/// Main app widget that handles initialization with splash screen
class YTSAppInitializer extends StatefulWidget {
  const YTSAppInitializer({super.key});

  @override
  State<YTSAppInitializer> createState() => _YTSAppInitializerState();
}

class _YTSAppInitializerState extends State<YTSAppInitializer> {
  AppInitState _initState = AppInitState.initializing;
  MoviesClient? _client;
  String? _errorMessage;
  final List<String> _initSteps = [];
  String _currentStep = 'Starting initialization...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      Timeline.startSync('init');

      await _updateStep('Initializing Flutter engine...');
      await Future.delayed(const Duration(milliseconds: 300));

      await _updateStep('Setting up system UI...');
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 200));

      await _updateStep('Initializing local storage...');
      await _initializeHive();
      await Future.delayed(const Duration(milliseconds: 300));

      await _updateStep('Setting up data persistence...');
      await _initializeHydratedStorage();
      await Future.delayed(const Duration(milliseconds: 300));

      await _updateStep('Opening data stores...');
      await Future.wait([
        Hive.openBox<Movie>(MyBoxs.favouriteBox),
        Hive.openBox<String>(MyBoxs.searchHistoryBox),
      ]);
      await Future.delayed(const Duration(milliseconds: 300));

      await _updateStep('Checking network connectivity...');
      await ConnectivityService.instance.initialize();
      await Future.delayed(const Duration(milliseconds: 300));

      await _updateStep('Initializing API client...');
      final client = await initClient();
      await Future.delayed(const Duration(milliseconds: 300));

      Timeline.finishSync();

      await _updateStep('Finalizing setup...');
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _client = client;
          _initState = AppInitState.ready;
        });
      }
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      if (mounted) {
        setState(() {
          _initState = AppInitState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _updateStep(String step) async {
    if (mounted) {
      setState(() {
        _currentStep = step;
        _initSteps.add(step);
      });
    }
  }

  Future<void> _initializeHive() async {
    await Hive.initFlutter();
    Hive
      ..registerAdapter(MovieAdapter())
      ..registerAdapter(TorrentAdapter());
  }

  Future<void> _initializeHydratedStorage() async {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorageDirectory.web
          : HydratedStorageDirectory((await getTemporaryDirectory()).path),
    );
  }

  Widget _buildApp(MoviesClient client) {
    return MultiProvider(
      providers: [
        RepositoryProvider<MoviesClient>(
          create: (_) => client,
        ),
        Provider<Filter>(
          create: (_) => Filter(),
          dispose: (_, filter) => filter.reset(),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(theme: AppTheme()),
        ),
      ],
      child: const YTSApp(),
    );
  }

  Widget _buildInitializationSplash() {
    return MaterialApp(
      title: 'YTS Movies',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF8B5CF6),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF818CF8),
          secondary: Color(0xFFA855F7),
        ),
      ),
      home: InitializationSplashScreen(
        currentStep: _currentStep,
        onRetry: _initState == AppInitState.error
            ? () {
                setState(() {
                  _initState = AppInitState.initializing;
                  _errorMessage = null;
                  _initSteps.clear();
                });
                _initializeApp();
              }
            : null,
        errorMessage: _errorMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_initState) {
      case AppInitState.initializing:
        return _buildInitializationSplash();
      case AppInitState.ready:
        return _client != null
            ? _buildApp(_client!)
            : _buildInitializationSplash();
      case AppInitState.error:
        return _buildInitializationSplash();
    }
  }
}

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

        const SizedBox(height: 40),

        // App Title
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Text(
                'YTS Movies',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
            );
          },
        ),

        const SizedBox(height: 60),

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
