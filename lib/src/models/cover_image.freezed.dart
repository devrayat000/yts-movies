// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cover_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CoverImage _$CoverImageFromJson(Map<String, dynamic> json) {
  return _CoverImage.fromJson(json);
}

/// @nodoc
mixin _$CoverImage {
  @JsonKey(name: Col.smallImage)
  String get small => throw _privateConstructorUsedError;
  @JsonKey(name: Col.mediumImage)
  String get medium => throw _privateConstructorUsedError;
  @JsonKey(name: Col.largeImage)
  String? get large => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CoverImageCopyWith<CoverImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoverImageCopyWith<$Res> {
  factory $CoverImageCopyWith(
          CoverImage value, $Res Function(CoverImage) then) =
      _$CoverImageCopyWithImpl<$Res, CoverImage>;
  @useResult
  $Res call(
      {@JsonKey(name: Col.smallImage) String small,
      @JsonKey(name: Col.mediumImage) String medium,
      @JsonKey(name: Col.largeImage) String? large});
}

/// @nodoc
class _$CoverImageCopyWithImpl<$Res, $Val extends CoverImage>
    implements $CoverImageCopyWith<$Res> {
  _$CoverImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? small = null,
    Object? medium = null,
    Object? large = freezed,
  }) {
    return _then(_value.copyWith(
      small: null == small
          ? _value.small
          : small // ignore: cast_nullable_to_non_nullable
              as String,
      medium: null == medium
          ? _value.medium
          : medium // ignore: cast_nullable_to_non_nullable
              as String,
      large: freezed == large
          ? _value.large
          : large // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CoverImageCopyWith<$Res>
    implements $CoverImageCopyWith<$Res> {
  factory _$$_CoverImageCopyWith(
          _$_CoverImage value, $Res Function(_$_CoverImage) then) =
      __$$_CoverImageCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: Col.smallImage) String small,
      @JsonKey(name: Col.mediumImage) String medium,
      @JsonKey(name: Col.largeImage) String? large});
}

/// @nodoc
class __$$_CoverImageCopyWithImpl<$Res>
    extends _$CoverImageCopyWithImpl<$Res, _$_CoverImage>
    implements _$$_CoverImageCopyWith<$Res> {
  __$$_CoverImageCopyWithImpl(
      _$_CoverImage _value, $Res Function(_$_CoverImage) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? small = null,
    Object? medium = null,
    Object? large = freezed,
  }) {
    return _then(_$_CoverImage(
      small: null == small
          ? _value.small
          : small // ignore: cast_nullable_to_non_nullable
              as String,
      medium: null == medium
          ? _value.medium
          : medium // ignore: cast_nullable_to_non_nullable
              as String,
      large: freezed == large
          ? _value.large
          : large // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CoverImage extends _CoverImage {
  const _$_CoverImage(
      {@JsonKey(name: Col.smallImage) required this.small,
      @JsonKey(name: Col.mediumImage) required this.medium,
      @JsonKey(name: Col.largeImage) this.large})
      : super._();

  factory _$_CoverImage.fromJson(Map<String, dynamic> json) =>
      _$$_CoverImageFromJson(json);

  @override
  @JsonKey(name: Col.smallImage)
  final String small;
  @override
  @JsonKey(name: Col.mediumImage)
  final String medium;
  @override
  @JsonKey(name: Col.largeImage)
  final String? large;

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CoverImageCopyWith<_$_CoverImage> get copyWith =>
      __$$_CoverImageCopyWithImpl<_$_CoverImage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CoverImageToJson(
      this,
    );
  }
}

abstract class _CoverImage extends CoverImage {
  const factory _CoverImage(
      {@JsonKey(name: Col.smallImage) required final String small,
      @JsonKey(name: Col.mediumImage) required final String medium,
      @JsonKey(name: Col.largeImage) final String? large}) = _$_CoverImage;
  const _CoverImage._() : super._();

  factory _CoverImage.fromJson(Map<String, dynamic> json) =
      _$_CoverImage.fromJson;

  @override
  @JsonKey(name: Col.smallImage)
  String get small;
  @override
  @JsonKey(name: Col.mediumImage)
  String get medium;
  @override
  @JsonKey(name: Col.largeImage)
  String? get large;
  @override
  @JsonKey(ignore: true)
  _$$_CoverImageCopyWith<_$_CoverImage> get copyWith =>
      throw _privateConstructorUsedError;
}
