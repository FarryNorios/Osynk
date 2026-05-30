// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Osynk';

  @override
  String get sync => 'Sync';

  @override
  String get syncSubtitle => 'Tap to start syncing';

  @override
  String get loadingLogin => 'Loading login info...';

  @override
  String get startSync => 'Start Sync';

  @override
  String get syncing => 'Syncing';

  @override
  String get cancelling => 'Cancelling...';

  @override
  String get cancelSync => 'Cancel Sync';

  @override
  String get log => 'Log';

  @override
  String get logSubtitle => 'Tap to view full log';

  @override
  String get noLogs => 'No sync logs yet';

  @override
  String get account => 'Account';

  @override
  String get accountSubtitle => 'Manage your account settings';

  @override
  String get loginMicrosoft => 'Sign in with Microsoft';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get unknownEmail => 'Unknown Email';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get confirmLogoutMessage =>
      'You need to sign in again after logging out.';

  @override
  String get cancel => 'Cancel';

  @override
  String get logout => 'Logout';

  @override
  String get syncTasks => 'Sync Tasks';

  @override
  String get syncTasksSubtitle => 'Manage your sync tasks';

  @override
  String get noTasks => 'No sync tasks yet';

  @override
  String get addTask => 'Add Sync Task';

  @override
  String get editTask => 'Edit Sync Task';

  @override
  String get taskName => 'Task Name';

  @override
  String get taskNameRequired => 'Task name is required';

  @override
  String get localPath => 'Local Path';

  @override
  String get localPathRequired => 'Local path is required';

  @override
  String get remotePath => 'Remote Path';

  @override
  String get remotePathRequired => 'Remote path is required';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get bidirectional => 'Bidirectional';

  @override
  String get uploadMirror => 'Upload Mirror';

  @override
  String get downloadMirror => 'Download Mirror';

  @override
  String get fullLog => 'Full Log';

  @override
  String get clearLog => 'Clear Log';

  @override
  String get noLogRecords => 'No log records yet';

  @override
  String logCount(int count) {
    return '$count entries';
  }

  @override
  String get latestLog => 'Latest Log';

  @override
  String get selectFile => 'Select File/Folder';

  @override
  String get emptyFolder => 'Empty Folder';

  @override
  String get select => 'Select';

  @override
  String get internalStorage => 'Internal Storage';

  @override
  String get noFolderPermission => 'No permission to access this folder';

  @override
  String get needStoragePermission => 'Storage permission required';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get followSystem => 'Follow System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get language => 'Language';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get syncStateIdle => 'Idle';

  @override
  String get syncStateStarting => 'Starting all sync tasks';

  @override
  String get syncStateCancelled => 'Sync cancelled';

  @override
  String get syncStateAllDone => 'All sync tasks completed';

  @override
  String get syncStatePartialFail => 'Sync interrupted, some tasks failed';

  @override
  String syncStateProgress(String name) {
    return 'Syncing: $name';
  }

  @override
  String syncStateDone(String name) {
    return 'Sync completed: $name';
  }

  @override
  String syncStateFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String uploadingFile(String name) {
    return 'Uploading: $name';
  }

  @override
  String downloadingFile(String name) {
    return 'Downloading: $name';
  }

  @override
  String get notifSyncing => 'Syncing';

  @override
  String get notifComplete => 'Sync Complete';

  @override
  String get notifFailed => 'Sync Failed';

  @override
  String get notifChannelName => 'Sync Notifications';

  @override
  String get notifChannelDesc => 'File sync progress notifications';

  @override
  String filesTransferred(int completed, int total) {
    return '$completed / $total files';
  }

  @override
  String get logCancelRequested => 'User requested cancel...';

  @override
  String get logSyncInProgress => 'Sync already in progress';

  @override
  String get logLoadingLogin => 'Loading login info, please wait';

  @override
  String get logPleaseLogin => 'Please login first';

  @override
  String get logNoEnabledTasks => 'No enabled sync tasks';

  @override
  String get logStartingAll => 'Starting all sync tasks';

  @override
  String logStartingTask(String name) {
    return 'Starting task: $name';
  }

  @override
  String logTaskStopped(String name) {
    return 'Task stopped: $name';
  }

  @override
  String get logSyncCancelled => 'Sync cancelled';

  @override
  String get logAllTasksCompleted => 'All sync tasks completed';

  @override
  String logTaskStarted(String name) {
    return 'Task started: $name';
  }

  @override
  String get logVerifyingRemote => 'Verifying remote connection...';

  @override
  String get logRunningUpload => 'Running upload mirror';

  @override
  String get logRunningDownload => 'Running download mirror';

  @override
  String get logRunningBidirectional =>
      'Running bidirectional sync (upload then download)';

  @override
  String logSyncCompleted(String name) {
    return 'Sync completed: $name';
  }

  @override
  String logSyncCancelledTask(String name) {
    return 'Sync cancelled: $name';
  }

  @override
  String logSyncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String logUploaded(int index, int total, String name, String size) {
    return 'Uploaded [$index/$total]: $name ($size)';
  }

  @override
  String logUploadDone(int dirs, int files) {
    return 'Upload done: $dirs dirs, $files files';
  }

  @override
  String logCreatedLocalDir(String path) {
    return 'Created local dir: $path';
  }

  @override
  String logDownloadingDir(String path) {
    return 'Downloading dir: $path';
  }

  @override
  String get logScanningRemote => 'Scanning remote files...';

  @override
  String logScanDone(int files, String size) {
    return 'Scan done: $files files, $size';
  }

  @override
  String logScanFailed(String path) {
    return 'Failed to scan remote dir: $path';
  }

  @override
  String logRemoteDirEmpty(String path) {
    return 'Remote dir empty: $path';
  }

  @override
  String logDownloaded(int index, String name, String size) {
    return 'Downloaded [$index]: $name ($size)';
  }

  @override
  String logDownloadRetry(int attempt, String name, String error) {
    return 'Download failed (attempt $attempt), retrying: $name - $error';
  }

  @override
  String logDownloadFailed(String name, String error) {
    return 'Download failed (3 attempts): $name - $error';
  }

  @override
  String logCreatedRemoteDir(String path) {
    return 'Created remote dir: $path';
  }
}
