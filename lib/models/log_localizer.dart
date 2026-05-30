import '../l10n/app_localizations.dart';
import 'sync_log.dart';

class LogLocalizer {
  static String getMessage(SyncLogEntry entry, AppLocalizations l10n) {
    final type = entry.messageType;
    if (type == null) return entry.message; // fallback for old logs

    final p = entry.params;
    return switch (type) {
      LogMessageType.cancelRequested => l10n.logCancelRequested,
      LogMessageType.syncInProgress => l10n.logSyncInProgress,
      LogMessageType.loadingLogin => l10n.logLoadingLogin,
      LogMessageType.pleaseLogin => l10n.logPleaseLogin,
      LogMessageType.noEnabledTasks => l10n.logNoEnabledTasks,
      LogMessageType.startingAll => l10n.logStartingAll,
      LogMessageType.startingTask => l10n.logStartingTask(p['name'] ?? ''),
      LogMessageType.taskStopped => l10n.logTaskStopped(p['name'] ?? ''),
      LogMessageType.syncCancelled => l10n.logSyncCancelled,
      LogMessageType.allTasksCompleted => l10n.logAllTasksCompleted,
      LogMessageType.taskStarted => l10n.logTaskStarted(p['name'] ?? ''),
      LogMessageType.verifyingRemote => l10n.logVerifyingRemote,
      LogMessageType.runningUpload => l10n.logRunningUpload,
      LogMessageType.runningDownload => l10n.logRunningDownload,
      LogMessageType.runningBidirectional => l10n.logRunningBidirectional,
      LogMessageType.syncCompleted => l10n.logSyncCompleted(p['name'] ?? ''),
      LogMessageType.syncCancelledTask => l10n.logSyncCancelledTask(p['name'] ?? ''),
      LogMessageType.syncFailed => l10n.logSyncFailed(p['error'] ?? ''),
      LogMessageType.uploaded => l10n.logUploaded(
          int.tryParse(p['index'] ?? '0') ?? 0,
          int.tryParse(p['total'] ?? '0') ?? 0,
          p['name'] ?? '',
          p['size'] ?? ''),
      LogMessageType.uploadDone => l10n.logUploadDone(
          int.tryParse(p['dirs'] ?? '0') ?? 0,
          int.tryParse(p['files'] ?? '0') ?? 0),
      LogMessageType.createdLocalDir => l10n.logCreatedLocalDir(p['path'] ?? ''),
      LogMessageType.downloadingDir => l10n.logDownloadingDir(p['path'] ?? ''),
      LogMessageType.scanningRemote => l10n.logScanningRemote,
      LogMessageType.scanDone => l10n.logScanDone(
          int.tryParse(p['files'] ?? '0') ?? 0,
          p['size'] ?? ''),
      LogMessageType.scanFailed => l10n.logScanFailed(p['path'] ?? ''),
      LogMessageType.remoteDirEmpty => l10n.logRemoteDirEmpty(p['path'] ?? ''),
      LogMessageType.downloaded => l10n.logDownloaded(
          int.tryParse(p['index'] ?? '0') ?? 0,
          p['name'] ?? '',
          p['size'] ?? ''),
      LogMessageType.downloadRetry => l10n.logDownloadRetry(
          int.tryParse(p['attempt'] ?? '0') ?? 0,
          p['name'] ?? '',
          p['error'] ?? ''),
      LogMessageType.downloadFailed => l10n.logDownloadFailed(
          p['name'] ?? '',
          p['error'] ?? ''),
      LogMessageType.createdRemoteDir => l10n.logCreatedRemoteDir(p['path'] ?? ''),
    };
  }
}
