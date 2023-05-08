import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytsmovies/src/utils/constants.dart';

part 'cover_image.g.dart';
part 'cover_image.freezed.dart';

@Freezed(equal: false, toStringOverride: false)
class CoverImage with _$CoverImage, EquatableMixin {
  const CoverImage._();

  const factory CoverImage({
    @JsonKey(name: Col.smallImage) required String small,
    @JsonKey(name: Col.mediumImage) required String medium,
    @JsonKey(name: Col.largeImage) String? large,
  }) = _CoverImage;

  factory CoverImage.fromJson(Map<String, dynamic> json) =>
      _$CoverImageFromJson(json);

  @override
  List<Object?> get props => [small, medium, large];

  @override
  bool? get stringify => true;
}
