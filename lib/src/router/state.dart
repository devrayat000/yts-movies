part of app_router;

class RootRouteState with ChangeNotifier {
  enums.StaticPage? staticPage;
  List<Movie> movies = [];
  RootRouteState() {
    print('state initialized');
  }

  void push(enums.StaticPage page) {
    staticPage = page;
    notifyListeners();
  }

  void pop() {
    staticPage = null;
    notifyListeners();
  }

  void pushDetails(Movie movie) {
    movies.add(movie);
    notifyListeners();
  }

  void popDetails() {
    movies.removeLast();
    notifyListeners();
  }
}

class RootRouteScope extends InheritedNotifier<RootRouteState> {
  RootRouteScope({
    Key? key,
    required RootRouteState notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);

  static RootRouteState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<RootRouteScope>()!
        .notifier!;
  }
}
