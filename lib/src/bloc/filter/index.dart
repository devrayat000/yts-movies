library app_bloc.filter;

import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ytsmovies/src/utils/enums.dart';
import 'package:ytsmovies/src/utils/lists.dart' as list;

part './rating.dart';
part './dropdown.dart';
part './order.dart';

class Filter extends Equatable {
  final order = OrderCubit();
  final sort = SortCubit();
  final genre = GenreCubit();
  final quality = QualityCubit();
  final rating = RatingCubit();

  void reset() {
    log("Resetting filter state");
    order.reset();
    sort.reset();
    genre.reset();
    quality.reset();
    rating.reset();
  }

  Map<String, dynamic> get values {
    debugPrint('getting filter values');
    final params = {
      'order_by': order.state ? 'desc' : null,
      'sort_by': sort.state,
      'genre': genre.state,
      'quality': quality.state,
      'minimum_rating': rating.state.round().toString(),
    };
    debugPrint('mapping filter values');
    return params..removeWhere((_, value) => value == null || value == '0');
  }

  @override
  List<Object?> get props => [
        order.state,
        sort.state,
        genre.state,
        quality.state,
        rating.state,
      ];

  @override
  bool get stringify => true;
}
