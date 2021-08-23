import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';

import 'package:ytsmovies/src/bloc/api/state.dart';
import 'package:ytsmovies/src/mock/movie_data.dart';
import 'package:ytsmovies/src/utils/exceptions.dart';
import 'package:ytsmovies/src/utils/isolates.dart';
import 'package:ytsmovies/src/utils/repository.dart';

export 'state.dart';

part 'static.dart';
part 'search.dart';
part 'favourites.dart';

typedef Resolver = Future<http.Response> Function([int? page]);

class ApiProvider {
  final LatestApiCubit latestMovies;
  final RatedApiCubit ratedMovies;
  final HDApiCubit hdMovies;
  final FavouriteApiCubit favouriteMovies;

  ApiProvider(MovieRepository _repository)
      : latestMovies = LatestApiCubit(_repository),
        ratedMovies = RatedApiCubit(_repository),
        hdMovies = HDApiCubit(_repository),
        favouriteMovies = FavouriteApiCubit(_repository);
}

abstract class ApiCubit extends Cubit<PageState> {
  final MovieRepository repository;
  ApiCubit(this.repository) : super(PageStateInitial());

  Future<void> getMovies(int page);
}

abstract class ApiBloc extends Bloc<int, PageState> {
  ApiBloc() : super(PageStateInitial());

  Resolver get resolver;

  AsyncCache<MovieData> get cacher;

  @override
  Stream<PageState> mapEventToState(int page) async* {
    print(page);
    try {
      final movieData = await listMoviesSearch(page);

      final movies = movieData.movies;

      if (movies == null) {
        throw CustomException('No movies were found');
      }

      yield PageStateSuccess(
        list: movies,
        nextPage: ++page,
        isLast: movieData.isLastPage,
      );
    } catch (e, s) {
      print(e);
      print(s);
      yield PageStateError(e, s);
    }
  }

  Future<MovieData> listMoviesSearch([int? page]) async {
    try {
      return await cacher.fetch(() async {
        try {
          final response = await this.resolver(page);
          return await compute(
            _parseMovieData,
            response.body,
            debugLabel: 'apiMovieDataParser',
          );
        } catch (e) {
          rethrow;
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  static MovieData _parseMovieData(String body) {
    final json = Spawn.decodeJson(body);
    final data = json['data'] as Map<String, dynamic>;
    return MovieData.fromJson(data);
  }
}
