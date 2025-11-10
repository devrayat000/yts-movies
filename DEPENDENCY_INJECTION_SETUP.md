# Dependency Injection Setup with get_it and injectable

## Overview

Successfully implemented dependency injection using `get_it` and `injectable` packages throughout the YTS Movies application.

## What Was Done

### 1. Core Setup Files Created

- **`lib/src/injection.dart`**: Main DI configuration file
  - Exports GetIt instance
  - Configures `injectable` with code generation
  - Provides `configureDependencies()` async function that initializes all dependencies

### 2. Services Converted to Injectable

#### API Services

- **`MoviesClient`** (api/client.dart): Configured as `@module` with async factory method
- **`FavouritesService`** (api/favourites.dart): Registered as `@lazySingleton`

#### Core Services

- **`ConnectivityService`** (services/connectivity_service.dart): Registered as `@lazySingleton`
- **`PreferencesService`** (services/preferences_service.dart): Registered as `@lazySingleton` with `@postConstruct` initialization
- **`ErrorReportingService`** (services/error_reporting_service.dart): Registered as `@lazySingleton`
- **`ErrorNotificationService`** (services/error_notification_service.dart): Registered as `@lazySingleton` with dependency on `ErrorReportingService`
- **`ForegroundDownloadService`** (services/foreground_download_service.dart): Registered as `@lazySingleton` with `@postConstruct` initialization, depends on `PreferencesService`

### 3. BLoCs Converted to Injectable

- **`ThemeCubit`** (bloc/theme_bloc.dart): Registered as `@lazySingleton`, depends on `AppTheme`
- **`DownloadManagerBloc`** (bloc/download_manager/download_manager_bloc.dart): Registered as `@lazySingleton`, depends on `ForegroundDownloadService`

### 4. Theme Configuration

- **`AppTheme`** (theme/index.dart): Registered as `@lazySingleton`

### 5. Helper Extensions Created

- **`service_extensions.dart`**: Extension methods on `BuildContext` for easy access to services
  - `favouritesService`
  - `connectivityService`
  - `errorNotificationService`
  - `errorReportingService`

### 6. App Initialization Updated

- **`app_initializer.dart`**:
  - Calls `configureDependencies()` during initialization
  - Uses `getIt` to retrieve BLoCs for providers
  - Removed old manual initialization code

### 7. Files Updated to Use DI

- Removed singleton patterns (`.instance` calls)
- Updated to use `getIt<ServiceType>()` or context extensions
- Updated files:
  - `api/error_interceptor.dart`
  - `widgets/buttons/favourite_button.dart`
  - `widgets/buttons/download_button.dart`
  - `widgets/connectivity_widgets.dart`
  - `widgets/enhanced_future_builder.dart`
  - `widgets/splash/splash_wrapper.dart`
  - `pages/favourites.dart`

## Dependency Graph

```
┌─ AppTheme @lazySingleton
│
├─ ThemeCubit @lazySingleton
│  └─ depends on: AppTheme
│
├─ MoviesClient @lazySingleton (async)
│
├─ FavouritesService @lazySingleton
│
├─ ConnectivityService @lazySingleton
│
├─ ErrorReportingService @lazySingleton
│
├─ ErrorNotificationService @lazySingleton
│  └─ depends on: ErrorReportingService
│
├─ PreferencesService @lazySingleton (async)
│  └─ @postConstruct initialization
│
├─ ForegroundDownloadService @lazySingleton (async)
│  ├─ depends on: PreferencesService
│  └─ @postConstruct initialization
│
└─ DownloadManagerBloc @lazySingleton (async)
   └─ depends on: ForegroundDownloadService
```

## How to Use

### Accessing Services

#### Option 1: Direct getIt Access

```dart
import 'package:ytsmovies/src/injection.dart';

final favourites = getIt<FavouritesService>();
final connectivity = getIt<ConnectivityService>();
```

#### Option 2: Context Extensions (in Widgets)

```dart
import 'package:ytsmovies/src/service_extensions.dart';

// In a StatelessWidget or StatefulWidget
context.favouritesService.toggleAddOrRemoveFavourite(movie);
context.errorNotificationService.showError(context, error);
```

#### Option 3: BLoCs via BlocProvider

```dart
// Already set up in app_initializer.dart
BlocProvider<ThemeCubit>(
  create: (_) => getIt<ThemeCubit>(),
),
BlocProvider<DownloadManagerBloc>(
  create: (_) => getIt<DownloadManagerBloc>()..add(DownloadManagerStarted()),
),
```

### Adding New Injectable Services

1. **Add annotation to your class:**

```dart
@lazySingleton  // or @singleton, @injectable
class MyService {
  MyService();
}
```

2. **For services with dependencies:**

```dart
@lazySingleton
class MyService {
  final SomeDependency _dependency;
  
  MyService(this._dependency);
}
```

3. **For async initialization:**

```dart
@lazySingleton
class MyService {
  MyService();
  
  @postConstruct
  Future<void> initialize() async {
    // Async initialization code
  }
}
```

4. **Run code generation:**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Benefits

1. **Testability**: Easy to mock dependencies in tests
2. **Maintainability**: Clear dependency relationships
3. **Flexibility**: Easy to swap implementations
4. **Type Safety**: Compile-time dependency resolution
5. **Lazy Loading**: Services are created only when first accessed
6. **Async Support**: Proper handling of async initialization

## Files Modified

### Created

- `lib/src/injection.dart`
- `lib/src/injection.config.dart` (generated)
- `lib/src/service_extensions.dart`

### Updated

- `lib/src/api/client.dart`
- `lib/src/api/movies.dart`
- `lib/src/api/favourites.dart`
- `lib/src/api/error_interceptor.dart`
- `lib/src/services/connectivity_service.dart`
- `lib/src/services/preferences_service.dart`
- `lib/src/services/error_reporting_service.dart`
- `lib/src/services/error_notification_service.dart`
- `lib/src/services/foreground_download_service.dart`
- `lib/src/bloc/theme_bloc.dart`
- `lib/src/bloc/download_manager/download_manager_bloc.dart`
- `lib/src/theme/index.dart`
- `lib/src/app_initializer.dart`
- `lib/src/widgets/buttons/index.dart`
- `lib/src/widgets/buttons/favourite_button.dart`
- `lib/src/widgets/buttons/download_button.dart`
- `lib/src/widgets/connectivity_widgets.dart`
- `lib/src/widgets/enhanced_future_builder.dart`
- `lib/src/widgets/splash/splash_wrapper.dart`
- `lib/src/widgets/index.dart`
- `lib/src/pages/favourites.dart`

## Next Steps

1. Update remaining parts of the codebase that still use old patterns
2. Add unit tests leveraging the new DI system
3. Consider adding environment-specific configurations if needed
4. Document service interfaces for better team understanding
