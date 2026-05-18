# YTS Movies

Flutter client for browsing the YTS catalog and downloading movie torrents directly on Android / iOS.

## Features

- Browse, search and filter the YTS movie catalog
- Movie detail pages with trailers, suggestions and cast
- Built-in torrent downloader (background foreground service)
  - Sequential queue with configurable concurrency
  - Per-file selection, tracker management, speed limits
- Favourites + offline cache
- Light / dark themes

## Tech

- Flutter 3 / Dart 3
- `flutter_bloc` + `hydrated_bloc` state management
- `go_router` navigation
- `dio` + `retrofit` for the YTS REST API
- `hive_ce` local storage
- `dtorrent_task_v2` torrent engine
- `flutter_background_service` + `flutter_local_notifications` for downloads

## Build

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release           # Android APK
flutter build appbundle --release     # Play / Galaxy / Huawei AAB
flutter build ipa --release           # iOS
```

## Signing

Android release builds require `android/key.properties` and a keystore. Generate via:

```powershell
./setup-signing.ps1
```

`key.properties` and `*.jks` are gitignored — never commit them.

## License

See [LICENSE](LICENSE).
