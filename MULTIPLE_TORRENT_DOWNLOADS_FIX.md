# Multiple Torrent Downloads Implementation Guide

## Problem Analysis

The current implementation in `torrent_task_handler.dart` and `foreground_download_service.dart` is designed to handle multiple concurrent downloads using a `Map<int, TorrentTask>` structure. However, only the first task is being downloaded while subsequent tasks are not starting properly.

## Root Causes

After analyzing the code, here are the potential root causes:

### 1. **Foreground Service Notification Limitation**
- **Issue**: Android foreground services typically require a single persistent notification (with ID `888` defined as `notificationId`)
- **Current Implementation**: Each task creates its own notification using `taskId` as the notification ID
- **Problem**: Multiple notifications might conflict with the foreground service requirement, or the system might be canceling them

### 2. **Resource Contention in dtorrent_task_v2**
- **Issue**: The `dtorrent_task_v2` library may have internal limitations on concurrent downloads
- **Possible Problems**:
  - Shared DHT (Distributed Hash Table) nodes
  - Port binding conflicts (all tasks might try to use the same ports)
  - Shared peer connection pool limits
  - Global bandwidth throttling

### 3. **Metadata Downloader Blocking**
- **Issue**: The `MetadataDownloader` instances might be blocking each other
- **Current Flow**: Each download starts with metadata download → then actual torrent download
- **Problem**: If metadata downloads are sequential or share resources, subsequent tasks will queue up

### 4. **Event Listener Interference**
- **Issue**: The event listeners might not be properly isolated between tasks
- **Problem**: Events from one task might affect others or get mixed up

### 5. **Service Isolate Limitations**
- **Issue**: The background service runs in a separate isolate
- **Problem**: Heavy computation or blocking operations in one task might block the isolate thread

## Detailed Implementation Guidelines

### Solution 1: Fix Foreground Service Notification Strategy

#### Problem Details
Android foreground services require ONE persistent notification to keep the service alive. Creating multiple notifications per task conflicts with this requirement.

#### Implementation Steps

1. **Keep Single Foreground Service Notification**
   - Use notification ID `888` (the constant `notificationId`) ONLY for the foreground service
   - This notification should show overall download status
   - Never cancel or modify this notification while downloads are active

2. **Create Task-Specific Notifications Separately**
   - Use unique notification IDs for each task: `taskId + 1000` (to avoid collision with service notification)
   - These notifications are informational only, not tied to foreground service
   - Make them cancellable and updatable independently

3. **Implement Aggregated Status Notification**
   ```
   Title: "YTS Movies - Downloads"
   Body: "3 active downloads • 45% average progress"
   - Movie 1: 67%
   - Movie 2: 34%
   - Movie 3: 12%
   ```

4. **Code Changes Needed in `torrent_task_handler.dart`**:
   - Modify `_showNotification()` to accept a `isForegroundServiceNotification` parameter
   - Keep notification ID `888` for service, use `taskId + 1000` for individual tasks
   - Add `_updateServiceNotification()` method for the main persistent notification
   - Add `_updateTaskNotification()` method for individual task notifications
   - Update notification in `_startProgressMonitoring()` to use task-specific IDs

### Solution 2: Implement Task Queuing System

#### Problem Details
The current implementation tries to start all tasks immediately, which may overwhelm the torrent library or system resources.

#### Implementation Steps

1. **Add Task Queue Management**
   - Create `_taskQueue` list to hold pending downloads
   - Create `_activeTasksLimit` constant (start with 2-3 concurrent downloads)
   - Add `_pendingTasks` map to track queued tasks

2. **Implement Queue Logic**
   ```
   Flow:
   1. When startDownload() is called:
      - Add task to queue
      - Check if we can start it immediately (under limit)
      - If yes: start download
      - If no: keep in pending queue
   
   2. When a task completes/stops:
      - Remove from active tasks
      - Check pending queue
      - Start next task from queue
   ```

3. **Add Status Tracking**
   - Add `DownloadStatus.queued` state
   - Send progress updates when task moves from queued → downloading
   - Show queue position in notifications: "Queued (2 ahead)"

4. **Configuration Options**
   - Allow users to configure max concurrent downloads
   - Store in `PreferencesService`
   - Default: 2 concurrent downloads (safe for most devices)

### Solution 3: Ensure Proper Port and Resource Isolation

#### Problem Details
Multiple TorrentTask instances might be competing for the same network ports or DHT resources.

#### Implementation Steps

1. **Configure Unique Ports for Each Task**
   - The `TorrentTask.newTask()` constructor might need port configuration
   - Assign port range: Base port (e.g., 6881) + taskId offset
   - Example: Task 1 uses 6881, Task 2 uses 6882, etc.

2. **Check dtorrent_task_v2 Documentation**
   - Review library documentation for concurrent download support
   - Check if there are any initialization parameters for:
     - Port ranges
     - Connection limits per task
     - DHT configuration
     - Bandwidth allocation

3. **Add Resource Initialization**
   ```
   Steps to add in startDownload():
   1. Calculate port: basePort = 6881 + (taskId % 100)
   2. Pass configuration to TorrentTask.newTask():
      - listening port
      - max connections per task
      - bandwidth limits per task
   ```

4. **Implement Resource Cleanup**
   - Ensure ports are released when task stops
   - Clear DHT nodes associated with task
   - Close all peer connections properly

### Solution 4: Add Comprehensive Logging and Debugging

#### Problem Details
Currently, it's difficult to diagnose why subsequent tasks aren't downloading.

#### Implementation Steps

1. **Add Detailed State Logging**
   ```
   Log at these points:
   - Task received: "=== Task X received in background service ==="
   - Task starting: "=== Starting task X, current active: Y ==="
   - Metadata download: "=== Task X metadata progress: N% ==="
   - Torrent creation: "=== Task X TorrentTask created ==="
   - Task started: "=== Task X actively downloading ==="
   - State updates: "=== Task X progress: N%, peers: M ==="
   ```

2. **Log Task State Transitions**
   ```
   Track and log:
   - _tasks map size before/after operations
   - _metadataDownloaders map size
   - _taskListeners map size
   - Active task count
   - Queued task count
   ```

3. **Add Performance Metrics**
   ```
   Log every 10 seconds:
   - Total active tasks
   - Per-task download speed
   - Per-task peer count
   - Memory usage (if possible)
   - CPU usage per task
   ```

4. **Implement Debug Mode**
   - Add `debugMode` flag in PreferencesService
   - When enabled, log everything
   - When disabled, log only errors and major events
   - Add log export functionality for troubleshooting

### Solution 5: Handle Metadata Download Concurrency

#### Problem Details
The `MetadataDownloader` might not support concurrent operations or might share resources.

#### Implementation Steps

1. **Sequential Metadata Downloads**
   - Create `_metadataQueue` for pending metadata downloads
   - Download metadata one at a time
   - Once metadata is complete, start the actual torrent download
   - This allows torrent downloads to be concurrent while metadata is sequential

2. **Implementation Flow**
   ```
   1. startDownload() called for Task 1:
      - Add to _metadataQueue
      - Start metadata download immediately
   
   2. startDownload() called for Task 2 (while Task 1 metadata downloading):
      - Add to _metadataQueue
      - Wait for Task 1 metadata to complete
   
   3. Task 1 metadata completes:
      - Start Task 1 torrent download
      - Check _metadataQueue
      - Start Task 2 metadata download
   
   4. Task 2 metadata completes:
      - Start Task 2 torrent download
      - Now both Task 1 and Task 2 are downloading concurrently
   ```

3. **Add Metadata Queue Manager**
   ```
   Create _MetadataQueueManager:
   - Tracks current metadata download
   - Maintains queue of pending metadata downloads
   - Automatically starts next when current completes
   - Timeout handling for stuck metadata downloads
   ```

### Solution 6: Optimize Event Listener Management

#### Problem Details
Event listeners might be causing overhead or conflicts between tasks.

#### Implementation Steps

1. **Reduce Listener Update Frequency**
   - Current: Every `StateFileUpdated` event triggers updates
   - Problem: This might fire too frequently with multiple tasks
   - Solution: Throttle updates to once per second per task
   - Implementation: Use `Timer` or `debounce` logic

2. **Batch Progress Updates**
   ```
   Instead of sending update per event:
   1. Collect progress data in memory
   2. Send batched update every 2-3 seconds
   3. Reduces service.invoke() calls
   4. Reduces UI updates
   ```

3. **Optimize Notification Updates**
   - Don't update notification on every progress event
   - Update only if progress changed by >1%
   - Update every 5 seconds at most per task
   - Reduces system overhead

### Solution 7: Implement Proper Task Lifecycle Management

#### Problem Details
Tasks might not be properly initialized or cleaned up, causing resource leaks.

#### Implementation Steps

1. **Add Task State Machine**
   ```
   States:
   - Initializing: Task received, preparing
   - DownloadingMetadata: Getting torrent metadata
   - Starting: Creating TorrentTask instance
   - Downloading: Actively downloading
   - Paused: Temporarily stopped
   - Stopped: Permanently stopped
   - Completed: Download finished
   - Failed: Error occurred
   ```

2. **Track Task States**
   ```
   Add to _TorrentTaskHandler:
   - Map<int, TaskState> _taskStates
   - Update state on every transition
   - Send state updates to UI
   - Log state transitions
   ```

3. **Validate State Transitions**
   ```
   Before starting a task:
   1. Check if task already exists
   2. Check current state
   3. Validate transition is allowed
   4. If invalid, send error to UI
   ```

4. **Implement Proper Cleanup**
   ```
   On task stop/complete:
   1. Dispose event listener
   2. Stop TorrentTask
   3. Remove from _tasks map
   4. Remove from _taskListeners map
   5. Clear task state
   6. Cancel notification
   7. Release any held resources
   ```

## Testing Strategy

### Phase 1: Add Logging
1. Add comprehensive logging as described in Solution 4
2. Test with 2 downloads
3. Review logs to identify exact point where second task fails/stalls
4. This will pinpoint the actual issue

### Phase 2: Implement Based on Findings
Based on log analysis, implement solutions in this priority:

**If logs show second task never starts downloading:**
- Implement Solution 1 (Notification fix) first
- Then Solution 3 (Resource isolation)

**If logs show second task starts but stalls:**
- Implement Solution 2 (Task queuing)
- Then Solution 5 (Metadata concurrency)

**If logs show both tasks start but perform poorly:**
- Implement Solution 6 (Optimize listeners)
- Then Solution 2 (Task queuing with limits)

### Phase 3: Incremental Testing
1. Test with 2 concurrent downloads
2. If successful, test with 3 downloads
3. Gradually increase to find optimal concurrent limit
4. Set default limit to safe value (2-3)

## Recommended Implementation Order

1. **Start with Logging (Solution 4)** - Critical for diagnosis
2. **Fix Notifications (Solution 1)** - Likely main issue
3. **Add Resource Isolation (Solution 3)** - Ensure tasks don't conflict
4. **Implement Task Queuing (Solution 2)** - Manage concurrency properly
5. **Handle Metadata Concurrency (Solution 5)** - If still issues
6. **Optimize Performance (Solution 6)** - Polish and improve
7. **Add Lifecycle Management (Solution 7)** - Long-term stability

## Configuration Recommendations

### User-Configurable Settings (via PreferencesService)

```dart
// Add these to PreferencesService:

// Maximum concurrent downloads (default: 2)
int maxConcurrentDownloads = 2;

// Maximum concurrent metadata downloads (default: 1)
int maxConcurrentMetadataDownloads = 1;

// Update notification frequency in seconds (default: 3)
int notificationUpdateInterval = 3;

// Progress update frequency in seconds (default: 2)
int progressUpdateInterval = 2;

// Enable debug logging (default: false)
bool debugLogging = false;

// Base port for torrent tasks (default: 6881)
int baseTorrentPort = 6881;

// Max connections per task (default: 50)
int maxConnectionsPerTask = 50;
```

## Expected Behavior After Implementation

1. **Multiple Tasks Can Start**: All queued tasks will start up to the concurrent limit
2. **Independent Progress**: Each task progresses independently with its own notification
3. **Proper Queuing**: Tasks beyond the limit wait in queue and start when slots open
4. **Resource Isolation**: Each task uses separate ports and doesn't interfere with others
5. **Clean UI Updates**: Each task sends its own progress updates without conflicts
6. **Stable Performance**: System resources are properly managed and released

## Monitoring and Maintenance

### Key Metrics to Monitor
- Task start success rate
- Average time from queue to active
- Memory usage with multiple tasks
- Network bandwidth distribution across tasks
- Task completion rate
- Error rate per task

### Common Issues to Watch For
- Port conflicts (if using same ports)
- Memory leaks (tasks not cleaned up)
- Notification spam (too frequent updates)
- DHT node exhaustion
- Peer connection limits
- Bandwidth starvation (one task using all bandwidth)

## Additional Considerations

### Android Foreground Service Best Practices
- Keep ONE persistent notification for the service
- Update it to show aggregate status
- Use separate notifications for task details
- Handle service stop properly when all tasks complete
- Request battery optimization exemption for better performance

### dtorrent_task_v2 Library Specifics
- Review the library's GitHub issues for concurrent download problems
- Check if there's a way to initialize separate DHT instances
- Verify port configuration options
- Look for any global state that might cause conflicts
- Consider creating separate isolates for each task if library has limitations

### Performance Optimization
- Limit total peer connections across all tasks
- Implement smart bandwidth allocation
- Prioritize tasks based on user preference
- Implement download scheduling (download during off-peak hours)
- Cache frequently accessed data to reduce overhead

## Conclusion

The most likely causes of the issue are:

1. **Notification conflicts** (Solution 1) - Most probable
2. **Resource/port conflicts** (Solution 3) - Very likely
3. **Missing concurrency management** (Solution 2) - Good practice

Start with comprehensive logging to diagnose the exact issue, then implement the notification fix and resource isolation. The queuing system should be added for better long-term stability even if it's not the root cause.

This implementation will require careful testing at each stage to ensure stability and performance with multiple concurrent downloads.
