import 'dart:async';
import 'dart:developer';

/// Manages a sequential download queue where only one download runs at a time
class SequentialDownloadQueue {
  /// Currently active task ID
  int? _activeTaskId;

  /// Queue of pending task IDs
  final List<int> _pendingTasks = [];

  /// Task titles for logging
  final Map<int, String> _taskTitles = {};

  /// Callback to actually start a download
  Future<void> Function(int taskId)? _startDownloadCallback;

  /// Whether we're currently processing
  bool _isProcessing = false;

  /// Set the callback function that will be called to start a download
  void setStartCallback(Future<void> Function(int taskId) callback) {
    _startDownloadCallback = callback;
  }

  /// Add a task to the queue
  /// Returns true if task was added to queue, false if it started immediately
  bool addTask(int taskId, String title) {
    _taskTitles[taskId] = title;

    log('=== SequentialDownloadQueue: All tasks $_pendingTasks ===');

    if (_activeTaskId == null) {
      // No active download, start immediately
      _activeTaskId = taskId;
      log('=== SequentialDownloadQueue: Starting task $taskId immediately ===');
      log('Title: $title');
      _startActiveTask();
      return false; // Started immediately
    } else {
      // Add to queue
      if (!_pendingTasks.contains(taskId)) {
        _pendingTasks.add(taskId);
        log('=== SequentialDownloadQueue: Added task $taskId to queue ===');
        log('Title: $title');
        log('Queue position: ${_pendingTasks.length}');
        log('Active task: $_activeTaskId (${_taskTitles[_activeTaskId]})');
      }
      return true; // Added to queue
    }
  }

  /// Mark the current download as complete and start the next one
  void markCurrentComplete(int taskId) {
    log('=== SequentialDownloadQueue: Marking task $taskId as complete ===');

    if (_activeTaskId == taskId) {
      _activeTaskId = null;
      _taskTitles.remove(taskId);
      log('Active task cleared');
      _processNext();
    } else if (_pendingTasks.contains(taskId)) {
      // Task was in queue but never started
      _pendingTasks.remove(taskId);
      _taskTitles.remove(taskId);
      log('Removed task from queue (never started)');
    }
  }

  /// Remove a task from the queue (if it's waiting)
  void removeTask(int taskId) {
    if (_pendingTasks.contains(taskId)) {
      _pendingTasks.remove(taskId);
      _taskTitles.remove(taskId);
      log('=== SequentialDownloadQueue: Removed task $taskId from queue ===');
    }
  }

  /// Process the next task in the queue
  void _processNext() {
    // Prevent multiple simultaneous calls to _processNext
    if (_isProcessing) {
      log('Already processing, skipping _processNext');
      return;
    }

    _isProcessing = true;

    try {
      if (_activeTaskId != null) {
        log('Active task still running: $_activeTaskId, not starting next');
        return;
      }

      if (_pendingTasks.isEmpty) {
        log('=== SequentialDownloadQueue: Queue is empty ===');
        return;
      }

      // Get next task
      final nextTaskId = _pendingTasks.removeAt(0);
      _activeTaskId = nextTaskId;

      log('=== SequentialDownloadQueue: Starting next task from queue ===');
      log('Task ID: $nextTaskId');
      log('Title: ${_taskTitles[nextTaskId]}');
      log('Remaining in queue: ${_pendingTasks.length}');

      _startActiveTask();
    } finally {
      _isProcessing = false;
    }
  }

  void _startActiveTask() {
    final taskId = _activeTaskId;
    if (taskId == null) {
      log('No active task to start');
      return;
    }

    if (_startDownloadCallback == null) {
      log('Start callback not set; cannot start task $taskId');
      return;
    }

    _startDownloadCallback!(taskId).catchError((e, s) {
      log('Error starting download $taskId: $e', error: e, stackTrace: s);
      // Clear active task on error so queue can proceed
      if (_activeTaskId == taskId) {
        _activeTaskId = null;
        _processNext();
      }
    });
  }

  /// Get current queue status
  Map<String, dynamic> getStats() {
    return {
      'activeTaskId': _activeTaskId,
      'activeTaskTitle':
          _activeTaskId != null ? _taskTitles[_activeTaskId] : null,
      'pendingCount': _pendingTasks.length,
      'pendingTaskIds': List.from(_pendingTasks),
    };
  }

  /// Get queue position for a task (0 if active, 1+ if in queue, -1 if not found)
  int getQueuePosition(int taskId) {
    if (_activeTaskId == taskId) return 0;
    final index = _pendingTasks.indexOf(taskId);
    return index >= 0 ? index + 1 : -1;
  }

  /// Check if a task is active
  bool isActive(int taskId) => _activeTaskId == taskId;

  /// Check if a task is in queue
  bool isInQueue(int taskId) => _pendingTasks.contains(taskId);

  /// Clear all tasks
  void clear() {
    _activeTaskId = null;
    _pendingTasks.clear();
    _taskTitles.clear();
    _isProcessing = false;
    log('=== SequentialDownloadQueue: Cleared ===');
  }
}
