import 'package:flutter/widgets.dart';
import 'package:ytsmovies/src/pages/favourites.dart';
import 'package:ytsmovies/src/pages/latest.dart';
import 'package:ytsmovies/src/utils/enums.dart';

class OtherPage extends Page {
  final StaticPage page;
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
          case StaticPage.LATEST:
            return const LatestMoviesPage();
          case StaticPage.HD:
            return const HD4KMoviesPage();
          case StaticPage.RATED:
            return const RatedMoviesPage();
          case StaticPage.FAVOURITES:
            return const FavouratesPage();
          default:
            throw UnimplementedError();
        }
      },
    );
  }
}
