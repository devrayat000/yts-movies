enum Quality { $720, $1080, $2160, $3D }

extension QualityValue on Quality {
  String get val {
    switch (this) {
      case Quality.$720:
        return '720p';
      case Quality.$1080:
        return '1080p';
      case Quality.$2160:
        return '2160p';
      case Quality.$3D:
        return '3D';
      default:
        return '720p';
    }
  }
}

enum Sort {
  TITLE,
  YEAR,
  RATING,
  PEERS,
  SEEDS,
  DOWNLOAD_COUNT,
  LIKE_COUNT,
  DATE_ADDED,
}

extension SortValue on Sort {
  String get val => this.toString().split('.')[1].toLowerCase();

  String get label {
    switch (this) {
      case Sort.DATE_ADDED:
        return 'Latest';
      case Sort.TITLE:
        return 'Alphabetical';
      case Sort.YEAR:
        return 'Year';
      case Sort.RATING:
        return 'Rating';
      case Sort.PEERS:
        return 'Peers';
      case Sort.SEEDS:
        return 'Seeds';
      case Sort.DOWNLOAD_COUNT:
        return 'Downloads';
      case Sort.LIKE_COUNT:
        return 'Likes';
      default:
        return 'Latest';
    }
  }
}

enum Order { ASC, DESC }

extension OrderValue on Order {
  String get val => this.toString().split('.')[1].toLowerCase();
}

enum View {
  GRID,
  LIST,
}

extension IsGrid on View {
  bool get isGrid => this == View.GRID;
}
