import 'package:freezed_annotation/freezed_annotation.dart';

part 'label_value.freezed.dart';

@Freezed(equal: true, toStringOverride: true, copyWith: false)
@immutable
sealed class LabelValue<T> with _$LabelValue<T> {
  const LabelValue._();

  const factory LabelValue(String label, T? value) = _LabelValue<T>;
}
