import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ytsmovies/src/app.dart';
import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/bloc/download_manager/index.dart';
import 'package:ytsmovies/src/injection.dart';
import 'package:ytsmovies/src/services/desktop_window_service.dart';
import 'package:ytsmovies/src/services/notification_service.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/router.dart';

/// Main app widget that handles initialization and provides dependencies
class YTSAppInitializer extends StatefulWidget {
  const YTSAppInitializer({super.key});

  @override
  State<YTSAppInitializer> createState() => _YTSAppInitializerState();
}

class _YTSAppInitializerState extends State<YTSAppInitializer> {
  bool _isInitializing = true;
  String? _error;
  StreamSubscription<int>? _notificationSubscription;
  DesktopWindowService? _desktopWindowService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize dependency injection
      await configureDependencies();

      // Initialize notification service and listen for taps
      final notificationService = getIt<NotificationService>();
      _notificationSubscription = notificationService.notificationTapStream
          .listen(_handleNotificationTap);

      // Initialize desktop window + tray integration (no-op off desktop)
      if (isDesktop) {
        _desktopWindowService =
            DesktopWindowService(getIt<DownloadManagerBloc>());
        await _desktopWindowService!.initialize();
      }

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      log('Initialization error: $e', error: e);
      setState(() {
        _error = e.toString();
        _isInitializing = false;
      });
    }
  }

  void _handleNotificationTap(int taskId) {
    // Get the download task to determine its status
    final downloadBloc = getIt<DownloadManagerBloc>();
    final task = downloadBloc.state.downloads[taskId];

    if (task == null) return;

    // Navigate based on download status
    final context = RouterExtension.rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    if (task.status == DownloadStatus.downloading ||
        task.status == DownloadStatus.paused ||
        task.status == DownloadStatus.downloadingMetadata ||
        task.status == DownloadStatus.queued) {
      // Navigate to download details page
      context.pushNamed(
        'download-details',
        pathParameters: {'taskId': taskId.toString()},
      );
    } else if (task.status == DownloadStatus.completed) {
      // Navigate to downloads page (user can tap there to open file)
      context.pushNamed('downloads');
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _desktopWindowService?.dispose();
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
          create: (_) => getIt<ThemeCubit>(),
        ),
        BlocProvider<DownloadManagerBloc>(
          create: (_) =>
              getIt<DownloadManagerBloc>()..add(DownloadManagerStarted()),
        ),
      ],
      child: YTSApp(),
    );
  }
}
