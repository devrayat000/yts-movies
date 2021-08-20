// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ytsmovies/utils/enums.dart';
import 'package:ytsmovies/utils/lists.dart' as list;

part './rating.dart';
part './dropdown.dart';
part './order.dart';

class Filter {
  final order = OrderCubit();
  final sort = SortCubit();
  final genre = GenreCubit();
  final quality = QualityCubit();
  final rating = RatingCubit();

  // final order = OrderCubit();
  // final sort = SortCubit();
  // final genre = GenreCubit();
  // final quality = QualityCubit();
  // final rating = RatingCubit();

  void reset() {
    order.reset();
    sort.reset();
    genre.reset();
    quality.reset();
    rating.reset();
  }

  Map<String, dynamic> get values {
    print('getting filter values');
    final params = {
      'order_by': order.state ? 'desc' : null,
      'sort': sort.state,
      'genre': genre.state,
      'quality': quality.state,
      'rating': rating.state.round().toString(),
    };
    print('mapping filter values');
    return params..removeWhere((_, value) => value == null || value == '0');
  }
}
