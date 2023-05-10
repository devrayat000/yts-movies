part of app_bloc.api;

class FavouriteApiCubit extends ApiCubit {
  FavouriteApiCubit(MovieRepository repository) : super(repository);

  @override
  Future<void> getMovies(int page) async {
    try {
      final movieData = await repository.favouriteMovies();
      emit(PageStateSuccess(
        list: movieData.movies!,
        nextPage: 0,
        isLast: true,
      ));
    } catch (e, s) {
      emit(PageStateError(e, s));
    }
  }
}
