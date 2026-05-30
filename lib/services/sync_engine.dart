import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/enums.dart';
import '../models/sync_log.dart';
import '../models/sync_progress.dart';
import '../models/sync_task.dart';
import 'auth_service.dart';
import 'file_transfer.dart';
import 'graph_api.dart';
import 'remote_folder.dart';

class SyncEngine {
  final GraphApi _graph;
  final AuthService _auth;
  late final RemoteFolder _remoteFolder;
  late final FileTransfer _fileTransfer;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  SyncStatusType _syncStatusType = SyncStatusType.idle;
  SyncStatusType get syncStatusType => _syncStatusType;

  /// Name of the task currently being synced (for UI display)
  String _currentTaskName = '';
  String get currentTaskName => _currentTaskName;

  SyncProgress _progress = SyncProgress();
  SyncProgress get progress => _progress;

  DateTime? _lastSyncAt;
  DateTime? get lastSyncAt => _lastSyncAt;

  bool _cancelRequested = false;
  bool _wasCancelled = false;
  bool get cancelRequested => _cancelRequested || _wasCancelled;

  void Function(SyncProgress progress)? onProgressChanged;
  void Function(bool syncing, SyncStatusType statusType)? onSyncStateChanged;
  void Function(SyncLogEntry entry)? onLogAppended;

  SyncEngine(this._graph, this._auth) {
    _remoteFolder = RemoteFolder(_graph);
    _fileTransfer = FileTransfer(_graph, _remoteFolder);

    _remoteFolder.onLogAppended = (entry) => onLogAppended?.call(entry);
    _fileTransfer.onLogAppended = (entry) => onLogAppended?.call(entry);
    _fileTransfer.onProgressChanged = (p) {
      _progress = p;
      onProgressChanged?.call(p);
    };
    _fileTransfer.onCancelCheck = () => _cancelRequested;
  }

  // ─── Cancel ───

  void cancel() {
    if (!_isSyncing) return;
    _cancelRequested = true;
    _appendLog('User requested cancel...', level: LogLevel.warning, type: LogMessageType.cancelRequested);
    _setState(syncing: true, statusType: SyncStatusType.syncing);
  }

  void _checkCancelled() {
    if (_cancelRequested) throw SyncCancelledException();
  }

  // ─── Entry Points ───

  Future<void> runAll(List<SyncTask> tasks) async {
    if (_isSyncing) {
      _appendLog('Sync already in progress', level: LogLevel.warning, type: LogMessageType.syncInProgress);
      return;
    }

    if (_auth.status == LoginStatus.loading) {
      _appendLog('Loading login info, please wait', level: LogLevel.warning, type: LogMessageType.loadingLogin);
      _setState(syncing: false, statusType: SyncStatusType.loading);
      return;
    }

    if (_auth.status != LoginStatus.loggedIn) {
      _appendLog('Please login first', level: LogLevel.warning, type: LogMessageType.pleaseLogin);
      _setState(syncing: false, statusType: SyncStatusType.notLoggedIn);
      return;
    }

    final enabled = tasks.where((t) => t.isEnabled).toList();
    if (enabled.isEmpty) {
      _appendLog('No enabled sync tasks', level: LogLevel.warning, type: LogMessageType.noEnabledTasks);
      _setState(syncing: false, statusType: SyncStatusType.noTasks);
      return;
    }

    _fileTransfer.resetProgress();
    _currentTaskName = '';
    _setState(syncing: true, statusType: SyncStatusType.starting);
    _appendLog('Starting all sync tasks', type: LogMessageType.startingAll);

    var success = true;
    var cancelled = false;

    for (final task in enabled) {
      _appendLog('Starting task: ${task.name}', type: LogMessageType.startingTask, params: {'name': task.name});
      final result = await _runTask(task, batchMode: true);
      if (!result) {
        if (_cancelRequested) cancelled = true;
        success = false;
        _appendLog('Task stopped: ${task.name}', level: LogLevel.warning, type: LogMessageType.taskStopped, params: {'name': task.name});
        break;
      }
    }

    _lastSyncAt = DateTime.now();
    _currentTaskName = '';
    if (cancelled) {
      _appendLog('Sync cancelled', level: LogLevel.warning, type: LogMessageType.syncCancelled);
      _setState(syncing: false, statusType: SyncStatusType.cancelled);
    } else if (success) {
      _appendLog('All sync tasks completed', type: LogMessageType.allTasksCompleted);
      _setState(syncing: false, statusType: SyncStatusType.completed);
    } else {
      _setState(syncing: false, statusType: SyncStatusType.failed);
    }
  }

  Future<bool> runSingle(SyncTask task) async {
    if (_isSyncing) {
      _appendLog('Sync already in progress', level: LogLevel.warning, type: LogMessageType.syncInProgress);
      return false;
    }
    _fileTransfer.resetProgress();
    return _runTask(task);
  }

  Future<bool> _runTask(SyncTask task, {bool batchMode = false}) async {
    if (!batchMode) {
      _fileTransfer.resetProgress();
      _currentTaskName = task.name;
      _setState(syncing: true, statusType: SyncStatusType.syncing);
    }
    _appendLog('Task started: ${task.name}', type: LogMessageType.taskStarted, params: {'name': task.name});

    try {
      final localRoot = task.localPath;
      final remoteRoot = task.remotePath;
      if (localRoot.isEmpty || remoteRoot.isEmpty) {
        throw Exception('Local or remote path is empty');
      }

      if (task.mode != SyncMode.download && !await Directory(localRoot).exists()) {
        throw Exception('Local path not found: $localRoot');
      }

      _appendLog('Verifying remote connection...', type: LogMessageType.verifyingRemote);
      _checkCancelled();
      final token = await _auth.getAccessToken();
      if (token == null) throw Exception('Cannot get access token, please re-login');

      _checkCancelled();
      if (task.mode == SyncMode.upload) {
        _appendLog('Running upload mirror', type: LogMessageType.runningUpload);
        await _fileTransfer.uploadDirectory(localRoot, remoteRoot);
      } else if (task.mode == SyncMode.download) {
        _appendLog('Running download mirror', type: LogMessageType.runningDownload);
        await _fileTransfer.downloadDirectory(localRoot, remoteRoot);
      } else {
        _appendLog('Running bidirectional sync (upload then download)', type: LogMessageType.runningBidirectional);
        await _fileTransfer.uploadDirectory(localRoot, remoteRoot);
        _checkCancelled();
        await _fileTransfer.downloadDirectory(localRoot, remoteRoot);
      }

      _lastSyncAt = DateTime.now();
      _appendLog('Sync completed: ${task.name}', level: LogLevel.success, type: LogMessageType.syncCompleted, params: {'name': task.name});
      if (!batchMode) {
        _currentTaskName = '';
        _setState(syncing: false, statusType: SyncStatusType.completed);
      }
      return true;
    } on SyncCancelledException {
      _appendLog('Sync cancelled: ${task.name}', level: LogLevel.warning, type: LogMessageType.syncCancelledTask, params: {'name': task.name});
      if (!batchMode) {
        _currentTaskName = '';
        _setState(syncing: false, statusType: SyncStatusType.cancelled);
      }
      return false;
    } catch (e, st) {
      _appendLog('Sync failed: $e', level: LogLevel.error, type: LogMessageType.syncFailed, params: {'error': e.toString()});
      debugPrint('Sync error detail: $st');
      if (!batchMode) {
        _currentTaskName = '';
        _setState(syncing: false, statusType: SyncStatusType.failed);
      }
      return false;
    }
  }

  // ─── Internal ───

  void _appendLog(String message, {LogLevel level = LogLevel.info, LogMessageType? type, Map<String, String> params = const {}}) {
    final entry = SyncLogEntry(level: level, message: message, messageType: type, params: params);
    debugPrint('[${entry.timeText}] ${entry.message}');
    onLogAppended?.call(entry);
  }

  void _setState({required bool syncing, SyncStatusType statusType = SyncStatusType.syncing}) {
    _syncStatusType = statusType;
    _isSyncing = syncing;
    if (!syncing) {
      if (_cancelRequested) _wasCancelled = true;
      _cancelRequested = false;
    }
    onSyncStateChanged?.call(syncing, statusType);
  }
}
