// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'api/client.dart' as _i131;
import 'api/favourites.dart' as _i126;
import 'api/movies.dart' as _i1000;
import 'bloc/download_manager/download_manager_bloc.dart' as _i611;
import 'bloc/theme_bloc.dart' as _i406;
import 'services/connectivity_service.dart' as _i807;
import 'services/error_notification_service.dart' as _i382;
import 'services/error_reporting_service.dart' as _i1043;
import 'services/foreground_download_service.dart' as _i663;
import 'services/notification_service.dart' as _i98;
import 'services/preferences_service.dart' as _i701;
import 'theme/index.dart' as _i1055;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final apiModule = _$ApiModule();
    gh.singletonAsync<_i98.NotificationService>(
      () {
        final i = _i98.NotificationService();
        return i.initialize().then((_) => i);
      },
      dispose: (i) => i.dispose(),
    );
    gh.singletonAsync<_i701.PreferencesService>(
      () {
        final i = _i701.PreferencesService();
        return i.initialize().then((_) => i);
      },
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i126.FavouritesService>(() => _i126.FavouritesService());
    gh.lazySingletonAsync<_i807.ConnectivityService>(
      () {
        final i = _i807.ConnectivityService();
        return i.initialize().then((_) => i);
      },
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i1043.ErrorReportingService>(
      () => _i1043.ErrorReportingService(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i1055.AppTheme>(() => _i1055.AppTheme());
    gh.singletonAsync<_i1000.MoviesClient>(() async => apiModule.initClient(
        conn: await getAsync<_i807.ConnectivityService>()));
    gh.lazySingleton<_i382.ErrorNotificationService>(() =>
        _i382.ErrorNotificationService(gh<_i1043.ErrorReportingService>()));
    gh.singletonAsync<_i663.ForegroundDownloadService>(
      () async {
        final i = _i663.ForegroundDownloadService(
            await getAsync<_i701.PreferencesService>());
        return i.initialize().then((_) => i);
      },
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i406.ThemeCubit>(
        () => _i406.ThemeCubit(gh<_i1055.AppTheme>()));
    gh.singletonAsync<_i611.DownloadManagerBloc>(
      () async => _i611.DownloadManagerBloc(
          await getAsync<_i663.ForegroundDownloadService>()),
      dispose: (i) => i.close(),
    );
    return this;
  }
}

class _$ApiModule extends _i131.ApiModule {}
