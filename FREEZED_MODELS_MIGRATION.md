# Type-Safe Service Communication with Freezed Models

## Overview

This document describes the addition of type-safe communication between the UI and background service using Freezed models instead of raw `Map<String, dynamic>` objects.

## New Models Created

### File: `lib/src/models/torrent_service_models.dart`

#### 1. Request Models (UI → Background Service)

**StartDownloadRequest**

```dart
@freezed
class StartDownloadRequest with _$StartDownloadRequest {
  const factory StartDownloadRequest({
    required String taskId,
    required String magnetUri,
    required String savePath,
    required String movieTitle,
  }) = _StartDownloadRequest;
  
  factory StartDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$StartDownloadRequestFromJson(json);
}
```

**PauseDownloadRequest**

```dart
@freezed
class PauseDownloadRequest with _$PauseDownloadRequest {
  const factory PauseDownloadRequest({
    required String taskId,
  }) = _PauseDownloadRequest;
  
  factory PauseDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$PauseDownloadRequestFromJson(json);
}
```

**ResumeDownloadRequest**

```dart
@freezed
class ResumeDownloadRequest with _$ResumeDownloadRequest {
  const factory ResumeDownloadRequest({
    required String taskId,
  }) = _ResumeDownloadRequest;
  
  factory ResumeDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$ResumeDownloadRequestFromJson(json);
}
```

**StopDownloadRequest**

```dart
@freezed
class StopDownloadRequest with _$StopDownloadRequest {
  const factory StopDownloadRequest({
    required String taskId,
  }) = _StopDownloadRequest;
  
  factory StopDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$StopDownloadRequestFromJson(json);
}
```

#### 2. Response Model (Background Service → UI)

**ProgressUpdate**

```dart
@freezed
class ProgressUpdate with _$ProgressUpdate {
  const factory ProgressUpdate({
    required String taskId,
    required DownloadStatusType status,
    @Default(0.0) double progress,
    @Default(0) int downloadSpeed,
    @Default(0) int uploadSpeed,
    @Default(0) int peers,
    @Default(0) int seeders,
    @Default(0) int downloadedBytes,
    @Default(0) int totalBytes,
    String? error,
  }) = _ProgressUpdate;
  
  factory ProgressUpdate.fromJson(Map<String, dynamic> json) =>
      _$ProgressUpdateFromJson(json);
}
```

**DownloadStatusType Enum**

```dart
enum DownloadStatusType {
  @JsonValue('downloading_metadata')
  downloadingMetadata,
  @JsonValue('downloading')
  downloading,
  @JsonValue('paused')
  paused,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('stopped')
  stopped,
}
```

## Changes to Existing Files

### `lib/src/services/torrent_task_handler.dart`

#### Before (Map-based)

```dart
service.on('startDownload').listen((event) {
  if (event != null) {
    final data = event;
    final taskId = data['taskId'] as String?;
    final magnetUri = data['magnetUri'] as String?;
    final savePath = data['savePath'] as String?;
    final movieTitle = data['movieTitle'] as String?;
    
    if (taskId != null && magnetUri != null && savePath != null) {
      handler._startDownload(
        taskId,
        magnetUri,
        savePath,
        movieTitle ?? 'Unknown',
      );
    }
  }
});
```

#### After (Model-based)

```dart
service.on('startDownload').listen((event) {
  if (event != null) {
    try {
      final request = StartDownloadRequest.fromJson(event);
      handler._startDownload(
        request.taskId,
        request.magnetUri,
        request.savePath,
        request.movieTitle,
      );
    } catch (e) {
      log('Error parsing startDownload event: $e');
    }
  }
});
```

#### Progress Update - Before

```dart
void _sendProgressUpdate(String taskId, Map<String, dynamic> data) {
  service.invoke(
    'progressUpdate',
    {
      'taskId': taskId,
      ...data,
    },
  );
}

// Usage
_sendProgressUpdate(taskId, {
  'status': 'downloading',
  'progress': progress,
  'downloadSpeed': downloadSpeed,
  'uploadSpeed': uploadSpeed,
  'peers': peers,
  'seeders': seeders,
  'downloadedBytes': downloaded.toInt(),
  'totalBytes': totalBytes,
});
```

#### Progress Update - After

```dart
void _sendProgressUpdate(ProgressUpdate update) {
  service.invoke(
    'progressUpdate',
    update.toJson(),
  );
}

// Usage
_sendProgressUpdate(
  ProgressUpdate(
    taskId: taskId,
    status: DownloadStatusType.downloading,
    progress: progress,
    downloadSpeed: downloadSpeed,
    uploadSpeed: uploadSpeed,
    peers: peers,
    seeders: seeders,
    downloadedBytes: downloaded.toInt(),
    totalBytes: totalBytes,
  ),
);
```

### `lib/src/services/foreground_download_service.dart`

#### Sending Requests - Before

```dart
service.invoke(
  'startDownload',
  {
    'taskId': taskId,
    'magnetUri': magnetUri,
    'savePath': savePath,
    'movieTitle': movieTitle,
  },
);
```

#### Sending Requests - After

```dart
service.invoke(
  'startDownload',
  StartDownloadRequest(
    taskId: taskId,
    magnetUri: magnetUri,
    savePath: savePath,
    movieTitle: movieTitle,
  ).toJson(),
);
```

#### Receiving Updates - Before

```dart
service.on('progressUpdate').listen((event) {
  if (event != null) {
    _progressController.add(event);
  }
});
```

#### Receiving Updates - After

```dart
service.on('progressUpdate').listen((event) {
  if (event != null) {
    try {
      final update = ProgressUpdate.fromJson(event);
      _progressController.add(update.toJson());
    } catch (e) {
      log('Error parsing progress update: $e');
    }
  }
});
```

## Benefits

### 1. **Type Safety**

- Compile-time checking of field names and types
- No more typos like `'taskId'` vs `'task_id'`
- IDE autocomplete for all fields

### 2. **Better Error Handling**

- JSON parsing errors are caught with try-catch
- Clear error messages when data format is incorrect
- Easier debugging of communication issues

### 3. **Code Maintainability**

- Models are self-documenting
- Single source of truth for data structure
- Easy to refactor - change model and compiler finds all usages

### 4. **Validation**

- Required fields enforced at compile time
- Default values handled consistently
- Null safety built in

### 5. **Generated Code**

- `toJson()` and `fromJson()` methods auto-generated
- `copyWith()` method for easy updates
- Equality and hashCode implemented correctly

## Generated Files

The following files are auto-generated by `build_runner`:

- `lib/src/models/torrent_service_models.freezed.dart` - Freezed implementation
- `lib/src/models/torrent_service_models.g.dart` - JSON serialization

These are regenerated by running:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Migration Notes

### All Progress Updates Now Use ProgressUpdate Model

Every `_sendProgressUpdate` call now creates a `ProgressUpdate` object:

```dart
// Failed download
_sendProgressUpdate(
  ProgressUpdate(
    taskId: taskId,
    status: DownloadStatusType.failed,
    error: 'Invalid magnet URI',
  ),
);

// Paused download
_sendProgressUpdate(
  ProgressUpdate(
    taskId: taskId,
    status: DownloadStatusType.paused,
  ),
);

// Completed download
_sendProgressUpdate(
  ProgressUpdate(
    taskId: taskId,
    status: DownloadStatusType.completed,
    progress: 1.0,
    downloadedBytes: downloaded.toInt(),
    totalBytes: totalBytes,
  ),
);
```

### Error Handling

All event parsing is wrapped in try-catch blocks to gracefully handle malformed data:

```dart
try {
  final request = StartDownloadRequest.fromJson(event);
  // Use request...
} catch (e) {
  log('Error parsing event: $e');
}
```

## Testing Considerations

1. **Serialization Testing**: Ensure models serialize/deserialize correctly
2. **Backward Compatibility**: Old JSON format should still work (if needed)
3. **Error Cases**: Test with invalid/missing fields
4. **Performance**: Serialization adds minimal overhead

## Future Improvements

1. **Add validation**: Use `@Assert` annotations for field validation
2. **Add custom converters**: For special types (DateTime, etc.)
3. **Union types**: Use Freezed unions for different status types
4. **Immutability**: Leverage Freezed's immutability for safer code
