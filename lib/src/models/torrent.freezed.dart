// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'torrent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Torrent {
  String get url;
  String get hash;
  String get quality;
  int get seeds;
  int get peers;
  String get size;
  DateTime get dateUploaded;
  String? get type;

  /// Serializes this Torrent to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Torrent &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.seeds, seeds) || other.seeds == seeds) &&
            (identical(other.peers, peers) || other.peers == peers) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.dateUploaded, dateUploaded) ||
                other.dateUploaded == dateUploaded) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, url, hash, quality, seeds, peers, size, dateUploaded, type);

  @override
  String toString() {
    return 'Torrent(url: $url, hash: $hash, quality: $quality, seeds: $seeds, peers: $peers, size: $size, dateUploaded: $dateUploaded, type: $type)';
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Torrent extends Torrent {
  const _Torrent(
      {required this.url,
      required this.hash,
      required this.quality,
      required this.seeds,
      required this.peers,
      required this.size,
      required this.dateUploaded,
      this.type})
      : super._();
  factory _Torrent.fromJson(Map<String, dynamic> json) =>
      _$TorrentFromJson(json);

  @override
  final String url;
  @override
  final String hash;
  @override
  final String quality;
  @override
  final int seeds;
  @override
  final int peers;
  @override
  final String size;
  @override
  final DateTime dateUploaded;
  @override
  final String? type;

  @override
  Map<String, dynamic> toJson() {
    return _$TorrentToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Torrent &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.seeds, seeds) || other.seeds == seeds) &&
            (identical(other.peers, peers) || other.peers == peers) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.dateUploaded, dateUploaded) ||
                other.dateUploaded == dateUploaded) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, url, hash, quality, seeds, peers, size, dateUploaded, type);

  @override
  String toString() {
    return 'Torrent(url: $url, hash: $hash, quality: $quality, seeds: $seeds, peers: $peers, size: $size, dateUploaded: $dateUploaded, type: $type)';
  }
}

// dart format on
