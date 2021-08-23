import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:ytsmovies/src/mock/movie.dart';
import 'package:ytsmovies/src/utils/enums.dart';

class RootRouteState with ChangeNotifier {
  StaticPage? staticPage;
  List<Movie> movies = [];
  RootRouteState() {
    print('state initialized');
  }

  void push(StaticPage page) {
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
