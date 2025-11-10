// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'torrent_service_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StartDownloadRequest {
  int get taskId;
  String get magnetUri;
  String get savePath;
  String get movieTitle;

  /// Create a copy of StartDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StartDownloadRequestCopyWith<StartDownloadRequest> get copyWith =>
      _$StartDownloadRequestCopyWithImpl<StartDownloadRequest>(
          this as StartDownloadRequest, _$identity);

  /// Serializes this StartDownloadRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StartDownloadRequest &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.magnetUri, magnetUri) ||
                other.magnetUri == magnetUri) &&
            (identical(other.savePath, savePath) ||
                other.savePath == savePath) &&
            (identical(other.movieTitle, movieTitle) ||
                other.movieTitle == movieTitle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, taskId, magnetUri, savePath, movieTitle);

  @override
  String toString() {
    return 'StartDownloadRequest(taskId: $taskId, magnetUri: $magnetUri, savePath: $savePath, movieTitle: $movieTitle)';
  }
}

/// @nodoc
abstract mixin class $StartDownloadRequestCopyWith<$Res> {
  factory $StartDownloadRequestCopyWith(StartDownloadRequest value,
          $Res Function(StartDownloadRequest) _then) =
      _$StartDownloadRequestCopyWithImpl;
  @useResult
  $Res call({int taskId, String magnetUri, String savePath, String movieTitle});
}

/// @nodoc
class _$StartDownloadRequestCopyWithImpl<$Res>
    implements $StartDownloadRequestCopyWith<$Res> {
  _$StartDownloadRequestCopyWithImpl(this._self, this._then);

  final StartDownloadRequest _self;
  final $Res Function(StartDownloadRequest) _then;

  /// Create a copy of StartDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taskId = null,
    Object? magnetUri = null,
    Object? savePath = null,
    Object? movieTitle = null,
  }) {
    return _then(_self.copyWith(
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      magnetUri: null == magnetUri
          ? _self.magnetUri
          : magnetUri // ignore: cast_nullable_to_non_nullable
              as String,
      savePath: null == savePath
          ? _self.savePath
          : savePath // ignore: cast_nullable_to_non_nullable
              as String,
      movieTitle: null == movieTitle
          ? _self.movieTitle
          : movieTitle // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _StartDownloadRequest implements StartDownloadRequest {
  const _StartDownloadRequest(
      {required this.taskId,
      required this.magnetUri,
      required this.savePath,
      required this.movieTitle});
  factory _StartDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$StartDownloadRequestFromJson(json);

  @override
  final int taskId;
  @override
  final String magnetUri;
  @override
  final String savePath;
  @override
  final String movieTitle;

  /// Create a copy of StartDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StartDownloadRequestCopyWith<_StartDownloadRequest> get copyWith =>
      __$StartDownloadRequestCopyWithImpl<_StartDownloadRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StartDownloadRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StartDownloadRequest &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.magnetUri, magnetUri) ||
                other.magnetUri == magnetUri) &&
            (identical(other.savePath, savePath) ||
                other.savePath == savePath) &&
            (identical(other.movieTitle, movieTitle) ||
                other.movieTitle == movieTitle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, taskId, magnetUri, savePath, movieTitle);

  @override
  String toString() {
    return 'StartDownloadRequest(taskId: $taskId, magnetUri: $magnetUri, savePath: $savePath, movieTitle: $movieTitle)';
  }
}

/// @nodoc
abstract mixin class _$StartDownloadRequestCopyWith<$Res>
    implements $StartDownloadRequestCopyWith<$Res> {
  factory _$StartDownloadRequestCopyWith(_StartDownloadRequest value,
          $Res Function(_StartDownloadRequest) _then) =
      __$StartDownloadRequestCopyWithImpl;
  @override
  @useResult
  $Res call({int taskId, String magnetUri, String savePath, String movieTitle});
}

/// @nodoc
class __$StartDownloadRequestCopyWithImpl<$Res>
    implements _$StartDownloadRequestCopyWith<$Res> {
  __$StartDownloadRequestCopyWithImpl(this._self, this._then);

  final _StartDownloadRequest _self;
  final $Res Function(_StartDownloadRequest) _then;

  /// Create a copy of StartDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? taskId = null,
    Object? magnetUri = null,
    Object? savePath = null,
    Object? movieTitle = null,
  }) {
    return _then(_StartDownloadRequest(
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      magnetUri: null == magnetUri
          ? _self.magnetUri
          : magnetUri // ignore: cast_nullable_to_non_nullable
              as String,
      savePath: null == savePath
          ? _self.savePath
          : savePath // ignore: cast_nullable_to_non_nullable
              as String,
      movieTitle: null == movieTitle
          ? _self.movieTitle
          : movieTitle // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$DownloadControlRequest {
  int get taskId;

  /// Create a copy of DownloadControlRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadControlRequestCopyWith<DownloadControlRequest> get copyWith =>
      _$DownloadControlRequestCopyWithImpl<DownloadControlRequest>(
          this as DownloadControlRequest, _$identity);

  /// Serializes this DownloadControlRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadControlRequest &&
            (identical(other.taskId, taskId) || other.taskId == taskId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, taskId);

  @override
  String toString() {
    return 'DownloadControlRequest(taskId: $taskId)';
  }
}

/// @nodoc
abstract mixin class $DownloadControlRequestCopyWith<$Res> {
  factory $DownloadControlRequestCopyWith(DownloadControlRequest value,
          $Res Function(DownloadControlRequest) _then) =
      _$DownloadControlRequestCopyWithImpl;
  @useResult
  $Res call({int taskId});
}

/// @nodoc
class _$DownloadControlRequestCopyWithImpl<$Res>
    implements $DownloadControlRequestCopyWith<$Res> {
  _$DownloadControlRequestCopyWithImpl(this._self, this._then);

  final DownloadControlRequest _self;
  final $Res Function(DownloadControlRequest) _then;

  /// Create a copy of DownloadControlRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taskId = null,
  }) {
    return _then(_self.copyWith(
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _DownloadControlRequest implements DownloadControlRequest {
  const _DownloadControlRequest({required this.taskId});
  factory _DownloadControlRequest.fromJson(Map<String, dynamic> json) =>
      _$DownloadControlRequestFromJson(json);

  @override
  final int taskId;

  /// Create a copy of DownloadControlRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DownloadControlRequestCopyWith<_DownloadControlRequest> get copyWith =>
      __$DownloadControlRequestCopyWithImpl<_DownloadControlRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DownloadControlRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DownloadControlRequest &&
            (identical(other.taskId, taskId) || other.taskId == taskId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, taskId);

  @override
  String toString() {
    return 'DownloadControlRequest(taskId: $taskId)';
  }
}

/// @nodoc
abstract mixin class _$DownloadControlRequestCopyWith<$Res>
    implements $DownloadControlRequestCopyWith<$Res> {
  factory _$DownloadControlRequestCopyWith(_DownloadControlRequest value,
          $Res Function(_DownloadControlRequest) _then) =
      __$DownloadControlRequestCopyWithImpl;
  @override
  @useResult
  $Res call({int taskId});
}

/// @nodoc
class __$DownloadControlRequestCopyWithImpl<$Res>
    implements _$DownloadControlRequestCopyWith<$Res> {
  __$DownloadControlRequestCopyWithImpl(this._self, this._then);

  final _DownloadControlRequest _self;
  final $Res Function(_DownloadControlRequest) _then;

  /// Create a copy of DownloadControlRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? taskId = null,
  }) {
    return _then(_DownloadControlRequest(
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$ProgressUpdate {
  int get taskId;
  DownloadStatus get status;
  double get progress;
  int get downloadSpeed;
  int get uploadSpeed;
  int get peers;
  int get seeders;
  int get downloadedBytes;
  int get totalBytes;
  String? get error;

  /// Create a copy of ProgressUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProgressUpdateCopyWith<ProgressUpdate> get copyWith =>
      _$ProgressUpdateCopyWithImpl<ProgressUpdate>(
          this as ProgressUpdate, _$identity);

  /// Serializes this ProgressUpdate to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProgressUpdate &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.downloadSpeed, downloadSpeed) ||
                other.downloadSpeed == downloadSpeed) &&
            (identical(other.uploadSpeed, uploadSpeed) ||
                other.uploadSpeed == uploadSpeed) &&
            (identical(other.peers, peers) || other.peers == peers) &&
            (identical(other.seeders, seeders) || other.seeders == seeders) &&
            (identical(other.downloadedBytes, downloadedBytes) ||
                other.downloadedBytes == downloadedBytes) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      taskId,
      status,
      progress,
      downloadSpeed,
      uploadSpeed,
      peers,
      seeders,
      downloadedBytes,
      totalBytes,
      error);

  @override
  String toString() {
    return 'ProgressUpdate(taskId: $taskId, status: $status, progress: $progress, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed, peers: $peers, seeders: $seeders, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes, error: $error)';
  }
}

/// @nodoc
abstract mixin class $ProgressUpdateCopyWith<$Res> {
  factory $ProgressUpdateCopyWith(
          ProgressUpdate value, $Res Function(ProgressUpdate) _then) =
      _$ProgressUpdateCopyWithImpl;
  @useResult
  $Res call(
      {int taskId,
      DownloadStatus status,
      double progress,
      int downloadSpeed,
      int uploadSpeed,
      int peers,
      int seeders,
      int downloadedBytes,
      int totalBytes,
      String? error});
}

/// @nodoc
class _$ProgressUpdateCopyWithImpl<$Res>
    implements $ProgressUpdateCopyWith<$Res> {
  _$ProgressUpdateCopyWithImpl(this._self, this._then);

  final ProgressUpdate _self;
  final $Res Function(ProgressUpdate) _then;

  /// Create a copy of ProgressUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taskId = null,
    Object? status = null,
    Object? progress = null,
    Object? downloadSpeed = null,
    Object? uploadSpeed = null,
    Object? peers = null,
    Object? seeders = null,
    Object? downloadedBytes = null,
    Object? totalBytes = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as DownloadStatus,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      downloadSpeed: null == downloadSpeed
          ? _self.downloadSpeed
          : downloadSpeed // ignore: cast_nullable_to_non_nullable
              as int,
      uploadSpeed: null == uploadSpeed
          ? _self.uploadSpeed
          : uploadSpeed // ignore: cast_nullable_to_non_nullable
              as int,
      peers: null == peers
          ? _self.peers
          : peers // ignore: cast_nullable_to_non_nullable
              as int,
      seeders: null == seeders
          ? _self.seeders
          : seeders // ignore: cast_nullable_to_non_nullable
              as int,
      downloadedBytes: null == downloadedBytes
          ? _self.downloadedBytes
          : downloadedBytes // ignore: cast_nullable_to_non_nullable
              as int,
      totalBytes: null == totalBytes
          ? _self.totalBytes
          : totalBytes // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ProgressUpdate implements ProgressUpdate {
  const _ProgressUpdate(
      {required this.taskId,
      required this.status,
      this.progress = 0.0,
      this.downloadSpeed = 0,
      this.uploadSpeed = 0,
      this.peers = 0,
      this.seeders = 0,
      this.downloadedBytes = 0,
      this.totalBytes = 0,
      this.error});
  factory _ProgressUpdate.fromJson(Map<String, dynamic> json) =>
      _$ProgressUpdateFromJson(json);

  @override
  final int taskId;
  @override
  final DownloadStatus status;
  @override
  @JsonKey()
  final double progress;
  @override
  @JsonKey()
  final int downloadSpeed;
  @override
  @JsonKey()
  final int uploadSpeed;
  @override
  @JsonKey()
  final int peers;
  @override
  @JsonKey()
  final int seeders;
  @override
  @JsonKey()
  final int downloadedBytes;
  @override
  @JsonKey()
  final int totalBytes;
  @override
  final String? error;

  /// Create a copy of ProgressUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProgressUpdateCopyWith<_ProgressUpdate> get copyWith =>
      __$ProgressUpdateCopyWithImpl<_ProgressUpdate>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProgressUpdateToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProgressUpdate &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.downloadSpeed, downloadSpeed) ||
                other.downloadSpeed == downloadSpeed) &&
            (identical(other.uploadSpeed, uploadSpeed) ||
                other.uploadSpeed == uploadSpeed) &&
            (identical(other.peers, peers) || other.peers == peers) &&
            (identical(other.seeders, seeders) || other.seeders == seeders) &&
            (identical(other.downloadedBytes, downloadedBytes) ||
                other.downloadedBytes == downloadedBytes) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      taskId,
      status,
      progress,
      downloadSpeed,
      uploadSpeed,
      peers,
      seeders,
      downloadedBytes,
      totalBytes,
      error);

  @override
  String toString() {
    return 'ProgressUpdate(taskId: $taskId, status: $status, progress: $progress, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed, peers: $peers, seeders: $seeders, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$ProgressUpdateCopyWith<$Res>
    implements $ProgressUpdateCopyWith<$Res> {
  factory _$ProgressUpdateCopyWith(
          _ProgressUpdate value, $Res Function(_ProgressUpdate) _then) =
      __$ProgressUpdateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int taskId,
      DownloadStatus status,
      double progress,
      int downloadSpeed,
      int uploadSpeed,
      int peers,
      int seeders,
      int downloadedBytes,
      int totalBytes,
      String? error});
}

/// @nodoc
class __$ProgressUpdateCopyWithImpl<$Res>
    implements _$ProgressUpdateCopyWith<$Res> {
  __$ProgressUpdateCopyWithImpl(this._self, this._then);

  final _ProgressUpdate _self;
  final $Res Function(_ProgressUpdate) _then;

  /// Create a copy of ProgressUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? taskId = null,
    Object? status = null,
    Object? progress = null,
    Object? downloadSpeed = null,
    Object? uploadSpeed = null,
    Object? peers = null,
    Object? seeders = null,
    Object? downloadedBytes = null,
    Object? totalBytes = null,
    Object? error = freezed,
  }) {
    return _then(_ProgressUpdate(
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as DownloadStatus,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      downloadSpeed: null == downloadSpeed
          ? _self.downloadSpeed
          : downloadSpeed // ignore: cast_nullable_to_non_nullable
              as int,
      uploadSpeed: null == uploadSpeed
          ? _self.uploadSpeed
          : uploadSpeed // ignore: cast_nullable_to_non_nullable
              as int,
      peers: null == peers
          ? _self.peers
          : peers // ignore: cast_nullable_to_non_nullable
              as int,
      seeders: null == seeders
          ? _self.seeders
          : seeders // ignore: cast_nullable_to_non_nullable
              as int,
      downloadedBytes: null == downloadedBytes
          ? _self.downloadedBytes
          : downloadedBytes // ignore: cast_nullable_to_non_nullable
              as int,
      totalBytes: null == totalBytes
          ? _self.totalBytes
          : totalBytes // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
