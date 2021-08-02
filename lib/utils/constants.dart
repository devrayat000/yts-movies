import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class Storage {
  final bucket = PageStorageBucket();
}

extension Bucket on BuildContext {
  PageStorageBucket get bucket => this.read<Storage>().bucket;
}

late Widget kCircularLoading;

class Col {
  static const id = 'id';
  static const title = 'title';
  static const year = 'year';
  static const rating = 'rating';
  static const dateUploaded = 'date_uploaded';
  static const url = 'url';
  static const imdbCode = 'imdb_code';
  static const language = 'language';
  static const mpaRating = 'mpa_rating';
  static const descriptionFull = 'description_full';
  static const synopsis = 'synopsis';
  static const trailer = 'yt_trailer_code';
  static const runtime = 'runtime';
  static const smallImage = 'small_cover_image';
  static const mediumImage = 'medium_cover_image';
  static const largeImage = 'large_cover_image';
  static const hash = 'hash';
  static const quality = 'quality';
  static const type = 'type';
  static const seeds = 'seeds';
  static const peers = 'peers';
  static const size = 'size';
  static const magnet = 'magnet';
  static const backgroundImage = 'background_image';
}
