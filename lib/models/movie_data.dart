// import 'package:ytsmovies/models/movie.dart';

// class MovieData {
//   final int movieCount;
//   final int limit;
//   final int pageNumber;
//   final List<Movie>? movies;

//   MovieData({
//     required this.limit,
//     required this.movieCount,
//     required this.movies,
//     required this.pageNumber,
//   });

//   MovieData.fromJSON(dynamic data)
//       : limit = data['limit'],
//         pageNumber = data['page_number'],
//         movieCount = data['movie_count'],
//         movies = (data['movies'] as List? ?? [])
//             .map((e) => Movie.fromJSON(e))
//             .toList(growable: false);

//   int get lastPage => (movieCount / limit).ceil();

//   bool get isLastPage => pageNumber >= lastPage;
// }
