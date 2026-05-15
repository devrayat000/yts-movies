import 'dart:async';
import 'dart:developer';

/// Multi-slot download queue. Up to [maxConcurrent] tasks may be running
/// (downloading or paused) at the same time. Pausing a task does NOT free
/// a slot — only stop / complete / fail does.
///
/// Class name kept for backwards compatibility with existing imports.
class SequentialDownloadQueue {
  /// Currently running / paused task IDs (occupy a slot)
  final Set<int> _activeTaskIds = <int>{};

  /// Queue of waiting task IDs (FIFO)
  final List<int> _pendingTasks = [];

  /// Task titles for logging
  final Map<int, String> _taskTitles = {};

  /// Callback to actually start a download
  Future<void> Function(int taskId)? _startDownloadCallback;

  /// Re-entrancy guard for `_processNext`
  bool _isProcessing = false;

  /// Maximum concurrent active tasks (running OR paused)
  int _maxConcurrent = 3;

  int get maxConcurrent => _maxConcurrent;

  set maxConcurrent(int value) {
    _maxConcurrent = value.clamp(1, 10);
    log('=== Queue: maxConcurrent set to $_maxConcurrent ===');
    _processNext();
  }

  void setStartCallback(Future<void> Function(int taskId) callback) {
    _startDownloadCallback = callback;
  }

  /// Add a task. Returns true if it was queued (waiting), false if it started
  /// immediately.
  bool addTask(int taskId, String title) {
    _taskTitles[taskId] = title;

    if (_activeTaskIds.contains(taskId) || _pendingTasks.contains(taskId)) {
      log('Task $taskId already present in queue / active');
      return _pendingTasks.contains(taskId);
    }

    if (_activeTaskIds.length < _maxConcurrent) {
      _activeTaskIds.add(taskId);
      log('=== Queue: starting task $taskId immediately ($title) ===');
      _startTask(taskId);
      return false;
    }

    _pendingTasks.add(taskId);
    log('=== Queue: task $taskId queued ($title), position ${_pendingTasks.length} ===');
    return true;
  }

  /// Free a slot occupied by [taskId] and try to start the next pending task.
  /// Call this on stop / complete / fail. Do NOT call on pause.
  void markCurrentComplete(int taskId) {
    final wasActive = _activeTaskIds.remove(taskId);
    final wasPending = _pendingTasks.remove(taskId);
    _taskTitles.remove(taskId);

    if (wasActive) {
      log('=== Queue: slot freed for task $taskId ===');
    } else if (wasPending) {
      log('=== Queue: removed pending task $taskId before it started ===');
    }
    _processNext();
  }

  /// Remove a pending task (no-op for active tasks).
  void removeTask(int taskId) {
    if (_pendingTasks.remove(taskId)) {
      _taskTitles.remove(taskId);
      log('=== Queue: removed pending task $taskId ===');
    }
  }

  void _processNext() {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      while (_activeTaskIds.length < _maxConcurrent &&
          _pendingTasks.isNotEmpty) {
        final next = _pendingTasks.removeAt(0);
        _activeTaskIds.add(next);
        log('=== Queue: promoting task $next (${_taskTitles[next]}) ===');
        _startTask(next);
      }
    } finally {
      _isProcessing = false;
    }
  }

  void _startTask(int taskId) {
    final cb = _startDownloadCallback;
    if (cb == null) {
      log('Start callback not set; cannot start task $taskId');
      return;
    }
    cb(taskId).catchError((e, s) {
      log('Error starting download $taskId: $e', error: e, stackTrace: s);
      // Free slot on failure so queue moves on
      _activeTaskIds.remove(taskId);
      _processNext();
    });
  }

  Map<String, dynamic> getStats() => {
        'activeTaskIds': _activeTaskIds.toList(),
        'pendingCount': _pendingTasks.length,
        'pendingTaskIds': List<int>.from(_pendingTasks),
        'maxConcurrent': _maxConcurrent,
      };

  /// 0 if active, 1+ if pending, -1 if not found
  int getQueuePosition(int taskId) {
    if (_activeTaskIds.contains(taskId)) return 0;
    final i = _pendingTasks.indexOf(taskId);
    return i >= 0 ? i + 1 : -1;
  }

  bool isActive(int taskId) => _activeTaskIds.contains(taskId);
  bool isInQueue(int taskId) => _pendingTasks.contains(taskId);

  void clear() {
    _activeTaskIds.clear();
    _pendingTasks.clear();
    _taskTitles.clear();
    _isProcessing = false;
    log('=== Queue: cleared ===');
  }
}
