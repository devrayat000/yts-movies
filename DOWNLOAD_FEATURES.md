# Torrent Download Features

## Overview

This app now supports in-app torrent downloading using the `dtorrent_task_v2` package. Users can download movies directly within the app and manage their downloads.

## Features Implemented

### 1. **Download Manager**

- Real-time download progress tracking
- Multiple concurrent downloads support
- Download lifecycle management (start, pause, resume, stop, delete)
- Persistent download state (survives app restarts)
- Organized download list (active, completed, paused, failed)

### 2. **Permission Handling**

- **Android:**
  - Android 13+ (API 33+): Uses `READ_MEDIA_VIDEO` permission
  - Android 11-12 (API 30-32): Uses `MANAGE_EXTERNAL_STORAGE` permission
  - Android 10 and below: Uses `READ_EXTERNAL_STORAGE` and `WRITE_EXTERNAL_STORAGE` permissions
  - Legacy storage support enabled for older devices
  
- **iOS:**
  - Photo library access permissions
  - File sharing enabled
  - Document opening support

### 3. **Custom Download Location**

- Users can select custom download directories using the file picker
- Download location is persisted across app sessions
- Default location: App's private documents directory
- Reset to default option available

### 4. **User Interface**

#### Downloads Page (`/downloads`)

- View all downloads organized by status
- Real-time progress updates with speed and peer information
- Download actions: pause, resume, stop, delete
- Clear completed downloads option
- Settings button to access download configuration

#### Download Settings Page

- View current download location
- Change download location with file picker
- Reset to default location
- Visual indicator for custom paths
- Information about download behavior
- Direct access to app settings for permissions

#### Download Dialog (Enhanced)

- Shows current download location
- Displays quality and size information
- Quick access to download settings
- Options:
  - **Download in App**: Start in-app torrent download
  - **Open External**: Launch system torrent client
  
## Usage

### Starting a Download

1. Browse to a movie details page
2. Tap on a quality button (e.g., "720p", "1080p")
3. Choose download method in the dialog:
   - **Download**: Starts in-app download
   - **Open External**: Opens with system torrent client
4. View progress in the Downloads page

### Changing Download Location

1. Navigate to Downloads page
2. Tap the settings icon (⚙️) in the app bar
3. Tap "Change Location"
4. Grant storage permissions if prompted
5. Select desired directory
6. Downloads will now be saved to the selected location

### Managing Downloads

- **Pause**: Temporarily stop a download (can be resumed later)
- **Resume**: Continue a paused download
- **Stop**: Cancel a download completely (removes partial files)
- **Delete**: Remove a completed download from the list

### Permissions

If permissions are denied:

1. Tap "Storage Permissions" → "Manage" in Download Settings
2. Grant required permissions in app settings
3. Return to the app and try again

## Technical Details

### Services

- **TorrentDownloadService**: Manages torrent operations using dtorrent_task_v2
- **PreferencesService**: Stores user preferences including download path
- **DownloadManagerBloc**: State management for downloads with persistence

### Models

- **DownloadTask**: Immutable model representing a download with all metadata
- **DownloadStatus**: Enum (downloading, completed, paused, failed, stopped)

### Storage

- Download state persisted using HydratedBloc
- User preferences stored using Hive
- Torrent data stored in selected download directory

## Limitations & Notes

- Active downloads continue to their original location if path is changed mid-download
- Requires sufficient storage space in selected directory
- Permission requirements vary by Android version
- Custom paths on Android 11+ require MANAGE_EXTERNAL_STORAGE permission

## Future Enhancements

- Batch download operations
- Download speed limits
- Scheduled downloads
- Download notifications
- Seed after download completion
- Search within downloads
