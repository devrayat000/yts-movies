library;

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ytsmovies/src/utils/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytsmovies/src/utils/lists.dart' as list;

part './rating.dart';
part './dropdown.dart';
part './order.dart';

part 'index.freezed.dart';

@Freezed(equal: true, toStringOverride: true, copyWith: false)
sealed class Filter with _$Filter {
  @override
  final OrderCubit order = OrderCubit();
  @override
  final SortCubit sort = SortCubit();
  @override
  final GenreCubit genre = GenreCubit();
  @override
  final QualityCubit quality = QualityCubit();
  @override
  final RatingCubit rating = RatingCubit();

  Filter._();

  factory Filter() = _Filter;

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
}
