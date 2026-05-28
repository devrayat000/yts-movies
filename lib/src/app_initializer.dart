import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:ytsmovies/src/app.dart';
import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/bloc/download_manager/index.dart';
import 'package:ytsmovies/src/injection.dart';
import 'package:ytsmovies/src/services/connectivity_service.dart';
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

class _YTSAppInitializerState extends State<YTSAppInitializer>
    with WindowListener, TrayListener {
  bool _isInitializing = true;
  String? _error;
  StreamSubscription<NotificationResponse>? _notificationSubscription;
  StreamSubscription<DownloadManagerState>? _downloadSubscription;
  bool _desktopInitialized = false;

  static const _trayShowKey = 'show_app';
  static const _trayPauseKey = 'pause_all';
  static const _trayResumeKey = 'resume_all';
  static const _trayExitKey = 'exit_app';
  static const _trayIconAsset = 'images/tray_icon.ico';

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
        await _initializeDesktopWindow();
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

  Future<void> _initializeDesktopWindow() async {
    if (_desktopInitialized) return;
    _desktopInitialized = true;

    await windowManager.ensureInitialized();

    const options = WindowOptions(
      size: Size(1366, 768),
      minimumSize: Size(900, 600),
      center: true,
      title: 'Brokeflix',
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setPreventClose(true);
      await windowManager.show();
      await windowManager.focus();
    });

    windowManager.addListener(this);
    trayManager.addListener(this);

    await _initTray();

    _downloadSubscription = getIt<DownloadManagerBloc>().stream.listen((state) {
      _updateTrayTooltip(state);
    });
  }

  Future<void> _initTray() async {
    try {
      await trayManager.setIcon(_trayIconAsset);
      await trayManager.setToolTip('Brokeflix');
      await _refreshTrayMenu();
    } catch (e, s) {
      log('Tray init failed: $e', error: e, stackTrace: s);
    }
  }

  Future<void> _refreshTrayMenu() async {
    final menu = Menu(
      items: [
        MenuItem(key: _trayShowKey, label: 'Open Brokeflix'),
        MenuItem.separator(),
        MenuItem(key: _trayPauseKey, label: 'Pause all downloads'),
        MenuItem(key: _trayResumeKey, label: 'Resume paused downloads'),
        MenuItem.separator(),
        MenuItem(key: _trayExitKey, label: 'Exit'),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  @override
  void onWindowClose() async {
    final prevent = await windowManager.isPreventClose();
    if (!prevent) {
      await windowManager.setPreventClose(true);
    }
    await windowManager.hide();
    log('Window hidden to tray; downloads continue');
  }

  @override
  void onTrayIconMouseDown() async {
    await _showWindow();
  }

  @override
  void onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case _trayShowKey:
        await _showWindow();
        break;
      case _trayPauseKey:
        _pauseAllActive();
        break;
      case _trayResumeKey:
        _resumeAllPaused();
        break;
      case _trayExitKey:
        await _exitApp();
        break;
    }
  }

  Future<void> _showWindow() async {
    if (await windowManager.isMinimized()) {
      await windowManager.restore();
    }
    await windowManager.show();
    await windowManager.focus();
  }

  void _pauseAllActive() {
    final downloadBloc = getIt<DownloadManagerBloc>();
    for (final task in downloadBloc.state.downloads.values) {
      if (task.canPause) {
        downloadBloc.add(DownloadManagerPauseDownload(task.taskId));
      }
    }
  }

  void _resumeAllPaused() {
    final downloadBloc = getIt<DownloadManagerBloc>();
    for (final task in downloadBloc.state.downloads.values) {
      if (task.status == DownloadStatus.paused) {
        downloadBloc.add(DownloadManagerResumeDownload(task.taskId));
      }
    }
  }

  Future<void> _exitApp() async {
    log('Tray exit: pausing active downloads before shutdown');
    _pauseAllActive();
    // Give libtorrent a moment to persist state.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await trayManager.destroy();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }

  void _handleNotificationTap(NotificationResponse response) {
    String? actionId = response.actionId;
    String? payload = response.payload;

    if (actionId != null && actionId.contains(':')) {
      final parts = actionId.split(':');
      actionId = parts[0];
      payload = parts.length > 1 ? parts[1] : null;
    } else if (payload != null && payload.contains(':')) {
      final parts = payload.split(':');
      actionId = parts[0];
      payload = parts.length > 1 ? parts[1] : null;
    }

    if (payload == null) return;
    final taskId = int.tryParse(payload);
    if (taskId == null) return;

    final downloadBloc = getIt<DownloadManagerBloc>();
    final task = downloadBloc.state.downloads[taskId];

    if (actionId != null) {
      log('Notification action clicked: $actionId for task: $taskId');
      switch (actionId) {
        case 'pause':
          downloadBloc.add(DownloadManagerPauseDownload(taskId));
          break;
        case 'resume':
          downloadBloc.add(DownloadManagerResumeDownload(taskId));
          break;
        case 'stop':
          downloadBloc.add(DownloadManagerStopDownload(taskId));
          break;
      }
      return;
    }

    if (task == null) return;

    // Navigate based on download status
    final context = rootNavigatorKey.currentContext;
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

  void _updateTrayTooltip(DownloadManagerState state) {
    if (!isDesktop) return;
    try {
      final active = state.activeDownloads;
      if (active.isEmpty) {
        trayManager.setToolTip('Brokeflix');
      } else if (active.length == 1) {
        final t = active.first;
        final speed = t.formattedDownloadSpeed;
        final progress = t.progressPercentage;
        trayManager.setToolTip('Brokeflix\nDownloading: $progress ($speed)');
      } else {
        var totalDl = 0;
        for (final t in active) {
          totalDl += t.downloadSpeed;
        }
        final totalSpeed = DownloadTask.formatBytes(totalDl);
        trayManager.setToolTip(
            'Brokeflix\nDownloading ${active.length} movies ($totalSpeed/s)');
      }
    } catch (e) {
      log('Error updating tray tooltip: $e');
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _downloadSubscription?.cancel();
    if (_desktopInitialized) {
      windowManager.removeListener(this);
      trayManager.removeListener(this);
    }
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
        BlocProvider<ConnectivityService>(
            create: (_) => getIt<ConnectivityService>())
      ],
      child: YTSApp(),
    );
  }
}
