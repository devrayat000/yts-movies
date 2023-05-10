part of app_router;

class RootRouteState with ChangeNotifier {
  enums.StaticPage? staticPage;
  List<Movie> movies = [];
  BasePath path = HomePath();

  RootRouteState() {
    debugPrint('state initialized');
  }

  void push(enums.StaticPage page) {
    staticPage = page;
    path = OtherPath(page);
    notifyListeners();
  }

  void pushDetails(Movie movie) {
    movies.add(movie);
    path = DetailsPath(movie.id);
    notifyListeners();
  }

  bool pagePopHandler<T>(Route<T> route, T result) {
    if (!route.didPop(result)) return false;

    final page = route.settings as Page;

    if (movies.length > 0) {
      final lastMovie = movies.last;
      if (page.key == ValueKey(lastMovie.id)) {
        movies.removeLast();
        path = movies.length > 0
            ? DetailsPath(movies.last.id)
            : staticPage != null
                ? OtherPath(staticPage!)
                : HomePath();
      }
    }

    if (staticPage != null && page.key == ValueKey(staticPage)) {
      staticPage = null;
      path = HomePath();
    }
    notifyListeners();
    return true;
  }
}

class RootRouteScope extends InheritedNotifier<RootRouteState> {
  RootRouteScope({
    Key? key,
    required RootRouteState notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);

  static RootRouteState of(BuildContext context) {
    final state =
        context.dependOnInheritedWidgetOfExactType<RootRouteScope>()?.notifier;
    if (state == null) {
      throw ProviderNotFoundException(
          state.runtimeType, context.widget.runtimeType);
    }
    return state;
  }
}
