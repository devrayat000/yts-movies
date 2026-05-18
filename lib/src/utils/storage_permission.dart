import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Public Downloads directory on Android primary user.
/// Path is stable across Android versions and what every download manager
/// (Chrome, 1DM, ADM) writes to.
const String kAndroidPublicDownloadsRoot = '/storage/emulated/0/Download';

/// Subfolder under public Downloads where movie torrents land by default.
const String kDefaultDownloadSubdir = 'Movies';

/// Ensures the app can write to public storage paths (anything outside the
/// app-specific sandbox). No-op on iOS — the iOS app uses its sandbox.
///
/// On Android 11+ (API 30+) this requires MANAGE_EXTERNAL_STORAGE
/// ("All files access" toggle in system Settings). On API 24-29 the
/// legacy WRITE_EXTERNAL_STORAGE runtime permission is enough.
Future<bool> ensurePublicStorageWrite() async {
  if (!Platform.isAndroid) return true;

  final manage = await Permission.manageExternalStorage.status;
  if (manage.isGranted) return true;
  final requested = await Permission.manageExternalStorage.request();
  if (requested.isGranted) return true;

  // API 24-29: manageExternalStorage doesn't exist, the request resolves
  // to granted automatically. Fall back to legacy storage perm for those
  // devices.
  final legacy = await Permission.storage.request();
  return legacy.isGranted;
}

/// Shows the "perm denied" dialog with a deep-link to system settings.
Future<void> showStoragePermissionDeniedDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('All Files Access required'),
      content: const Text(
        'To save downloads to public folders such as Download/Movies, grant '
        '"All files access" in system settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            openAppSettings();
          },
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
}
