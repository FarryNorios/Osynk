import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static const _syncChannelId = 'osynk_sync';
  static const _progressNotificationId = 1;

  final _plugin = FlutterLocalNotificationsPlugin();
  String _channelName = 'Sync Notifications';
  String _channelDesc = 'File sync progress notifications';
  String _errorTitle = 'Sync Failed';

  void setLocalizedStrings({
    required String channelName,
    required String channelDesc,
    required String errorTitle,
  }) {
    _channelName = channelName;
    _channelDesc = channelDesc;
    _errorTitle = errorTitle;
  }

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  Future<void> showSyncProgress({
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _syncChannelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      ongoing: true,
      autoCancel: false,
      icon: '@mipmap/ic_launcher',
    );
    final details = NotificationDetails(android: androidDetails);
    await _plugin.show(_progressNotificationId, title, body, details);
  }

  Future<void> showSyncComplete({required String title, required String body}) async {
    await cancelSyncNotification();

    final androidDetails = AndroidNotificationDetails(
      _syncChannelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    final details = NotificationDetails(android: androidDetails);
    await _plugin.show(_progressNotificationId + 1, title, body, details);
  }

  Future<void> showSyncError({required String body}) async {
    await cancelSyncNotification();

    final androidDetails = AndroidNotificationDetails(
      _syncChannelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    final details = NotificationDetails(android: androidDetails);
    await _plugin.show(_progressNotificationId + 2, _errorTitle, body, details);
  }

  Future<void> cancelSyncNotification() async {
    await _plugin.cancel(_progressNotificationId);
  }
}
