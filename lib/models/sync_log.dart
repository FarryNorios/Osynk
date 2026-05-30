enum LogLevel { info, success, warning, error }

enum LogMessageType {
  cancelRequested,
  syncInProgress,
  loadingLogin,
  pleaseLogin,
  noEnabledTasks,
  startingAll,
  startingTask,
  taskStopped,
  syncCancelled,
  allTasksCompleted,
  taskStarted,
  verifyingRemote,
  runningUpload,
  runningDownload,
  runningBidirectional,
  syncCompleted,
  syncCancelledTask,
  syncFailed,
  uploaded,
  uploadDone,
  createdLocalDir,
  downloadingDir,
  scanningRemote,
  scanDone,
  scanFailed,
  remoteDirEmpty,
  downloaded,
  downloadRetry,
  downloadFailed,
  createdRemoteDir,
}

class SyncLogEntry {
  final DateTime time;
  final LogLevel level;
  final String message; // fallback / raw message
  final LogMessageType? messageType;
  final Map<String, String> params;

  SyncLogEntry({
    required this.level,
    required this.message,
    this.messageType,
    this.params = const {},
  }) : time = DateTime.now();

  SyncLogEntry._({
    required this.time,
    required this.level,
    required this.message,
    this.messageType,
    this.params = const {},
  });

  String get timeText =>
      "${time.hour.toString().padLeft(2, "0")}:"
      "${time.minute.toString().padLeft(2, "0")}:"
      "${time.second.toString().padLeft(2, "0")}";

  String get dateText =>
      "${time.year}-${time.month.toString().padLeft(2, "0")}-${time.day.toString().padLeft(2, "0")}";

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'level': level.index,
    'message': message,
    if (messageType != null) 'messageType': messageType!.index,
    if (params.isNotEmpty) 'params': params,
  };

  factory SyncLogEntry.fromJson(Map<String, dynamic> json) => SyncLogEntry._(
    time: DateTime.parse(json['time'] as String),
    level: LogLevel.values[json['level'] as int? ?? 0],
    message: json['message'] as String? ?? '',
    messageType: json['messageType'] != null
        ? LogMessageType.values[json['messageType'] as int]
        : null,
    params: (json['params'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v.toString())) ??
        {},
  );
}
