import 'package:ytsmovies/models/constants.dart';

class MovieDetails extends Movie {
  late final String downloadCount;
  late final String likeCount;

  MovieDetails.fromJSON(dynamic movie) : super.fromJSON(movie) {
    downloadCount = movie['download_count'].toString();
    likeCount = movie['like_count'].toString();
  }
}

class MovieSearchAutocomplete {
  late final String id;
  late final String title;
  late final String avatar;
  late final dynamic raw;

  MovieSearchAutocomplete.fromJSON(dynamic movie)
      : id = movie['id'].toString(),
        title = movie['title'],
        avatar = movie['small_cover_image'],
        raw = movie;
}

class Movie {
  late final String id;
  late final String title;
  late final String year;
  late final String rating;
  late final CoverImage coverImg;
  late final String backgroundImage;
  late final DateTime dateUploaded;
  late final String url;
  late final String imdbCode;
  late final String language;
  late final String mpaRating;
  late final String descriptionFull;
  late final String synopsis;
  late final String trailer;
  late final int runtime;
  late final List<String> genres;
  late final List<Torrent> torrents;

  late final String? _uploaded;
  late final String _trailerCode;

  Movie.fromJSON(dynamic movie) {
    final List _genres = movie['genres'];
    final List _torrents = movie['torrents'];
    _trailerCode = movie['yt_trailer_code'];
    _uploaded = movie['date_uploaded'];

    id = movie['id'].toString();
    title = movie['title'];
    year = movie['year'].toString();
    rating = movie['rating'].toString();
    coverImg = CoverImage(
      small: movie['small_cover_image'],
      medium: movie['medium_cover_image'],
      large: movie['large_cover_image'],
    );
    backgroundImage =
        movie['background_image'] ?? movie['background_image_original'];
    dateUploaded =
        _uploaded == null ? DateTime.now() : DateTime.parse(_uploaded!);
    url = movie['url'];
    imdbCode = movie['imdb_code'];
    language = movie['language'];
    mpaRating = movie['mpa_rating'];
    descriptionFull = movie['description_full'];
    synopsis = movie['synopsis'] ?? movie['description_full'];
    trailer = 'https://www.youtube.com/watch?v=$_trailerCode';
    runtime = movie['runtime'];
    genres = _genres.map((g) => g.toString()).toList();
    torrents = _torrents.map((e) => Torrent(e, title: title)).toList();
  }

  Map<String, Object?> toJSON() {
    return {
      Col.id: id,
      Col.title: title,
      Col.year: year,
      Col.rating: rating,
      Col.dateUploaded: _uploaded,
      Col.url: url,
      Col.imdbCode: imdbCode,
      Col.language: language,
      Col.mpaRating: mpaRating,
      Col.descriptionFull: descriptionFull,
      Col.synopsis: synopsis,
      Col.trailer: _trailerCode,
      Col.runtime: runtime,
      Col.backgroundImage: backgroundImage,
    }..addAll(coverImg.toJSON());
  }

  List<String> get quality {
    return torrents.map((e) => e.quality).toSet().toList();
  }
}

class CoverImage {
  final String small;
  final String medium;
  final String? large;
  const CoverImage({
    required this.small,
    required this.medium,
    this.large,
  });

  Map<String, Object?> toJSON() {
    return {
      Col.smallImage: small,
      Col.mediumImage: medium,
      Col.largeImage: large,
    };
  }
}

class Torrent {
  late final String url;
  late final String hash;
  late final String quality;
  late final String? type;
  late final int seeds;
  late final int peers;
  late final String size;
  late final DateTime dateUploaded;
  late final String _title;

  Torrent(Map<String, dynamic> torrent, {required String title}) {
    url = torrent['url'];
    hash = torrent['hash'];
    type = torrent['type'].toString() == 'bluray' ? 'blu' : torrent['type'];
    quality = torrent['quality'];
    seeds = torrent['seeds'];
    peers = torrent['peers'];
    size = torrent['size'];
    dateUploaded = DateTime.parse(torrent['date_uploaded']);
    _title = title;
  }

  Map<String, Object?> toJSON() {
    return {
      Col.url: url,
      Col.hash: hash,
      Col.type: type,
      Col.quality: quality,
      Col.seeds: seeds,
      Col.peers: peers,
      Col.size: size,
      Col.dateUploaded: dateUploaded.toString(),
    };
  }

  Uri get magnet {
    final magnetUri = Uri(
      scheme: 'magnet',
      queryParameters: {
        'xt': 'urn:btih:$hash',
        'dn': '$_title [$quality] [YTS.MX]',
        'tr': [
          'udp://glotorrents.pw:6969/announce',
          'udp://tracker.opentrackr.org:1337/announce',
          'udp://torrent.gresille.org:80/announce',
          'udp://tracker.openbittorrent.com:80',
          'udp://tracker.coppersurfer.tk:6969',
          'udp://tracker.leechers-paradise.org:6969',
          'udp://p4p.arenabg.ch:1337',
          'udp://tracker.internetwarriors.net:1337',
        ],
      },
    );
    return magnetUri;
  }
}

class MovieArg<T extends Movie> {
  final T movie;
  MovieArg(this.movie);
}
