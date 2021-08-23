import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:ytsmovies/src/router/path.dart';
import '../utils/enums.dart' as enums;

class RootRouteInfoParser extends RouteInformationParser<BasePath> {
  @override
  Future<BasePath> parseRouteInformation(RouteInformation routeInformation) {
    final path = routeInformation.location!;
    final url = Uri.parse(path);
    final pathSegments = url.pathSegments;

    BasePath result;
    if (pathSegments.length == 0) {
      result = HomePath();
    } else if (pathSegments.length == 1) {
      final page = pathSegments.first;
      final index = enums.page.values.toList().indexOf(page);

      result = OtherPath(enums.page.keys.elementAt(index));
    } else if (pathSegments.length == 2) {
      final id = int.tryParse(pathSegments.last);
      if (id == null) {
        throw UnimplementedError();
      } else {
        result = DetailsPath(id);
      }
    } else {
      throw UnimplementedError();
    }
    return SynchronousFuture(result);
  }

  @override
  RouteInformation? restoreRouteInformation(BasePath config) {
    return RouteInformation(location: config.path);
  }
}
