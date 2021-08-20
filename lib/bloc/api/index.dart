import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';

import 'package:ytsmovies/bloc/api/state.dart';
import 'package:ytsmovies/mock/movie.dart';
import 'package:ytsmovies/mock/movie_data.dart';
import 'package:ytsmovies/utils/api.dart';
import 'package:ytsmovies/utils/constants.dart';
import 'package:ytsmovies/utils/exceptions.dart';
import 'package:ytsmovies/utils/isolates.dart';

export 'state.dart';

part 'static.dart';
part 'search.dart';
part 'favourites.dart';

typedef Resolver = Future<http.Response> Function([int? page]);

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
