library app_bloc.api;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';

import 'package:ytsmovies/src/bloc/api/state.dart';
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

  @override
  void onChange(Change<PageState> change) {
    print('Current: ${change.currentState.runtimeType}\n');
    print('Next: ${change.nextState.runtimeType}\n');
    super.onChange(change);
  }
}
