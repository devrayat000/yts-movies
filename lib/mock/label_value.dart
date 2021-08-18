import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'label_value.freezed.dart';

@freezed
@immutable
class LabelValue<T> with _$LabelValue<T>, EquatableMixin {
  LabelValue._();

  factory LabelValue(String label, T? value) = _LabelValue<T>;

  @override
  List<Object?> get props => [label, value];

  @override
  bool? get stringify => true;
}
