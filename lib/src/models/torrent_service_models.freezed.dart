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
  String get taskId;
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
  $Res call(
      {String taskId, String magnetUri, String savePath, String movieTitle});
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
              as String,
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
  final String taskId;
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
  $Res call(
      {String taskId, String magnetUri, String savePath, String movieTitle});
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
              as String,
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
mixin _$PauseDownloadRequest {
  String get taskId;

  /// Create a copy of PauseDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PauseDownloadRequestCopyWith<PauseDownloadRequest> get copyWith =>
      _$PauseDownloadRequestCopyWithImpl<PauseDownloadRequest>(
          this as PauseDownloadRequest, _$identity);

  /// Serializes this PauseDownloadRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PauseDownloadRequest &&
            (identical(other.taskId, taskId) || other.taskId == taskId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, taskId);

  @override
  String toString() {
    return 'PauseDownloadRequest(taskId: $taskId)';
  }
}

/// @nodoc
abstract mixin class $PauseDownloadRequestCopyWith<$Res> {
  factory $PauseDownloadRequestCopyWith(PauseDownloadRequest value,
          $Res Function(PauseDownloadRequest) _then) =
      _$PauseDownloadRequestCopyWithImpl;
  @useResult
  $Res call({String taskId});
}

/// @nodoc
class _$PauseDownloadRequestCopyWithImpl<$Res>
    implements $PauseDownloadRequestCopyWith<$Res> {
  _$PauseDownloadRequestCopyWithImpl(this._self, this._then);

  final PauseDownloadRequest _self;
  final $Res Function(PauseDownloadRequest) _then;

  /// Create a copy of PauseDownloadRequest
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
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _PauseDownloadRequest implements PauseDownloadRequest {
  const _PauseDownloadRequest({required this.taskId});
  factory _PauseDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$PauseDownloadRequestFromJson(json);

  @override
  final String taskId;

  /// Create a copy of PauseDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PauseDownloadRequestCopyWith<_PauseDownloadRequest> get copyWith =>
      __$PauseDownloadRequestCopyWithImpl<_PauseDownloadRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PauseDownloadRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PauseDownloadRequest &&
            (identical(other.taskId, taskId) || other.taskId == taskId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, taskId);

  @override
  String toString() {
    return 'PauseDownloadRequest(taskId: $taskId)';
  }
}

/// @nodoc
abstract mixin class _$PauseDownloadRequestCopyWith<$Res>
    implements $PauseDownloadRequestCopyWith<$Res> {
  factory _$PauseDownloadRequestCopyWith(_PauseDownloadRequest value,
          $Res Function(_PauseDownloadRequest) _then) =
      __$PauseDownloadRequestCopyWithImpl;
  @override
  @useResult
  $Res call({String taskId});
}

/// @nodoc
class __$PauseDownloadRequestCopyWithImpl<$Res>
    implements _$PauseDownloadRequestCopyWith<$Res> {
  __$PauseDownloadRequestCopyWithImpl(this._self, this._then);

  final _PauseDownloadRequest _self;
  final $Res Function(_PauseDownloadRequest) _then;

  /// Create a copy of PauseDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? taskId = null,
  }) {
    return _then(_PauseDownloadRequest(
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ResumeDownloadRequest {
  String get taskId;

  /// Create a copy of ResumeDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ResumeDownloadRequestCopyWith<ResumeDownloadRequest> get copyWith =>
      _$ResumeDownloadRequestCopyWithImpl<ResumeDownloadRequest>(
          this as ResumeDownloadRequest, _$identity);

  /// Serializes this ResumeDownloadRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ResumeDownloadRequest &&
            (identical(other.taskId, taskId) || other.taskId == taskId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, taskId);

  @override
  String toString() {
    return 'ResumeDownloadRequest(taskId: $taskId)';
  }
}

/// @nodoc
abstract mixin class $ResumeDownloadRequestCopyWith<$Res> {
  factory $ResumeDownloadRequestCopyWith(ResumeDownloadRequest value,
          $Res Function(ResumeDownloadRequest) _then) =
      _$ResumeDownloadRequestCopyWithImpl;
  @useResult
  $Res call({String taskId});
}

/// @nodoc
class _$ResumeDownloadRequestCopyWithImpl<$Res>
    implements $ResumeDownloadRequestCopyWith<$Res> {
  _$ResumeDownloadRequestCopyWithImpl(this._self, this._then);

  final ResumeDownloadRequest _self;
  final $Res Function(ResumeDownloadRequest) _then;

  /// Create a copy of ResumeDownloadRequest
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
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ResumeDownloadRequest implements ResumeDownloadRequest {
  const _ResumeDownloadRequest({required this.taskId});
  factory _ResumeDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$ResumeDownloadRequestFromJson(json);

  @override
  final String taskId;

  /// Create a copy of ResumeDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ResumeDownloadRequestCopyWith<_ResumeDownloadRequest> get copyWith =>
      __$ResumeDownloadRequestCopyWithImpl<_ResumeDownloadRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ResumeDownloadRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ResumeDownloadRequest &&
            (identical(other.taskId, taskId) || other.taskId == taskId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, taskId);

  @override
  String toString() {
    return 'ResumeDownloadRequest(taskId: $taskId)';
  }
}

/// @nodoc
abstract mixin class _$ResumeDownloadRequestCopyWith<$Res>
    implements $ResumeDownloadRequestCopyWith<$Res> {
  factory _$ResumeDownloadRequestCopyWith(_ResumeDownloadRequest value,
          $Res Function(_ResumeDownloadRequest) _then) =
      __$ResumeDownloadRequestCopyWithImpl;
  @override
  @useResult
  $Res call({String taskId});
}

/// @nodoc
class __$ResumeDownloadRequestCopyWithImpl<$Res>
    implements _$ResumeDownloadRequestCopyWith<$Res> {
  __$ResumeDownloadRequestCopyWithImpl(this._self, this._then);

  final _ResumeDownloadRequest _self;
  final $Res Function(_ResumeDownloadRequest) _then;

  /// Create a copy of ResumeDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? taskId = null,
  }) {
    return _then(_ResumeDownloadRequest(
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$StopDownloadRequest {
  String get taskId;

  /// Create a copy of StopDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StopDownloadRequestCopyWith<StopDownloadRequest> get copyWith =>
      _$StopDownloadRequestCopyWithImpl<StopDownloadRequest>(
          this as StopDownloadRequest, _$identity);

  /// Serializes this StopDownloadRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StopDownloadRequest &&
            (identical(other.taskId, taskId) || other.taskId == taskId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, taskId);

  @override
  String toString() {
    return 'StopDownloadRequest(taskId: $taskId)';
  }
}

/// @nodoc
abstract mixin class $StopDownloadRequestCopyWith<$Res> {
  factory $StopDownloadRequestCopyWith(
          StopDownloadRequest value, $Res Function(StopDownloadRequest) _then) =
      _$StopDownloadRequestCopyWithImpl;
  @useResult
  $Res call({String taskId});
}

/// @nodoc
class _$StopDownloadRequestCopyWithImpl<$Res>
    implements $StopDownloadRequestCopyWith<$Res> {
  _$StopDownloadRequestCopyWithImpl(this._self, this._then);

  final StopDownloadRequest _self;
  final $Res Function(StopDownloadRequest) _then;

  /// Create a copy of StopDownloadRequest
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
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _StopDownloadRequest implements StopDownloadRequest {
  const _StopDownloadRequest({required this.taskId});
  factory _StopDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$StopDownloadRequestFromJson(json);

  @override
  final String taskId;

  /// Create a copy of StopDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StopDownloadRequestCopyWith<_StopDownloadRequest> get copyWith =>
      __$StopDownloadRequestCopyWithImpl<_StopDownloadRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StopDownloadRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StopDownloadRequest &&
            (identical(other.taskId, taskId) || other.taskId == taskId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, taskId);

  @override
  String toString() {
    return 'StopDownloadRequest(taskId: $taskId)';
  }
}

/// @nodoc
abstract mixin class _$StopDownloadRequestCopyWith<$Res>
    implements $StopDownloadRequestCopyWith<$Res> {
  factory _$StopDownloadRequestCopyWith(_StopDownloadRequest value,
          $Res Function(_StopDownloadRequest) _then) =
      __$StopDownloadRequestCopyWithImpl;
  @override
  @useResult
  $Res call({String taskId});
}

/// @nodoc
class __$StopDownloadRequestCopyWithImpl<$Res>
    implements _$StopDownloadRequestCopyWith<$Res> {
  __$StopDownloadRequestCopyWithImpl(this._self, this._then);

  final _StopDownloadRequest _self;
  final $Res Function(_StopDownloadRequest) _then;

  /// Create a copy of StopDownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? taskId = null,
  }) {
    return _then(_StopDownloadRequest(
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ProgressUpdate {
  String get taskId;
  DownloadStatusType get status;
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
      {String taskId,
      DownloadStatusType status,
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
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as DownloadStatusType,
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
  final String taskId;
  @override
  final DownloadStatusType status;
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
      {String taskId,
      DownloadStatusType status,
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
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as DownloadStatusType,
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
