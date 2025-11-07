// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DownloadTask {
  /// Unique task identifier
  String get taskId;

  /// Movie ID from YTS
  int get movieId;

  /// Movie title
  String get movieTitle;

  /// Torrent hash
  String get torrentHash;

  /// Torrent magnet link
  String get magnetUri;

  /// Quality (e.g., "720p", "1080p")
  String get quality;

  /// File type (e.g., "web", "bluray")
  String? get type;

  /// File size
  String get size;

  /// Download progress (0.0 to 1.0)
  double get progress;

  /// Download status
  DownloadStatus get status;

  /// Download speed in bytes per second
  int get downloadSpeed;

  /// Upload speed in bytes per second
  int get uploadSpeed;

  /// Number of peers
  int get peers;

  /// Number of seeders
  int get seeders;

  /// Downloaded bytes
  int get downloadedBytes;

  /// Total bytes
  int get totalBytes;

  /// File path where the download is saved
  String? get filePath;

  /// Error message if download failed
  String? get errorMessage;

  /// Time when download was started
  DateTime? get startedAt;

  /// Time when download was completed
  DateTime? get completedAt;

  /// Movie cover image URL
  String? get coverImage;

  /// Create a copy of DownloadTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DownloadTaskCopyWith<DownloadTask> get copyWith =>
      _$DownloadTaskCopyWithImpl<DownloadTask>(
          this as DownloadTask, _$identity);

  /// Serializes this DownloadTask to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DownloadTask &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.movieId, movieId) || other.movieId == movieId) &&
            (identical(other.movieTitle, movieTitle) ||
                other.movieTitle == movieTitle) &&
            (identical(other.torrentHash, torrentHash) ||
                other.torrentHash == torrentHash) &&
            (identical(other.magnetUri, magnetUri) ||
                other.magnetUri == magnetUri) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.status, status) || other.status == status) &&
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
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        taskId,
        movieId,
        movieTitle,
        torrentHash,
        magnetUri,
        quality,
        type,
        size,
        progress,
        status,
        downloadSpeed,
        uploadSpeed,
        peers,
        seeders,
        downloadedBytes,
        totalBytes,
        filePath,
        errorMessage,
        startedAt,
        completedAt,
        coverImage
      ]);

  @override
  String toString() {
    return 'DownloadTask(taskId: $taskId, movieId: $movieId, movieTitle: $movieTitle, torrentHash: $torrentHash, magnetUri: $magnetUri, quality: $quality, type: $type, size: $size, progress: $progress, status: $status, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed, peers: $peers, seeders: $seeders, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes, filePath: $filePath, errorMessage: $errorMessage, startedAt: $startedAt, completedAt: $completedAt, coverImage: $coverImage)';
  }
}

/// @nodoc
abstract mixin class $DownloadTaskCopyWith<$Res> {
  factory $DownloadTaskCopyWith(
          DownloadTask value, $Res Function(DownloadTask) _then) =
      _$DownloadTaskCopyWithImpl;
  @useResult
  $Res call(
      {String taskId,
      int movieId,
      String movieTitle,
      String torrentHash,
      String magnetUri,
      String quality,
      String? type,
      String size,
      double progress,
      DownloadStatus status,
      int downloadSpeed,
      int uploadSpeed,
      int peers,
      int seeders,
      int downloadedBytes,
      int totalBytes,
      String? filePath,
      String? errorMessage,
      DateTime? startedAt,
      DateTime? completedAt,
      String? coverImage});
}

/// @nodoc
class _$DownloadTaskCopyWithImpl<$Res> implements $DownloadTaskCopyWith<$Res> {
  _$DownloadTaskCopyWithImpl(this._self, this._then);

  final DownloadTask _self;
  final $Res Function(DownloadTask) _then;

  /// Create a copy of DownloadTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taskId = null,
    Object? movieId = null,
    Object? movieTitle = null,
    Object? torrentHash = null,
    Object? magnetUri = null,
    Object? quality = null,
    Object? type = freezed,
    Object? size = null,
    Object? progress = null,
    Object? status = null,
    Object? downloadSpeed = null,
    Object? uploadSpeed = null,
    Object? peers = null,
    Object? seeders = null,
    Object? downloadedBytes = null,
    Object? totalBytes = null,
    Object? filePath = freezed,
    Object? errorMessage = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? coverImage = freezed,
  }) {
    return _then(_self.copyWith(
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      movieId: null == movieId
          ? _self.movieId
          : movieId // ignore: cast_nullable_to_non_nullable
              as int,
      movieTitle: null == movieTitle
          ? _self.movieTitle
          : movieTitle // ignore: cast_nullable_to_non_nullable
              as String,
      torrentHash: null == torrentHash
          ? _self.torrentHash
          : torrentHash // ignore: cast_nullable_to_non_nullable
              as String,
      magnetUri: null == magnetUri
          ? _self.magnetUri
          : magnetUri // ignore: cast_nullable_to_non_nullable
              as String,
      quality: null == quality
          ? _self.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      size: null == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as DownloadStatus,
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
      filePath: freezed == filePath
          ? _self.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      startedAt: freezed == startedAt
          ? _self.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      coverImage: freezed == coverImage
          ? _self.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _DownloadTask extends DownloadTask {
  const _DownloadTask(
      {required this.taskId,
      required this.movieId,
      required this.movieTitle,
      required this.torrentHash,
      required this.magnetUri,
      required this.quality,
      this.type,
      required this.size,
      this.progress = 0.0,
      this.status = DownloadStatus.queued,
      this.downloadSpeed = 0,
      this.uploadSpeed = 0,
      this.peers = 0,
      this.seeders = 0,
      this.downloadedBytes = 0,
      this.totalBytes = 0,
      this.filePath,
      this.errorMessage,
      this.startedAt,
      this.completedAt,
      this.coverImage})
      : super._();
  factory _DownloadTask.fromJson(Map<String, dynamic> json) =>
      _$DownloadTaskFromJson(json);

  /// Unique task identifier
  @override
  final String taskId;

  /// Movie ID from YTS
  @override
  final int movieId;

  /// Movie title
  @override
  final String movieTitle;

  /// Torrent hash
  @override
  final String torrentHash;

  /// Torrent magnet link
  @override
  final String magnetUri;

  /// Quality (e.g., "720p", "1080p")
  @override
  final String quality;

  /// File type (e.g., "web", "bluray")
  @override
  final String? type;

  /// File size
  @override
  final String size;

  /// Download progress (0.0 to 1.0)
  @override
  @JsonKey()
  final double progress;

  /// Download status
  @override
  @JsonKey()
  final DownloadStatus status;

  /// Download speed in bytes per second
  @override
  @JsonKey()
  final int downloadSpeed;

  /// Upload speed in bytes per second
  @override
  @JsonKey()
  final int uploadSpeed;

  /// Number of peers
  @override
  @JsonKey()
  final int peers;

  /// Number of seeders
  @override
  @JsonKey()
  final int seeders;

  /// Downloaded bytes
  @override
  @JsonKey()
  final int downloadedBytes;

  /// Total bytes
  @override
  @JsonKey()
  final int totalBytes;

  /// File path where the download is saved
  @override
  final String? filePath;

  /// Error message if download failed
  @override
  final String? errorMessage;

  /// Time when download was started
  @override
  final DateTime? startedAt;

  /// Time when download was completed
  @override
  final DateTime? completedAt;

  /// Movie cover image URL
  @override
  final String? coverImage;

  /// Create a copy of DownloadTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DownloadTaskCopyWith<_DownloadTask> get copyWith =>
      __$DownloadTaskCopyWithImpl<_DownloadTask>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DownloadTaskToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DownloadTask &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.movieId, movieId) || other.movieId == movieId) &&
            (identical(other.movieTitle, movieTitle) ||
                other.movieTitle == movieTitle) &&
            (identical(other.torrentHash, torrentHash) ||
                other.torrentHash == torrentHash) &&
            (identical(other.magnetUri, magnetUri) ||
                other.magnetUri == magnetUri) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.status, status) || other.status == status) &&
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
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        taskId,
        movieId,
        movieTitle,
        torrentHash,
        magnetUri,
        quality,
        type,
        size,
        progress,
        status,
        downloadSpeed,
        uploadSpeed,
        peers,
        seeders,
        downloadedBytes,
        totalBytes,
        filePath,
        errorMessage,
        startedAt,
        completedAt,
        coverImage
      ]);

  @override
  String toString() {
    return 'DownloadTask(taskId: $taskId, movieId: $movieId, movieTitle: $movieTitle, torrentHash: $torrentHash, magnetUri: $magnetUri, quality: $quality, type: $type, size: $size, progress: $progress, status: $status, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed, peers: $peers, seeders: $seeders, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes, filePath: $filePath, errorMessage: $errorMessage, startedAt: $startedAt, completedAt: $completedAt, coverImage: $coverImage)';
  }
}

/// @nodoc
abstract mixin class _$DownloadTaskCopyWith<$Res>
    implements $DownloadTaskCopyWith<$Res> {
  factory _$DownloadTaskCopyWith(
          _DownloadTask value, $Res Function(_DownloadTask) _then) =
      __$DownloadTaskCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String taskId,
      int movieId,
      String movieTitle,
      String torrentHash,
      String magnetUri,
      String quality,
      String? type,
      String size,
      double progress,
      DownloadStatus status,
      int downloadSpeed,
      int uploadSpeed,
      int peers,
      int seeders,
      int downloadedBytes,
      int totalBytes,
      String? filePath,
      String? errorMessage,
      DateTime? startedAt,
      DateTime? completedAt,
      String? coverImage});
}

/// @nodoc
class __$DownloadTaskCopyWithImpl<$Res>
    implements _$DownloadTaskCopyWith<$Res> {
  __$DownloadTaskCopyWithImpl(this._self, this._then);

  final _DownloadTask _self;
  final $Res Function(_DownloadTask) _then;

  /// Create a copy of DownloadTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? taskId = null,
    Object? movieId = null,
    Object? movieTitle = null,
    Object? torrentHash = null,
    Object? magnetUri = null,
    Object? quality = null,
    Object? type = freezed,
    Object? size = null,
    Object? progress = null,
    Object? status = null,
    Object? downloadSpeed = null,
    Object? uploadSpeed = null,
    Object? peers = null,
    Object? seeders = null,
    Object? downloadedBytes = null,
    Object? totalBytes = null,
    Object? filePath = freezed,
    Object? errorMessage = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? coverImage = freezed,
  }) {
    return _then(_DownloadTask(
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      movieId: null == movieId
          ? _self.movieId
          : movieId // ignore: cast_nullable_to_non_nullable
              as int,
      movieTitle: null == movieTitle
          ? _self.movieTitle
          : movieTitle // ignore: cast_nullable_to_non_nullable
              as String,
      torrentHash: null == torrentHash
          ? _self.torrentHash
          : torrentHash // ignore: cast_nullable_to_non_nullable
              as String,
      magnetUri: null == magnetUri
          ? _self.magnetUri
          : magnetUri // ignore: cast_nullable_to_non_nullable
              as String,
      quality: null == quality
          ? _self.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      size: null == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as DownloadStatus,
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
      filePath: freezed == filePath
          ? _self.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      startedAt: freezed == startedAt
          ? _self.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      coverImage: freezed == coverImage
          ? _self.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
