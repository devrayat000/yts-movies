To get your Flutter Windows app to behave like qBittorrent, you need to handle two main pieces of functionality:

1. **System Tray Integration:** intercepting the close (`X`) button to hide the window instead of destroying it, and adding a system tray icon with a "Quit" menu.
2. **Lifecycle Management:** ensuring your background tasks (like downloading) keep running while the window is hidden, and pause/clean up only when the app is truly terminated from the tray.

Here is a complete guide and architecture to achieve this.

---

## 🛠️ The Essential Plugins

You will need two highly reliable community plugins to handle the window management and system tray integration:

* **`tray_manager`**: Handles the Windows system tray icon and its context menus.
* **`window_manager`**: Intercepts native Windows window events (like clicking the `X` button).

Add them to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  window_manager: ^0.3.9
  tray_manager: ^0.2.2

```

---

## 💻 Implementation Guide

### 1. Update Windows Native Code (`windows/runner/main.cpp`)

By default, Flutter Windows apps close immediately when `X` is pressed. We need to tell the native wrapper to let Flutter handle the close signal.

Open `windows/runner/main.cpp` and add this line inside the `wWinMain` function, right after `window.Create(...)` or before the message loop:

```cpp
// Force the window to pass close events to Flutter instead of killing the process
window.SetQuitOnClose(false); 

```

### 2. The Flutter Implementation

Set up the window listener and tray manager inside your `main.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Window Manager
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    title: "My Downloader App",
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener, TrayListener {
  bool _isDownloading = true; // Your download state

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
    _initSystemTray();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  // --- System Tray Setup ---
  void _initSystemTray() async {
    // Set the tray icon (Ensure this icon is added to your assets)
    await trayManager.setIcon('assets/app_icon.ico'); 
    
    Menu menu = Menu(
      items: [
        MenuItem(key: 'show_app', label: 'Open Downloader'),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: 'Exit'),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  // --- Window Manager Interception ---
  @override
  void onWindowClose() async {
    // Instead of closing, we simply hide the window.
    // The Flutter engine keeps running in the background!
    bool isPreventClose = await windowManager.isPreventClose();
    if (!isPreventClose) {
      await windowManager.setPreventClose(true);
    }
    await windowManager.hide(); 
    debugPrint("App hidden to tray. Downloads are still running...");
  }

  // --- Tray Event Listeners ---
  @override
  void onTrayIconMouseDown(TrayIconMouseDownDetails details) async {
    // Left-clicking the tray icon restores the window (like qBittorrent)
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_app') {
      await windowManager.show();
      await windowManager.focus();
    } 
    else if (menuItem.key == 'exit_app') {
      _handleAppExit();
    }
  }

  // --- Lifecycle & Task Cleanup ---
  void _handleAppExit() {
    debugPrint("Pausing downloads and cleaning up before exit...");
    
    // 1. Pause/Save your download state here
    setState(() {
      _isDownloading = false;
    });

    // 2. Destroy the tray icon
    trayManager.destroy();

    // 3. Actually close the application
    windowManager.destroy(); 
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Downloader App')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isDownloading ? "Downloading file... 📥" : "Downloads Paused ⏸️",
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              const Text("Click 'X' to test hiding to the System Tray."),
            ],
          ),
        ),
      ),
    );
  }
}

```

---

## 🧠 How This Solves Your Request

### Why the download keeps running on 'X'

In Flutter Desktop, the Dart VM runs entirely inside the main application window process. If you use `windowManager.hide()`, the native window visibility is set to false, but the underlying process, Dart event loop, and your download streams **remain 100% active**. It doesn't put the app into a mobile-style suspended state.

### Why the download pauses on Tray Close

When you click "Exit" from the tray context menu, it calls `_handleAppExit()`. This gives you a dedicated hook to pause your HTTP download streams, write the current chunks/metadata to a database/file, and cleanly call `windowManager.destroy()`.
