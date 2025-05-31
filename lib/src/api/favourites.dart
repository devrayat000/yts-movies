import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/index.dart';

class FavouritesService {
  FavouritesService._();
  static final instance = FavouritesService._();

  Box<Movie> get _favouriteBox {
    if (!Hive.isBoxOpen(MyBoxs.favouriteBox)) {
      throw const CustomException("Favourites box is not open");
    }
    return Hive.box<Movie>(MyBoxs.favouriteBox);
  }

  Future<MovieListResponse> getFavouriteMovies(int page) {
    final box = _favouriteBox;
    final count = box.length;

    return SynchronousFuture(
      MovieListResponse(
        status: "ok",
        statusMessage: "Query was successful",
        data: MovieListData(
          movieCount: count,
          limit: count == 0 ? 1 : count,
          pageNumber: 1,
          movies: box.values.toList(),
        ),
      ),
    );
  }

  Future<bool> toggleAddOrRemoveFavourite(Movie movie) async {
    final favBox = _favouriteBox;
    final isLiked = favBox.containsKey(movie.id);

    if (isLiked) {
      await favBox.delete(movie.id);
    } else {
      await favBox.put(movie.id, movie);
    }

    return !isLiked;
  }

  Future<bool> isFavourite(int id) {
    return SynchronousFuture(_favouriteBox.containsKey(id));
  }
}
