// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoverImage _$CoverImageFromJson(Map<String, dynamic> json) => _CoverImage(
      small: json['small_cover_image'] as String,
      medium: json['medium_cover_image'] as String,
      large: json['large_cover_image'] as String?,
    );

Map<String, dynamic> _$CoverImageToJson(_CoverImage instance) =>
    <String, dynamic>{
      'small_cover_image': instance.small,
      'medium_cover_image': instance.medium,
      'large_cover_image': instance.large,
    };
