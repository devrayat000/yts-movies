import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Size;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'package:ytsmovies/src/bloc/download_manager/download_manager_bloc.dart';
import 'package:ytsmovies/src/models/download_task.dart';

/// True on Windows/macOS/Linux when not running on the web.
bool get isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

/// True on Windows specifically (excluded on web).
bool get isWindowsDesktop => !kIsWeb && Platform.isWindows;

const _trayShowKey = 'show_app';
const _trayPauseKey = 'pause_all';
const _trayResumeKey = 'resume_all';
const _trayExitKey = 'exit_app';

/// Wires window_manager + tray_manager so the app:
///  - hides to the system tray on close (downloads keep running)
///  - exposes a tray menu to restore / pause-all / resume-all / exit
///  - pauses active downloads + destroys the window on tray-exit
class DesktopWindowService with WindowListener, TrayListener {
  DesktopWindowService(this._downloadBloc);

  final DownloadManagerBloc _downloadBloc;
  bool _initialized = false;

  static const _trayIconAsset = 'images/tray_icon.ico';

  Future<void> initialize() async {
    if (!isDesktop || _initialized) return;
    _initialized = true;

    await windowManager.ensureInitialized();

    const options = WindowOptions(
      size: Size(1280, 800),
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
  }

  Future<void> _initTray() async {
    try {
      await trayManager.setIcon(_trayIconAsset);
      await trayManager.setToolTip('YTS Movies');
      await _refreshTrayMenu();
    } catch (e, s) {
      log('Tray init failed: $e', error: e, stackTrace: s);
    }
  }

  Future<void> _refreshTrayMenu() async {
    final menu = Menu(
      items: [
        MenuItem(key: _trayShowKey, label: 'Open YTS Movies'),
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
    for (final task in _downloadBloc.state.downloads.values) {
      if (task.canPause) {
        _downloadBloc.add(DownloadManagerPauseDownload(task.taskId));
      }
    }
  }

  void _resumeAllPaused() {
    for (final task in _downloadBloc.state.downloads.values) {
      if (task.status == DownloadStatus.paused) {
        _downloadBloc.add(DownloadManagerResumeDownload(task.taskId));
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

  void dispose() {
    if (!_initialized) return;
    windowManager.removeListener(this);
    trayManager.removeListener(this);
  }
}
