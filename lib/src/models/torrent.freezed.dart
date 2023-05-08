// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'torrent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Torrent _$TorrentFromJson(Map<String, dynamic> json) {
  return _Torrent.fromJson(json);
}

/// @nodoc
mixin _$Torrent {
  @HiveField(0)
  String get url => throw _privateConstructorUsedError;
  @HiveField(1)
  String get hash => throw _privateConstructorUsedError;
  @HiveField(2)
  String get quality => throw _privateConstructorUsedError;
  @HiveField(3)
  int get seeds => throw _privateConstructorUsedError;
  @HiveField(4)
  int get peers => throw _privateConstructorUsedError;
  @HiveField(5)
  String get size => throw _privateConstructorUsedError;
  @HiveField(6)
  DateTime get dateUploaded => throw _privateConstructorUsedError;
  @HiveField(7)
  String? get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TorrentCopyWith<Torrent> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TorrentCopyWith<$Res> {
  factory $TorrentCopyWith(Torrent value, $Res Function(Torrent) then) =
      _$TorrentCopyWithImpl<$Res, Torrent>;
  @useResult
  $Res call(
      {@HiveField(0) String url,
      @HiveField(1) String hash,
      @HiveField(2) String quality,
      @HiveField(3) int seeds,
      @HiveField(4) int peers,
      @HiveField(5) String size,
      @HiveField(6) DateTime dateUploaded,
      @HiveField(7) String? type});
}

/// @nodoc
class _$TorrentCopyWithImpl<$Res, $Val extends Torrent>
    implements $TorrentCopyWith<$Res> {
  _$TorrentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? hash = null,
    Object? quality = null,
    Object? seeds = null,
    Object? peers = null,
    Object? size = null,
    Object? dateUploaded = null,
    Object? type = freezed,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      hash: null == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      quality: null == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as String,
      seeds: null == seeds
          ? _value.seeds
          : seeds // ignore: cast_nullable_to_non_nullable
              as int,
      peers: null == peers
          ? _value.peers
          : peers // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String,
      dateUploaded: null == dateUploaded
          ? _value.dateUploaded
          : dateUploaded // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TorrentCopyWith<$Res> implements $TorrentCopyWith<$Res> {
  factory _$$_TorrentCopyWith(
          _$_Torrent value, $Res Function(_$_Torrent) then) =
      __$$_TorrentCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String url,
      @HiveField(1) String hash,
      @HiveField(2) String quality,
      @HiveField(3) int seeds,
      @HiveField(4) int peers,
      @HiveField(5) String size,
      @HiveField(6) DateTime dateUploaded,
      @HiveField(7) String? type});
}

/// @nodoc
class __$$_TorrentCopyWithImpl<$Res>
    extends _$TorrentCopyWithImpl<$Res, _$_Torrent>
    implements _$$_TorrentCopyWith<$Res> {
  __$$_TorrentCopyWithImpl(_$_Torrent _value, $Res Function(_$_Torrent) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? hash = null,
    Object? quality = null,
    Object? seeds = null,
    Object? peers = null,
    Object? size = null,
    Object? dateUploaded = null,
    Object? type = freezed,
  }) {
    return _then(_$_Torrent(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      hash: null == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      quality: null == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as String,
      seeds: null == seeds
          ? _value.seeds
          : seeds // ignore: cast_nullable_to_non_nullable
              as int,
      peers: null == peers
          ? _value.peers
          : peers // ignore: cast_nullable_to_non_nullable
              as int,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String,
      dateUploaded: null == dateUploaded
          ? _value.dateUploaded
          : dateUploaded // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 2, adapterName: 'TorrentAdapter')
class _$_Torrent extends _Torrent {
  _$_Torrent(
      {@HiveField(0) required this.url,
      @HiveField(1) required this.hash,
      @HiveField(2) required this.quality,
      @HiveField(3) required this.seeds,
      @HiveField(4) required this.peers,
      @HiveField(5) required this.size,
      @HiveField(6) required this.dateUploaded,
      @HiveField(7) this.type})
      : super._();

  factory _$_Torrent.fromJson(Map<String, dynamic> json) =>
      _$$_TorrentFromJson(json);

  @override
  @HiveField(0)
  final String url;
  @override
  @HiveField(1)
  final String hash;
  @override
  @HiveField(2)
  final String quality;
  @override
  @HiveField(3)
  final int seeds;
  @override
  @HiveField(4)
  final int peers;
  @override
  @HiveField(5)
  final String size;
  @override
  @HiveField(6)
  final DateTime dateUploaded;
  @override
  @HiveField(7)
  final String? type;

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TorrentCopyWith<_$_Torrent> get copyWith =>
      __$$_TorrentCopyWithImpl<_$_Torrent>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TorrentToJson(
      this,
    );
  }
}

abstract class _Torrent extends Torrent {
  factory _Torrent(
      {@HiveField(0) required final String url,
      @HiveField(1) required final String hash,
      @HiveField(2) required final String quality,
      @HiveField(3) required final int seeds,
      @HiveField(4) required final int peers,
      @HiveField(5) required final String size,
      @HiveField(6) required final DateTime dateUploaded,
      @HiveField(7) final String? type}) = _$_Torrent;
  _Torrent._() : super._();

  factory _Torrent.fromJson(Map<String, dynamic> json) = _$_Torrent.fromJson;

  @override
  @HiveField(0)
  String get url;
  @override
  @HiveField(1)
  String get hash;
  @override
  @HiveField(2)
  String get quality;
  @override
  @HiveField(3)
  int get seeds;
  @override
  @HiveField(4)
  int get peers;
  @override
  @HiveField(5)
  String get size;
  @override
  @HiveField(6)
  DateTime get dateUploaded;
  @override
  @HiveField(7)
  String? get type;
  @override
  @JsonKey(ignore: true)
  _$$_TorrentCopyWith<_$_Torrent> get copyWith =>
      throw _privateConstructorUsedError;
}
