import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ytsmovies/src/utils/enums.dart';

typedef Resolver = Future<Response> Function(int);

final routeObserver = RouteObserver();

final Map<Query, Map<String, dynamic>> parseQuery = {
  Query.latest: {},
  Query.hd: {'quality': '2160p'},
  Query.mostDownloaded: {'sort_by': 'download_count'},
  Query.mostLiked: {'sort_by': 'like_count'},
  Query.rated: {'sort_by': 'rating', 'minimum_rating': '5'},
};

class MyGlobals {
  static final bucket = PageStorageBucket();

  static const Widget kCircularLoading = Center(
    child: CircularProgressIndicator.adaptive(),
  );
}

class MyBoxs {
  static const favouriteBox = 'favourites';
  static const searchHistoryBox = 'searchHistory';
}

class Col {
  static const smallImage = 'small_cover_image';
  static const mediumImage = 'medium_cover_image';
  static const largeImage = 'large_cover_image';
}
