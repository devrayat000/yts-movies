part of app_router;

class OtherPage extends Page {
  final enums.StaticPage page;
  const OtherPage({
    LocalKey? key,
    String? name,
    String? restorationId,
    required this.page,
  }) : super(
          key: key,
          name: name,
          restorationId: restorationId,
        );

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      maintainState: true,
      settings: this,
      pageBuilder: (context, _, __) {
        switch (this.page) {
          case enums.StaticPage.LATEST:
            return const LatestMoviesPage();
          case enums.StaticPage.HD:
            return const HD4KMoviesPage();
          case enums.StaticPage.RATED:
            return const RatedMoviesPage();
          case enums.StaticPage.FAVOURITES:
            return const FavouritesPage();
          default:
            throw UnimplementedError();
        }
      },
    );
  }
}
