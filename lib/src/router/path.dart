import 'package:ytsmovies/src/utils/enums.dart';
import '../utils/enums.dart' as enums;

abstract class BasePath {
  const BasePath();
  String get path;
}

class HomePath extends BasePath {
  @override
  final path = '/';
}

class OtherPath extends BasePath {
  final StaticPage page;
  const OtherPath(this.page);

  @override
  String get path {
    final _page = enums.page[page];
    if (_page == null) {
      throw UnimplementedError();
    }
    return '/$_page';
  }
}

class DetailsPath extends BasePath {
  final int id;
  const DetailsPath(this.id);

  @override
  String get path => '/movie/$id';
}
