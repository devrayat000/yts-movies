import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/index.dart';

class FavouritesService {
  FavouritesService._();
  static final instance = FavouritesService._();

  Future<MovieListResponse> getFavoutiteMovies(int page) {
    if (!Hive.isBoxOpen(MyBoxs.favouriteBox)) {
      throw const CustomException("Favourites box is not open");
    }
    final box = Hive.box<Movie>(MyBoxs.favouriteBox);
    return SynchronousFuture(
      MovieListResponse(
        status: "",
        statusMessage: "",
        data: MovieListData(
          movieCount: box.length,
          limit: box.length,
          pageNumber: 1,
          movies: box.values.toList(),
        ),
      ),
    );
  }

  Future<bool> toggleAddOrRemoveFavourite(Movie movie) async {
    if (!Hive.isBoxOpen(MyBoxs.favouriteBox)) {
      throw const CustomException("Favourites box is not open");
    }
    final favBox = Hive.box<Movie>(MyBoxs.favouriteBox);
    final isLiked = favBox.containsKey(movie.id);
    if (isLiked) {
      await favBox.delete(movie.id);
    } else {
      await favBox.put(movie.id, movie);
    }
    return !isLiked;
  }

  Future<bool> isFavourite(int id) {
    if (!Hive.isBoxOpen(MyBoxs.favouriteBox)) {
      throw const CustomException("Favourites box is not open");
    }
    final favBox = Hive.box<Movie>(MyBoxs.favouriteBox);
    return SynchronousFuture(favBox.containsKey(id));
  }
}
