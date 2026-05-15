// import 'enums.dart';
// import 'lists.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

int urlToUniqueInt(String url) {
  var bytes = utf8.encode(url); // Convert URL string to bytes
  var digest = sha256.convert(bytes); // Hash the bytes using SHA-256
  // Take a portion of the hash and convert it to an integer
  // This approach ensures a fixed-size integer representation.
  return int.parse(digest.toString().substring(0, 8), radix: 16);
}

// class Urls {
//   String get baseUrl => 'yts.mx';

//   Uri listMovies({
//     int? limit,
//     int? page,
//     Quality? quality,
//     int? minimumRating,
//     String? queryTerm,
//     String? genre,
//     Sort? sortBy,
//     Order? orderBy,
//     bool? withRtRatings,
//   }) {
//     if (limit != null) {
//       assert(limit >= 1 && limit <= 50);
//     }
//     if (minimumRating != null) {
//       assert(minimumRating >= 1 && minimumRating <= 9);
//     }
//     if (genre != null) {
//       assert(genres.map((e) => e.value).contains(genre));
//     }

//     return Uri.https(
//         baseUrl,
//         '/api/v2/list_movies.json',
//         trimParams({
//           'limit': '$limit',
//           'page': '$page',
//           'quality': qualities[quality],
//           'minimum_rating': '$minimumRating',
//           'query_term': queryTerm,
//           'genre': genre,
//           'sort_by': sortBy?.toJson(),
//           'order_by': orderBy?.toJson(),
//           'with_rt_ratings': '$withRtRatings',
//         }));
//   }

//   Uri listMoviesWithRawParams([Map<String, String?>? params]) {
//     return Uri.https(baseUrl, '/api/v2/list_movies.json', trimParams(params));
//   }

//   Uri movieDetails(String id, {bool? image, bool? cast}) {
//     return Uri.https(
//         baseUrl,
//         '/api/v2/movie_details.json',
//         trimParams({
//           'movie_id': id,
//           'with_image': '$image',
//           'with_cast': '$cast',
//         }));
//   }

//   Uri movieSuggestions(String id) {
//     return Uri.https(baseUrl, '/api/v2/movie_suggestions.json', {
//       'movie_id': id,
//     });
//   }

//   Map<String, dynamic>? trimParams([Map<String, String?>? params]) {
//     params?.removeWhere(
//         (key, value) => value == null || value == '0' || value == 'null');
//     return params;
//   }
// }
