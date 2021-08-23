// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'label_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$LabelValueTearOff {
  const _$LabelValueTearOff();

  _LabelValue<T> call<T>(String label, T? value) {
    return _LabelValue<T>(
      label,
      value,
    );
  }
}

/// @nodoc
const $LabelValue = _$LabelValueTearOff();

/// @nodoc
mixin _$LabelValue<T> {
  String get label => throw _privateConstructorUsedError;
  T? get value => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LabelValueCopyWith<T, LabelValue<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelValueCopyWith<T, $Res> {
  factory $LabelValueCopyWith(
          LabelValue<T> value, $Res Function(LabelValue<T>) then) =
      _$LabelValueCopyWithImpl<T, $Res>;
  $Res call({String label, T? value});
}

/// @nodoc
class _$LabelValueCopyWithImpl<T, $Res>
    implements $LabelValueCopyWith<T, $Res> {
  _$LabelValueCopyWithImpl(this._value, this._then);

  final LabelValue<T> _value;
  // ignore: unused_field
  final $Res Function(LabelValue<T>) _then;

  @override
  $Res call({
    Object? label = freezed,
    Object? value = freezed,
  }) {
    return _then(_value.copyWith(
      label: label == freezed
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: value == freezed
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as T?,
    ));
  }
}

/// @nodoc
abstract class _$LabelValueCopyWith<T, $Res>
    implements $LabelValueCopyWith<T, $Res> {
  factory _$LabelValueCopyWith(
          _LabelValue<T> value, $Res Function(_LabelValue<T>) then) =
      __$LabelValueCopyWithImpl<T, $Res>;
  @override
  $Res call({String label, T? value});
}

/// @nodoc
class __$LabelValueCopyWithImpl<T, $Res>
    extends _$LabelValueCopyWithImpl<T, $Res>
    implements _$LabelValueCopyWith<T, $Res> {
  __$LabelValueCopyWithImpl(
      _LabelValue<T> _value, $Res Function(_LabelValue<T>) _then)
      : super(_value, (v) => _then(v as _LabelValue<T>));

  @override
  _LabelValue<T> get _value => super._value as _LabelValue<T>;

  @override
  $Res call({
    Object? label = freezed,
    Object? value = freezed,
  }) {
    return _then(_LabelValue<T>(
      label == freezed
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value == freezed
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as T?,
    ));
  }
}

/// @nodoc

class _$_LabelValue<T> extends _LabelValue<T> {
  const _$_LabelValue(this.label, this.value) : super._();

  @override
  final String label;
  @override
  final T? value;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _LabelValue<T> &&
            (identical(other.label, label) ||
                const DeepCollectionEquality().equals(other.label, label)) &&
            (identical(other.value, value) ||
                const DeepCollectionEquality().equals(other.value, value)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(label) ^
      const DeepCollectionEquality().hash(value);

  @JsonKey(ignore: true)
  @override
  _$LabelValueCopyWith<T, _LabelValue<T>> get copyWith =>
      __$LabelValueCopyWithImpl<T, _LabelValue<T>>(this, _$identity);
}

abstract class _LabelValue<T> extends LabelValue<T> {
  const factory _LabelValue(String label, T? value) = _$_LabelValue<T>;
  const _LabelValue._() : super._();

  @override
  String get label => throw _privateConstructorUsedError;
  @override
  T? get value => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$LabelValueCopyWith<T, _LabelValue<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
