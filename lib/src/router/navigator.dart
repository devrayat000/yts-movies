part of app_router;

class RootNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  RootNavigator({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeState = RootRouteScope.of(context);

    return Navigator(
      key: navigatorKey,
      observers: [routeObserver],
      pages: [
        const MaterialPage(
          key: ValueKey('home'),
          maintainState: true,
          child: HomePage(),
        ),
        if (routeState.staticPage != null)
          OtherPage(
            key: ValueKey(routeState.staticPage),
            page: routeState.staticPage!,
          ),
        if (routeState.movies.length > 0) ...[
          for (final movie in routeState.movies)
            MaterialPage(
              key: ValueKey(movie.id),
              child: MoviePage.withMovie(item: movie),
            ),
        ],
      ],
      onPopPage: routeState.pagePopHandler,
    );
  }
}
