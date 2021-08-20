part of 'index.dart';

class LatestApiBloc extends ApiBloc {
  @override
  Resolver get resolver => Api.latestMovies;

  @override
  AsyncCache<MovieData> get cacher => AsyncCache<MovieData>(Duration(hours: 1));
}

class RatedApiBloc extends ApiBloc {
  @override
  Resolver get resolver => Api.ratedMovies;

  @override
  AsyncCache<MovieData> get cacher => AsyncCache<MovieData>(Duration(hours: 1));
}

class HDApiBloc extends ApiBloc {
  @override
  Resolver get resolver => Api.hd4kMovies;

  @override
  AsyncCache<MovieData> get cacher => AsyncCache<MovieData>(Duration(hours: 1));
}
