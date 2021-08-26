part of app_bloc.api;

class LatestApiCubit extends ApiCubit {
  LatestApiCubit(MovieRepository _repository) : super(_repository);

  @override
  Future<void> getMovies(int page) async {
    try {
      final movieData = await repository.latestMovies(page);
      print(movieData.runtimeType);
      this.emit(PageStateInitial());
      this.emit(PageStateSuccess(
        list: movieData.movies!,
        nextPage: ++page,
        isLast: movieData.isLastPage,
      ));
      print('emitted');
    } catch (e, s) {
      this.emit(PageStateError(e, s));
    }
    return SynchronousFuture(null);
  }
}

class RatedApiCubit extends ApiCubit {
  RatedApiCubit(MovieRepository _repository) : super(_repository);

  @override
  Future<void> getMovies(int page) async {
    try {
      final movieData = await repository.ratedMovies(page);
      print(movieData.runtimeType);
      this.emit(PageStateInitial());
      this.emit(PageStateSuccess(
        list: movieData.movies!,
        nextPage: ++page,
        isLast: movieData.isLastPage,
      ));
      print('emitted');
    } catch (e, s) {
      this.emit(PageStateError(e, s));
    }
    return SynchronousFuture(null);
  }
}

class HDApiCubit extends ApiCubit {
  HDApiCubit(MovieRepository _repository) : super(_repository);

  @override
  Future<void> getMovies(int page) async {
    try {
      final movieData = await repository.hd4kMovies(page);
      print(movieData.runtimeType);
      this.emit(PageStateSuccess(
        list: movieData.movies!,
        nextPage: ++page,
        isLast: movieData.isLastPage,
      ));
      print('emitted');
    } catch (e, s) {
      this.emit(PageStateError(e, s));
    }
    return SynchronousFuture(null);
  }
}
