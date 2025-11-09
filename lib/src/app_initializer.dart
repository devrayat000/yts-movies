import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/app.dart';
import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/bloc/download_manager/index.dart';
import 'package:ytsmovies/src/services/preferences_service.dart';
import 'package:ytsmovies/src/services/foreground_download_service.dart';
import 'package:ytsmovies/src/theme/index.dart';

/// Main app widget that handles initialization and provides dependencies
class YTSAppInitializer extends StatefulWidget {
  const YTSAppInitializer({super.key});

  @override
  State<YTSAppInitializer> createState() => _YTSAppInitializerState();
}

class _YTSAppInitializerState extends State<YTSAppInitializer> {
  bool _isInitializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize preferences service first
      await PreferencesService.initialize();

      // Initialize foreground download service
      await ForegroundDownloadService.instance.initialize();

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Initialization error: $_error'),
          ),
        ),
      );
    }

    // Always provide the theme cubit and download manager since storage is now initialized
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(theme: AppTheme()),
        ),
        BlocProvider(
          create: (_) => MoviesClientCubit(),
        ),
        BlocProvider<DownloadManagerBloc>(
          create: (_) => DownloadManagerBloc()..add(DownloadManagerStarted()),
        ),
      ],
      child: const YTSApp(),
    );
  }
}
