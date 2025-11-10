import 'package:flutter/widgets.dart';
import 'package:ytsmovies/src/api/favourites.dart';
import 'package:ytsmovies/src/services/connectivity_service.dart';
import 'package:ytsmovies/src/services/error_notification_service.dart';
import 'package:ytsmovies/src/services/error_reporting_service.dart';
import 'package:ytsmovies/src/injection.dart';

/// Extension to easily access dependency injected services from BuildContext
extension ServiceProviderExtension on BuildContext {
  /// Get FavouritesService
  FavouritesService get favouritesService => getIt<FavouritesService>();

  /// Get ConnectivityService
  ConnectivityService get connectivityService => getIt<ConnectivityService>();

  /// Get ErrorNotificationService
  ErrorNotificationService get errorNotificationService =>
      getIt<ErrorNotificationService>();

  /// Get ErrorReportingService
  ErrorReportingService get errorReportingService =>
      getIt<ErrorReportingService>();
}
