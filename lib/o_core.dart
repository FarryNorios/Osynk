import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

import 'l10n/app_localizations.dart';
import 'models/enums.dart';
import 'models/sync_log.dart';
import 'models/sync_progress.dart';
import 'services/auth_service.dart';
import 'services/graph_api.dart';
import 'services/graph_service.dart';
import 'services/notification_service.dart';
import 'services/sync_engine.dart';
import 'services/sync_log_repository.dart';
import 'services/sync_task_repository.dart';
import 'services/theme_settings.dart';

export 'models/enums.dart';
export 'models/sync_log.dart';
export 'models/sync_progress.dart';
export 'models/sync_task.dart';
export 'services/graph_api.dart' show GraphResponse;
export 'services/theme_settings.dart';
export 'services/sync_task_repository.dart';
export 'services/sync_log_repository.dart';

class OCore extends ChangeNotifier {
  late final GraphApi _graph;
  late final AuthService _auth;
  late final SyncEngine _engine;
  late final NotificationService _notify;

  final ThemeSettings themeSettings;
  final SyncTaskRepository taskRepo;
  final SyncLogRepository logRepo;

  bool _disposed = false;

  OCore({
    required this.themeSettings,
    required this.taskRepo,
    required this.logRepo,
  }) {
    _graph = GraphService(getToken: () => _auth.getAccessToken());
    _auth = AuthService(_graph);
    _engine = SyncEngine(_graph, _auth);
    _notify = NotificationService();

    _auth.onStatusChanged = _onStatusChanged;
    _engine.onProgressChanged = _onProgressChanged;
    _engine.onSyncStateChanged = _onSyncStateChanged;
    _engine.onLogAppended = _onLogAppended;

    _initAsync();
  }

  Future<void> _initAsync() async {
    try {
      await Future.wait([taskRepo.load(), logRepo.load(), themeSettings.load()]);
    } catch (e) {
      debugPrint('Failed to load data: $e');
    }
    try {
      await Future.wait([_auth.init(), _notify.init()]);
    } catch (e) {
      debugPrint('Failed to init services: $e');
    }
    _setupDeepLinks();
    _setupLifecycle();
  }

  // ─── Callbacks (safe against dispose) ───

  void _onStatusChanged(LoginStatus _) {
    if (_disposed) return;
    notifyListeners();
  }

  // Notification localized strings (set by UI)
  String _notifSyncing = '正在同步';
  String _notifComplete = '同步完成';

  void setNotificationStrings({
    required String syncing,
    required String complete,
    required String failed,
    required String channelName,
    required String channelDesc,
  }) {
    _notifSyncing = syncing;
    _notifComplete = complete;
    _notify.setLocalizedStrings(
      channelName: channelName,
      channelDesc: channelDesc,
      errorTitle: failed,
    );
  }

  void _onProgressChanged(SyncProgress p) {
    if (_disposed) return;
    notifyListeners();
    if (_engine.isSyncing && p.totalFiles > 0) {
      _notify.showSyncProgress(
        title: _notifSyncing,
        body: "${p.currentFile}  ${p.transferredTextFormatted((c, t) => "$c/$t")}  ${p.speedText}",
        progress: p.completedFiles,
        maxProgress: p.totalFiles,
      );
    }
  }

  void _onSyncStateChanged(bool syncing, SyncStatusType statusType) {
    if (_disposed) return;
    notifyListeners();
    final taskName = _engine.currentTaskName;
    if (syncing) {
      final body = taskName.isNotEmpty ? taskName : '';
      _notify.showSyncProgress(title: _notifSyncing, body: body, progress: 0, maxProgress: 0);
    } else {
      switch (statusType) {
        case SyncStatusType.completed:
          _notify.showSyncComplete(title: _notifComplete, body: taskName);
        case SyncStatusType.failed:
          _notify.showSyncError(body: taskName);
        default:
          _notify.cancelSyncNotification();
      }
    }
  }

  void _onLogAppended(SyncLogEntry entry) {
    if (_disposed) return;
    logRepo.append(entry);
  }

  // ─── Deep Link ───

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _deepLinkSub;

  void _setupDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _handleDeepLink(initialUri);
    } catch (e) {
      debugPrint('Failed to get initial deep link: $e');
    }

    _deepLinkSub = _appLinks.uriLinkStream.listen(
      (Uri uri) => _handleDeepLink(uri),
      onError: (e) => debugPrint('Deep link stream error: $e'),
    );
  }

  Future<void> _handleDeepLink(Uri uri) async {
    try {
      final code = uri.queryParameters['code'];
      if (code != null) {
        if (_auth.status == LoginStatus.loggedIn) return;
        await _auth.exchangeCode(code);
      }
    } catch (e) {
      debugPrint('Deep link handling error: $e');
    }
  }

  // ─── Lifecycle ───

  AppLifecycleListener? _lifecycleListener;

  void _setupLifecycle() {
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
          _auth.clearAccessToken();
        }
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    logRepo.flushSave();
    _deepLinkSub?.cancel();
    _lifecycleListener?.dispose();
    _auth.onStatusChanged = null;
    _engine.onProgressChanged = null;
    _engine.onSyncStateChanged = null;
    _engine.onLogAppended = null;
    super.dispose();
  }

  // ─── Login (delegate to AuthService) ───

  LoginStatus get loginStatus => _auth.status;
  String? get userName => _auth.userName;
  String? get userEmail => _auth.userEmail;

  Future<void> launchLogin() async {
    _auth.launchLogin();
    try {
      final launched = await launchUrl(
        Uri.parse(
          'https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=${GraphResponse.clientId}&scope=Files.ReadWrite.All offline_access User.Read&response_type=code&redirect_uri=${GraphResponse.redirectUri}',
        ),
      );
      if (!launched) {
        debugPrint('Failed to open browser');
        _auth.init();
      }
    } catch (e) {
      debugPrint('Browser launch error: $e');
      _auth.init();
    }
  }

  Future<void> launchLogout() async {
    await _auth.logout();
  }

  // ─── Sync State (delegate to SyncEngine) ───

  bool get isSyncing => _engine.isSyncing;
  bool get cancelRequested => _engine.cancelRequested;
  SyncStatusType get syncStatusType => _engine.syncStatusType;

  String localizedSyncState(AppLocalizations l10n) {
    final st = _engine.syncStatusType;
    final taskName = _engine.currentTaskName;
    return switch (st) {
      SyncStatusType.idle => l10n.syncStateIdle,
      SyncStatusType.loading => l10n.loadingLogin,
      SyncStatusType.notLoggedIn => l10n.syncStateIdle,
      SyncStatusType.noTasks => l10n.syncStateIdle,
      SyncStatusType.starting => l10n.syncStateStarting,
      SyncStatusType.cancelled => l10n.syncStateCancelled,
      SyncStatusType.completed when taskName.isNotEmpty => l10n.syncStateDone(taskName),
      SyncStatusType.completed => l10n.syncStateAllDone,
      SyncStatusType.failed when taskName.isNotEmpty => l10n.syncStateFailed(taskName),
      SyncStatusType.failed => l10n.syncStatePartialFail,
      SyncStatusType.syncing || SyncStatusType.uploading || SyncStatusType.downloading =>
        taskName.isNotEmpty ? l10n.syncStateProgress(taskName) : l10n.syncStateStarting,
    };
  }

  SyncProgress get syncProgress => _engine.progress;
  DateTime? get lastSyncAt => _engine.lastSyncAt;

  void cancelSync() => _engine.cancel();

  Future<void> runAllSyncTasks() async {
    await _engine.runAll(taskRepo.tasks);
  }

  Future<void> runSyncTask(int index) async {
    final tasks = taskRepo.tasks;
    if (index < 0 || index >= tasks.length) return;
    await _engine.runSingle(tasks[index]);
  }

  // ─── Graph API proxy ───

  Future<GraphResponse> graphList(String path) => _graph.graphList(path);
}
