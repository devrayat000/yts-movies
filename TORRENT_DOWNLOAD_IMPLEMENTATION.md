# Torrent Download Feature Implementation

## Overview

This implementation adds in-app torrent downloading functionality to the YTS Movies Flutter app using the `dtorrent_task_v2` package. Users can now download movies directly within the app and track download progress.

## Features Implemented

### 1. **Torrent Download Service** (`lib/src/services/torrent_download_service.dart`)

- Singleton service for managing torrent downloads
- Handles torrent task lifecycle (start, pause, resume, stop, delete)
- Provides real-time progress updates via streams
- Manages download and configuration paths
- Uses `dtorrent_task_v2` for torrent protocol implementation

### 2. **Download Task Model** (`lib/src/models/download_task.dart`)

- Freezed model with JSON serialization
- Tracks download metadata:
  - Movie information (title, ID, cover image)
  - Torrent details (hash, magnet URI, quality, type)
  - Progress metrics (downloaded bytes, speed, peers, seeders)
  - Download status (queued, downloading, paused, completed, failed, stopped)
  - Timestamps (started, completed)
- Helper methods for formatted output (percentage, speeds, sizes)
- Status checking methods (isActive, canResume, canPause)

### 3. **Download Manager BLoC** (`lib/src/bloc/download_manager/`)

- State management using `HydratedBloc` for persistence
- Events:
  - `DownloadManagerStarted`: Initialize and subscribe to progress
  - `DownloadManagerAddDownload`: Start a new download
  - `DownloadManagerPauseDownload`: Pause active download
  - `DownloadManagerResumeDownload`: Resume paused download
  - `DownloadManagerStopDownload`: Stop download
  - `DownloadManagerDeleteDownload`: Delete download and files
  - `DownloadManagerUpdateProgress`: Update task progress
  - `DownloadManagerClearCompleted`: Remove completed downloads
- State:
  - Map of all downloads indexed by task ID
  - Computed lists for different download states
  - JSON serialization for state persistence

### 4. **Downloads Page UI** (`lib/src/pages/downloads.dart`)

- Displays all downloads organized by status:
  - Active downloads (downloading/queued)
  - Paused downloads
  - Completed downloads
  - Failed downloads
- Real-time progress indicators with:
  - Progress bar
  - Download/upload speeds
  - Peer and seeder counts
  - Downloaded vs total size
- Action menu for each download (pause, resume, stop, delete)
- Empty state for no downloads
- "Clear completed" action in app bar

### 5. **Enhanced Download Button** (`lib/src/widgets/buttons/download_button.dart`)

- Dialog to choose download method:
  - **Download in App**: Uses internal torrent client
  - **Open with Torrent Client**: Opens external torrent app
- Internal download:
  - Checks for duplicate downloads
  - Creates download task with movie context
  - Adds to download manager
  - Shows snackbar with "View" action to navigate to downloads
- External download:
  - Falls back to magnet URI launch (existing behavior)

### 6. **Navigation Integration**

- **Router** (`lib/src/router.dart`):
  - Added `/home/downloads` route
- **App Bar** (`lib/src/widgets/appbars/home_appbar.dart`):
  - Added "Downloads" icon button in app bar
  - Positioned between "Favourites" and "App Info"
- **Movie Page** (`lib/src/pages/movie.dart`):
  - Passes movie object to DownloadButton for full context

### 7. **App Initialization** (`lib/src/app_initializer.dart`)

- Converted to StatefulWidget for async initialization
- Initializes `TorrentDownloadService` on app startup
- Provides `DownloadManagerBloc` to entire app
- Shows loading indicator during initialization
- Handles initialization errors gracefully

## Architecture

```
User Interface
    ↓
Download Button → Dialog (Choose Method)
    ↓                       ↓
Internal Download      External Launch
    ↓
DownloadManagerBloc
    ↓
TorrentDownloadService
    ↓
dtorrent_task_v2 Package
    ↓
Progress Updates → Stream
    ↓
DownloadManagerBloc → State Update
    ↓
Downloads Page UI (Real-time Updates)
```

## Data Flow

1. **Starting a Download**:
   - User taps download button on movie page
   - Dialog appears to choose download method
   - If "Download in App" selected:
     - Create `DownloadTask` with movie/torrent info
     - Dispatch `DownloadManagerAddDownload` event
     - BLoC adds task to state
     - BLoC calls `TorrentDownloadService.startDownload()`
     - Service parses magnet URI using `dtorrent_parser`
     - Service creates `TorrentTask` and starts download
     - Service begins periodic progress polling

2. **Progress Updates**:
   - Service polls torrent task every second
   - Extracts progress metrics (speed, peers, bytes, etc.)
   - Emits updated `DownloadTask` to stream
   - BLoC listens to stream
   - BLoC dispatches `DownloadManagerUpdateProgress` event
   - State updates with new progress
   - UI rebuilds automatically via `BlocBuilder`

3. **State Persistence**:
   - `HydratedBloc` automatically persists state to disk
   - On app restart, downloads state is restored
   - Active downloads can be resumed from paused state

## Key Dependencies

- **dtorrent_task_v2** (^0.4.4): Core torrent downloading functionality
- **dtorrent_parser** (^1.0.8): Parses torrent files and magnet URIs
- **flutter_bloc** (^9.1.1): State management
- **hydrated_bloc** (^10.0.0): State persistence
- **freezed** (^3.0.6): Immutable models
- **go_router** (^15.1.2): Navigation

## File Structure

```
lib/
├── src/
│   ├── bloc/
│   │   └── download_manager/
│   │       ├── download_manager_bloc.dart
│   │       ├── download_manager_event.dart
│   │       ├── download_manager_state.dart
│   │       └── index.dart
│   ├── models/
│   │   ├── download_task.dart
│   │   ├── download_task.freezed.dart
│   │   └── download_task.g.dart
│   ├── pages/
│   │   └── downloads.dart
│   ├── services/
│   │   └── torrent_download_service.dart
│   ├── widgets/
│   │   ├── buttons/
│   │   │   └── download_button.dart (updated)
│   │   └── appbars/
│   │       └── home_appbar.dart (updated)
│   ├── app_initializer.dart (updated)
│   └── router.dart (updated)
```

## Usage

### For Users

1. **Starting a Download**:
   - Navigate to a movie details page
   - Tap any download button (quality option)
   - Choose "Download in App" from the dialog
   - Download starts and notification appears
   - Tap "View" in notification or the downloads icon in app bar

2. **Managing Downloads**:
   - Open Downloads page from app bar icon
   - View all downloads organized by status
   - Tap ⋮ menu on any download to:
     - Pause active downloads
     - Resume paused downloads
     - Stop downloads
     - Delete downloads (with confirmation)
   - Tap "Clear completed" in app bar to remove all completed downloads

3. **Monitoring Progress**:
   - See real-time progress bars
   - View download/upload speeds
   - Check peer and seeder counts
   - Monitor downloaded vs total size

### For Developers

#### Adding a Download Programmatically

```dart
// Get the download manager
final downloadManager = context.read<DownloadManagerBloc>();

// Create a task
final task = DownloadTask(
  taskId: '${movie.id}_${torrent.hash}',
  movieId: movie.id,
  movieTitle: movie.title,
  torrentHash: torrent.hash,
  magnetUri: torrent.magnet(movie.title).toString(),
  quality: torrent.quality,
  type: torrent.type,
  size: torrent.size,
  coverImage: movie.mediumCoverImage,
);

// Start the download
downloadManager.add(DownloadManagerAddDownload(
  task: task,
  movie: movie,
  torrent: torrent,
));
```

#### Listening to Download Progress

```dart
// In a widget
BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
  builder: (context, state) {
    final activeDownloads = state.activeDownloads;
    // Build UI with active downloads
    return ListView.builder(
      itemCount: activeDownloads.length,
      itemBuilder: (context, index) {
        final task = activeDownloads[index];
        return ListTile(
          title: Text(task.movieTitle),
          subtitle: Text(task.progressPercentage),
        );
      },
    );
  },
)
```

#### Accessing the Service Directly

```dart
// Get the service instance
final service = TorrentDownloadService.instance;

// Check if a task is active
if (service.isTaskActive(taskId)) {
  // Task is downloading
}

// Get download path
final path = service.downloadPath;
```

## Configuration

### Download Location

Downloads are saved to: `{ApplicationDocumentsDirectory}/downloads`

### Configuration Files

Torrent configuration is stored in: `{ApplicationDocumentsDirectory}/torrent_config`

### State Persistence

Download state is persisted using HydratedBloc in the app's storage directory.

## Future Enhancements

1. **Download Queue Management**:
   - Limit concurrent downloads
   - Priority queue system
   - Auto-start queued downloads

2. **File Management**:
   - Open downloaded files
   - Share completed downloads
   - Move files to custom locations
   - Disk space monitoring

3. **Advanced Features**:
   - Sequential/ordered downloading (for streaming while downloading)
   - Bandwidth limits (up/down)
   - Download scheduling
   - WiFi-only option
   - Battery optimization settings

4. **UI Improvements**:
   - Download notifications with progress
   - Background download support
   - Batch operations (pause all, resume all)
   - Search and filter in downloads list

5. **Analytics**:
   - Download statistics
   - Speed graphs
   - Historical data
   - Storage usage tracking

## Troubleshooting

### Downloads Not Starting

- Check internet connectivity
- Verify sufficient storage space
- Ensure torrent has available peers/seeders

### Slow Download Speeds

- Check number of connected peers
- Verify internet connection speed
- Some torrents may have limited seeders

### App Crashes on Download

- Check device storage
- Verify permissions (if required)
- Check logs for specific error messages

## Notes

- The implementation uses in-memory task tracking, so active downloads will be lost if the app is killed (state is preserved but dtorrent tasks need to be recreated)
- Completed downloads are persisted and survive app restarts
- The service is initialized as a singleton and disposed when the app closes
- Progress updates occur every second while downloads are active

## Credits

Built using:

- [dtorrent_task_v2](https://pub.dev/packages/dtorrent_task_v2) by [the package author]
- [dtorrent_parser](https://pub.dev/packages/dtorrent_parser)
- YTS API for movie and torrent metadata
