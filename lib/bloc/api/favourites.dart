part of 'index.dart';

class FavouriteApiBloc extends ApiBloc {
  final _box = Hive.box<Movie>(MyBoxs.favouriteBox);

  @override
  Stream<PageState> mapEventToState(int page) async* {
    try {
      print(page);

      yield PageStateSuccess(
        list: _box.values.toList(),
        nextPage: ++page,
        isLast: true,
      );
    } catch (e, s) {
      print(e);
      yield PageStateError(e, s);
    }
  }

  Future<void> deleteBox() => _box.deleteFromDisk();

  @override
  Resolver get resolver => Api.latestMovies;

  @override
  AsyncCache<MovieData> get cacher => throw UnimplementedError();
}
