import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytsmovies/src/utils/constants.dart';

class CoverImage with EquatableMixin {
  final String small;
  final String medium;
  final String? large;
  const CoverImage({
    required this.small,
    required this.medium,
    this.large,
  });

  Map<String, dynamic> toJson() {
    return {
      Col.smallImage: small,
      Col.mediumImage: medium,
      Col.largeImage: large,
    };
  }

  @override
  List<Object?> get props => [small, medium, large];

  @override
  bool? get stringify => true;
}

class CoverImageConverter
    implements JsonConverter<CoverImage, Map<String, dynamic>> {
  const CoverImageConverter();

  @override
  CoverImage fromJson(Map<String, dynamic> json) {
    return CoverImage(
      small: json[Col.smallImage],
      medium: json[Col.mediumImage],
      large: json[Col.largeImage],
    );
  }

  @override
  Map<String, dynamic> toJson(CoverImage object) => object.toJson();
}
