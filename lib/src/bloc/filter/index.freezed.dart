// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'index.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Filter implements DiagnosticableTreeMixin {
  OrderCubit get order;
  SortCubit get sort;
  GenreCubit get genre;
  QualityCubit get quality;
  RatingCubit get rating;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'Filter'))
      ..add(DiagnosticsProperty('order', order))
      ..add(DiagnosticsProperty('sort', sort))
      ..add(DiagnosticsProperty('genre', genre))
      ..add(DiagnosticsProperty('quality', quality))
      ..add(DiagnosticsProperty('rating', rating));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Filter &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, order, sort, genre, quality, rating);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Filter(order: $order, sort: $sort, genre: $genre, quality: $quality, rating: $rating)';
  }
}

/// @nodoc

class _Filter extends Filter with DiagnosticableTreeMixin {
  _Filter() : super._();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'Filter'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Filter);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Filter()';
  }
}

// dart format on
