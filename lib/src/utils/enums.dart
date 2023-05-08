enum Query {
  latest,
  hd,
  mostDownloaded,
  mostLiked,
  rated,
  year,
}

Quality deserializeQuality(String json) => QualityValue.fromJson(json);
String? serializeQuality(Quality? object) => object?.toJson();

enum Quality { $720, $1080, $2160, $3D }

final qualities = {
  Quality.$720: '720p',
  Quality.$1080: '1080p',
  Quality.$2160: '2160p',
  Quality.$3D: '3D',
};

Sort deserializeSort(String json) => SortValue.fromJson(json);
String? serializeSort(Sort? object) => object?.toJson();

enum Sort {
  TITLE, //
  YEAR, //
  RATING,
  PEERS, //
  SEEDS, //
  DOWNLOAD_COUNT, //
  LIKE_COUNT, //
  DATE_ADDED, //
}

final sorts = {
  Sort.TITLE: 'Alphabetical',
  Sort.RATING: 'Rating',
  Sort.DATE_ADDED: 'Latest',
  Sort.YEAR: 'Year',
  Sort.PEERS: 'Peers',
  Sort.SEEDS: 'Seeds',
  Sort.DOWNLOAD_COUNT: 'Downloads',
  Sort.LIKE_COUNT: 'Likes',
};

extension QualityValue on Quality {
  String toJson() => qualities[this]!;
  static Quality fromJson(String val) =>
      Quality.values.firstWhere((e) => e.toJson() == val);
}

extension SortValue on Sort {
  String toJson() => sorts[this]!;
  static Sort fromJson(String val) =>
      Sort.values.firstWhere((e) => e.toJson() == val);
}

Order deserializeOrder(String json) => OrderValue.fromJson(json);
String? serializeOrder(Order? object) => object?.toJson();

enum Order { ASC, DESC }

extension OrderValue on Order {
  String toJson() => toString().split('.')[1].toLowerCase();
  static Order fromJson(String val) =>
      Order.values.firstWhere((e) => e.toJson() == val);
}

enum StaticPage { LATEST, HD, RATED, SEARCH, FAVOURITES }

const Map<StaticPage, String> page = {
  StaticPage.LATEST: 'latest',
  StaticPage.HD: '4k',
  StaticPage.RATED: 'rated',
  StaticPage.SEARCH: 'search',
  StaticPage.FAVOURITES: 'favourites',
};
