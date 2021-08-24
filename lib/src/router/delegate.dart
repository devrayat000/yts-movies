part of app_router;

class RootRouterDelegate extends RouterDelegate<BasePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BasePath> {
  final RootRouteState appState;
  final MovieRepository repository;
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  RootRouterDelegate({
    required this.appState,
    required this.repository,
  }) : navigatorKey = GlobalKey<NavigatorState>() {
    appState.addListener(notifyListeners);
  }

  @override
  BasePath? get currentConfiguration {
    if (appState.staticPage != null) {
      return OtherPath(appState.staticPage!);
    }
    if (appState.movies.length > 0) {
      return DetailsPath(appState.movies.last.id);
    }
    return HomePath();
  }

  @override
  Widget build(BuildContext context) {
    return RootNavigator(navigatorKey: navigatorKey);
  }

  @override
  Future<void> setNewRoutePath(BasePath config) async {
    if (config is HomePath) {
      appState.staticPage = null;
      appState.movies.clear();
    }
    if (config is OtherPath) {
      appState.staticPage = config.page;
    }
    if (config is DetailsPath) {
      final id = config.id;
      final movie = await repository.movieDetails(id);
      appState.movies.add(movie);
    }
    return SynchronousFuture<void>(null);
  }

  @override
  void dispose() {
    appState.removeListener(notifyListeners);
    appState.dispose();
    super.dispose();
  }
}
