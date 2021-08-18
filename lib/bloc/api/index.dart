import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:ytsmovies/mock/movie.dart';
import 'package:ytsmovies/mock/movie_data.dart';
import 'package:ytsmovies/utils/api.dart';
import 'package:ytsmovies/utils/exceptions.dart';
import 'package:ytsmovies/utils/isolates.dart';

typedef Resolver = Future<http.Response> Function([int? page]);

class ApiBloc extends Bloc<int, PageState> {
  final Resolver _resolver;
  ApiBloc({required Resolver resolver})
      : _resolver = resolver,
        super(PageState.empty());

  @override
  Stream<PageState> mapEventToState(int page) async* {
    print(page);
    try {
      final data = await listMoviesSearch(page);

      final movieData = await compute(
        _parseMovieData,
        data,
        debugLabel: 'apiMovieDataParser',
      );

      final movies = movieData.movies;

      if (movies == null) {
        throw NotFoundException('No movies were found');
      }

      yield PageState(
        list: movies,
        nextPage: ++page,
        isLast: movieData.isLastPage,
      );
    } catch (e, s) {
      this.addError(e, s);
      print(e);
      yield* Stream.error(e, s);
    }
  }

  Future<Map<String, dynamic>> listMoviesSearch([int? page]) async {
    try {
      final response = await this._resolver(page);
      final respData = await compute(Spawn.decodeJson, response.body);
      return respData['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  static MovieData _parseMovieData(Map<String, dynamic> json) =>
      MovieData.fromJson(json);
}

class PageState with EquatableMixin {
  final List<Movie> list;
  final int nextPage;
  final bool isLast;
  const PageState(
      {required this.list, required this.nextPage, this.isLast = false});

  const PageState.empty()
      : list = const [],
        nextPage = 0,
        isLast = false;

  @override
  List<Object?> get props => [list, nextPage, isLast];
}
