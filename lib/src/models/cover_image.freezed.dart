// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cover_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoverImage {
  @JsonKey(name: Col.smallImage)
  String get small;
  @JsonKey(name: Col.mediumImage)
  String get medium;
  @JsonKey(name: Col.largeImage)
  String? get large;

  /// Serializes this CoverImage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CoverImage &&
            (identical(other.small, small) || other.small == small) &&
            (identical(other.medium, medium) || other.medium == medium) &&
            (identical(other.large, large) || other.large == large));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, small, medium, large);

  @override
  String toString() {
    return 'CoverImage(small: $small, medium: $medium, large: $large)';
  }
}

/// @nodoc
@JsonSerializable()
class _CoverImage implements CoverImage {
  const _CoverImage(
      {@JsonKey(name: Col.smallImage) required this.small,
      @JsonKey(name: Col.mediumImage) required this.medium,
      @JsonKey(name: Col.largeImage) this.large});
  factory _CoverImage.fromJson(Map<String, dynamic> json) =>
      _$CoverImageFromJson(json);

  @override
  @JsonKey(name: Col.smallImage)
  final String small;
  @override
  @JsonKey(name: Col.mediumImage)
  final String medium;
  @override
  @JsonKey(name: Col.largeImage)
  final String? large;

  @override
  Map<String, dynamic> toJson() {
    return _$CoverImageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CoverImage &&
            (identical(other.small, small) || other.small == small) &&
            (identical(other.medium, medium) || other.medium == medium) &&
            (identical(other.large, large) || other.large == large));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, small, medium, large);

  @override
  String toString() {
    return 'CoverImage(small: $small, medium: $medium, large: $large)';
  }
}

// dart format on
