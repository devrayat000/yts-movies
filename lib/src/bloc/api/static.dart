part of app_bloc.api;

class LatestApiCubit extends ApiCubit {
  LatestApiCubit(MovieRepository repository) : super(repository);

  @override
  Future<void> getMovies(int page) async {
    try {
      final movieData = await repository.latestMovies(page);
      debugPrint(movieData.runtimeType.toString());
      emit(PageStateInitial());
      emit(PageStateSuccess(
        list: movieData.movies!,
        nextPage: ++page,
        isLast: movieData.isLastPage,
      ));
      debugPrint('emitted');
    } catch (e, s) {
      emit(PageStateError(e, s));
    }
    return SynchronousFuture(null);
  }
}

class RatedApiCubit extends ApiCubit {
  RatedApiCubit(MovieRepository repository) : super(repository);

  @override
  Future<void> getMovies(int page) async {
    try {
      final movieData = await repository.ratedMovies(page);
      debugPrint(movieData.runtimeType.toString());
      emit(PageStateInitial());
      emit(PageStateSuccess(
        list: movieData.movies!,
        nextPage: ++page,
        isLast: movieData.isLastPage,
      ));
      debugPrint('emitted');
    } catch (e, s) {
      emit(PageStateError(e, s));
    }
    return SynchronousFuture(null);
  }
}

class HDApiCubit extends ApiCubit {
  HDApiCubit(MovieRepository repository) : super(repository);

  @override
  Future<void> getMovies(int page) async {
    try {
      final movieData = await repository.hd4kMovies(page);
      debugPrint(movieData.runtimeType.toString());
      emit(PageStateSuccess(
        list: movieData.movies!,
        nextPage: ++page,
        isLast: movieData.isLastPage,
      ));
      debugPrint('emitted');
    } catch (e, s) {
      emit(PageStateError(e, s));
    }
    return SynchronousFuture(null);
  }
}
