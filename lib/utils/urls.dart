import 'enums.dart';
import 'lists.dart';

class Urls {
  static const baseUrl = 'yts.mx';

  static Uri listMovies({
    int? limit,
    int? page,
    Quality? quality,
    int? minimumRating,
    String? queryTerm,
    String? genre,
    Sort? sortBy,
    Order? orderBy,
    bool? withRtRatings,
  }) {
    if (limit != null) {
      assert(limit >= 1 && limit <= 50);
    }
    if (minimumRating != null) {
      assert(minimumRating >= 1 && minimumRating <= 9);
    }
    if (genre != null) {
      assert(genres.map((e) => e.value).contains(genre));
    }

    return Uri.https(
        baseUrl,
        '/api/v2/list_movies.json',
        trimParams({
          'limit': '$limit',
          'page': '$page',
          'quality': quality?.val,
          'minimum_rating': '$minimumRating',
          'query_term': queryTerm,
          'genre': genre,
          'sort_by': sortBy?.val,
          'order_by': orderBy?.val,
          'with_rt_ratings': '$withRtRatings',
        }));
  }

  static Uri listMoviesWithRawParams([Map<String, dynamic>? params]) {
    return Uri.https(baseUrl, '/api/v2/list_movies.json', trimParams(params));
  }

  static Uri movieDetails(String id, {bool? image, bool? cast}) {
    assert(id != null);

    return Uri.https(
        baseUrl,
        '/api/v2/movie_details.json',
        trimParams({
          'movie_id': id,
          'with_image': '$image',
          'with_cast': '$cast',
        }));
  }

  static Uri movieSuggestions(String id) {
    return Uri.https(baseUrl, '/api/v2/movie_suggestions.json', {
      'movie_id': id,
    });
  }

  static Map<String, dynamic>? trimParams([Map<String, dynamic>? params]) {
    params?.removeWhere(
        (key, value) => value == null || value == '0' || value == 'null');
    return params;
  }
}
