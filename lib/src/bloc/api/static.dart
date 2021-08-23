part of 'index.dart';

class LatestApiCubit extends ApiCubit {
  LatestApiCubit(MovieRepository _repository) : super(_repository);

  @override
  Future<void> getMovies(int page) async {
    try {
      final movieData = await repository.latestMovies(page);
      emit(PageStateSuccess(
        list: movieData.movies!,
        nextPage: ++page,
        isLast: movieData.isLastPage,
      ));
    } catch (e, s) {
      emit(PageStateError(e, s));
    }
  }
}

class RatedApiCubit extends ApiCubit {
  RatedApiCubit(MovieRepository _repository) : super(_repository);

  @override
  Future<void> getMovies(int page) async {
    try {
      final movieData = await repository.ratedMovies(page);
      emit(PageStateSuccess(
        list: movieData.movies!,
        nextPage: ++page,
        isLast: movieData.isLastPage,
      ));
    } catch (e, s) {
      emit(PageStateError(e, s));
    }
  }
}

class HDApiCubit extends ApiCubit {
  HDApiCubit(MovieRepository _repository) : super(_repository);

  @override
  Future<void> getMovies(int page) async {
    try {
      final movieData = await repository.hd4kMovies(page);
      emit(PageStateSuccess(
        list: movieData.movies!,
        nextPage: ++page,
        isLast: movieData.isLastPage,
      ));
    } catch (e, s) {
      emit(PageStateError(e, s));
    }
  }
}
