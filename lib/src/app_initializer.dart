import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ytsmovies/hive/hive_registrar.g.dart';

import 'package:ytsmovies/src/api/client.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/app.dart';
import 'package:ytsmovies/src/bloc/filter/index.dart';
import 'package:ytsmovies/src/widgets/splash/splash_wrapper.dart';
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
    Hive.registerAdapters();
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
