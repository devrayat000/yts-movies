enum Query {
  latest,
  hd,
  mostDownloaded,
  mostLiked,
  rated,
  year,
}

enum Quality { $720, $1080, $2160, $3D }

final qualities = {
  Quality.$720: '720p',
  Quality.$1080: '1080p',
  Quality.$2160: '2160p',
  Quality.$3D: '3D',
};

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

extension SortValue on Sort {
  String get val => this.toString().split('.')[1].toLowerCase();
}

enum Order { ASC, DESC }

extension OrderValue on Order {
  String get val => this.toString().split('.')[1].toLowerCase();
}

enum StaticPage { LATEST, HD, RATED, SEARCH, FAVOURITES }

const Map<StaticPage, String> page = const {
  StaticPage.LATEST: 'latest',
  StaticPage.HD: '4k',
  StaticPage.RATED: 'rated',
  StaticPage.SEARCH: 'search',
  StaticPage.FAVOURITES: 'favourites',
};
