import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'Osynk'**
  String get appTitle;

  /// No description provided for @sync.
  ///
  /// In zh, this message translates to:
  /// **'同步'**
  String get sync;

  /// No description provided for @syncSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'点击按钮开始同步'**
  String get syncSubtitle;

  /// No description provided for @loadingLogin.
  ///
  /// In zh, this message translates to:
  /// **'正在加载登录信息...'**
  String get loadingLogin;

  /// No description provided for @startSync.
  ///
  /// In zh, this message translates to:
  /// **'开始同步'**
  String get startSync;

  /// No description provided for @syncing.
  ///
  /// In zh, this message translates to:
  /// **'正在同步'**
  String get syncing;

  /// No description provided for @cancelling.
  ///
  /// In zh, this message translates to:
  /// **'正在取消...'**
  String get cancelling;

  /// No description provided for @cancelSync.
  ///
  /// In zh, this message translates to:
  /// **'取消同步'**
  String get cancelSync;

  /// No description provided for @log.
  ///
  /// In zh, this message translates to:
  /// **'日志'**
  String get log;

  /// No description provided for @logSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'点击查看完整日志'**
  String get logSubtitle;

  /// No description provided for @noLogs.
  ///
  /// In zh, this message translates to:
  /// **'暂无同步日志'**
  String get noLogs;

  /// No description provided for @account.
  ///
  /// In zh, this message translates to:
  /// **'账户'**
  String get account;

  /// No description provided for @accountSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'管理您的账户设置'**
  String get accountSubtitle;

  /// No description provided for @loginMicrosoft.
  ///
  /// In zh, this message translates to:
  /// **'登录 Microsoft 账户'**
  String get loginMicrosoft;

  /// No description provided for @unknownUser.
  ///
  /// In zh, this message translates to:
  /// **'未知用户'**
  String get unknownUser;

  /// No description provided for @unknownEmail.
  ///
  /// In zh, this message translates to:
  /// **'未知邮箱'**
  String get unknownEmail;

  /// No description provided for @confirmLogout.
  ///
  /// In zh, this message translates to:
  /// **'确认登出'**
  String get confirmLogout;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In zh, this message translates to:
  /// **'登出后需要重新登录才能同步文件。'**
  String get confirmLogoutMessage;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In zh, this message translates to:
  /// **'登出'**
  String get logout;

  /// No description provided for @syncTasks.
  ///
  /// In zh, this message translates to:
  /// **'同步任务'**
  String get syncTasks;

  /// No description provided for @syncTasksSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'管理您的同步任务'**
  String get syncTasksSubtitle;

  /// No description provided for @noTasks.
  ///
  /// In zh, this message translates to:
  /// **'暂无同步任务'**
  String get noTasks;

  /// No description provided for @addTask.
  ///
  /// In zh, this message translates to:
  /// **'添加同步任务'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In zh, this message translates to:
  /// **'编辑同步任务'**
  String get editTask;

  /// No description provided for @taskName.
  ///
  /// In zh, this message translates to:
  /// **'任务名称'**
  String get taskName;

  /// No description provided for @taskNameRequired.
  ///
  /// In zh, this message translates to:
  /// **'任务名称不能为空'**
  String get taskNameRequired;

  /// No description provided for @localPath.
  ///
  /// In zh, this message translates to:
  /// **'本地路径'**
  String get localPath;

  /// No description provided for @localPathRequired.
  ///
  /// In zh, this message translates to:
  /// **'本地路径不能为空'**
  String get localPathRequired;

  /// No description provided for @remotePath.
  ///
  /// In zh, this message translates to:
  /// **'远程路径'**
  String get remotePath;

  /// No description provided for @remotePathRequired.
  ///
  /// In zh, this message translates to:
  /// **'远程路径不能为空'**
  String get remotePathRequired;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @bidirectional.
  ///
  /// In zh, this message translates to:
  /// **'双向同步'**
  String get bidirectional;

  /// No description provided for @uploadMirror.
  ///
  /// In zh, this message translates to:
  /// **'上传镜像'**
  String get uploadMirror;

  /// No description provided for @downloadMirror.
  ///
  /// In zh, this message translates to:
  /// **'下载镜像'**
  String get downloadMirror;

  /// No description provided for @fullLog.
  ///
  /// In zh, this message translates to:
  /// **'完整日志'**
  String get fullLog;

  /// No description provided for @clearLog.
  ///
  /// In zh, this message translates to:
  /// **'清空日志'**
  String get clearLog;

  /// No description provided for @noLogRecords.
  ///
  /// In zh, this message translates to:
  /// **'暂无日志记录'**
  String get noLogRecords;

  /// No description provided for @logCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条'**
  String logCount(int count);

  /// No description provided for @latestLog.
  ///
  /// In zh, this message translates to:
  /// **'最新日志'**
  String get latestLog;

  /// No description provided for @selectFile.
  ///
  /// In zh, this message translates to:
  /// **'选择文件/文件夹'**
  String get selectFile;

  /// No description provided for @emptyFolder.
  ///
  /// In zh, this message translates to:
  /// **'空文件夹'**
  String get emptyFolder;

  /// No description provided for @select.
  ///
  /// In zh, this message translates to:
  /// **'选择'**
  String get select;

  /// No description provided for @internalStorage.
  ///
  /// In zh, this message translates to:
  /// **'内部存储'**
  String get internalStorage;

  /// No description provided for @noFolderPermission.
  ///
  /// In zh, this message translates to:
  /// **'没有权限访问该文件夹'**
  String get noFolderPermission;

  /// No description provided for @needStoragePermission.
  ///
  /// In zh, this message translates to:
  /// **'需要存储权限'**
  String get needStoragePermission;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get appearance;

  /// No description provided for @followSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystem;

  /// No description provided for @light.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get dark;

  /// No description provided for @themeColor.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get themeColor;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @chinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @syncStateIdle.
  ///
  /// In zh, this message translates to:
  /// **'未在同步'**
  String get syncStateIdle;

  /// No description provided for @syncStateStarting.
  ///
  /// In zh, this message translates to:
  /// **'开始同步全部任务'**
  String get syncStateStarting;

  /// No description provided for @syncStateCancelled.
  ///
  /// In zh, this message translates to:
  /// **'同步已取消'**
  String get syncStateCancelled;

  /// No description provided for @syncStateAllDone.
  ///
  /// In zh, this message translates to:
  /// **'全部同步任务完成'**
  String get syncStateAllDone;

  /// No description provided for @syncStatePartialFail.
  ///
  /// In zh, this message translates to:
  /// **'同步中断，部分任务失败'**
  String get syncStatePartialFail;

  /// No description provided for @syncStateProgress.
  ///
  /// In zh, this message translates to:
  /// **'同步进行中：{name}'**
  String syncStateProgress(String name);

  /// No description provided for @syncStateDone.
  ///
  /// In zh, this message translates to:
  /// **'同步完成：{name}'**
  String syncStateDone(String name);

  /// No description provided for @syncStateFailed.
  ///
  /// In zh, this message translates to:
  /// **'同步失败：{error}'**
  String syncStateFailed(String error);

  /// No description provided for @uploadingFile.
  ///
  /// In zh, this message translates to:
  /// **'上传中：{name}'**
  String uploadingFile(String name);

  /// No description provided for @downloadingFile.
  ///
  /// In zh, this message translates to:
  /// **'下载中：{name}'**
  String downloadingFile(String name);

  /// No description provided for @notifSyncing.
  ///
  /// In zh, this message translates to:
  /// **'正在同步'**
  String get notifSyncing;

  /// No description provided for @notifComplete.
  ///
  /// In zh, this message translates to:
  /// **'同步完成'**
  String get notifComplete;

  /// No description provided for @notifFailed.
  ///
  /// In zh, this message translates to:
  /// **'同步失败'**
  String get notifFailed;

  /// No description provided for @notifChannelName.
  ///
  /// In zh, this message translates to:
  /// **'同步通知'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In zh, this message translates to:
  /// **'文件同步进度通知'**
  String get notifChannelDesc;

  /// No description provided for @filesTransferred.
  ///
  /// In zh, this message translates to:
  /// **'{completed} / {total} 个文件'**
  String filesTransferred(int completed, int total);

  /// No description provided for @logCancelRequested.
  ///
  /// In zh, this message translates to:
  /// **'用户请求取消...'**
  String get logCancelRequested;

  /// No description provided for @logSyncInProgress.
  ///
  /// In zh, this message translates to:
  /// **'已有同步任务正在进行中'**
  String get logSyncInProgress;

  /// No description provided for @logLoadingLogin.
  ///
  /// In zh, this message translates to:
  /// **'正在加载登录信息，请稍后再试'**
  String get logLoadingLogin;

  /// No description provided for @logPleaseLogin.
  ///
  /// In zh, this message translates to:
  /// **'请先登录后再执行同步'**
  String get logPleaseLogin;

  /// No description provided for @logNoEnabledTasks.
  ///
  /// In zh, this message translates to:
  /// **'没有启用的同步任务'**
  String get logNoEnabledTasks;

  /// No description provided for @logStartingAll.
  ///
  /// In zh, this message translates to:
  /// **'开始同步全部任务'**
  String get logStartingAll;

  /// No description provided for @logStartingTask.
  ///
  /// In zh, this message translates to:
  /// **'开始任务：{name}'**
  String logStartingTask(String name);

  /// No description provided for @logTaskStopped.
  ///
  /// In zh, this message translates to:
  /// **'任务停止：{name}'**
  String logTaskStopped(String name);

  /// No description provided for @logSyncCancelled.
  ///
  /// In zh, this message translates to:
  /// **'同步已取消'**
  String get logSyncCancelled;

  /// No description provided for @logAllTasksCompleted.
  ///
  /// In zh, this message translates to:
  /// **'全部同步任务完成'**
  String get logAllTasksCompleted;

  /// No description provided for @logTaskStarted.
  ///
  /// In zh, this message translates to:
  /// **'任务开始：{name}'**
  String logTaskStarted(String name);

  /// No description provided for @logVerifyingRemote.
  ///
  /// In zh, this message translates to:
  /// **'验证远程连接...'**
  String get logVerifyingRemote;

  /// No description provided for @logRunningUpload.
  ///
  /// In zh, this message translates to:
  /// **'执行上传镜像'**
  String get logRunningUpload;

  /// No description provided for @logRunningDownload.
  ///
  /// In zh, this message translates to:
  /// **'执行下载镜像'**
  String get logRunningDownload;

  /// No description provided for @logRunningBidirectional.
  ///
  /// In zh, this message translates to:
  /// **'执行双向同步（先上传后下载）'**
  String get logRunningBidirectional;

  /// No description provided for @logSyncCompleted.
  ///
  /// In zh, this message translates to:
  /// **'同步完成：{name}'**
  String logSyncCompleted(String name);

  /// No description provided for @logSyncCancelledTask.
  ///
  /// In zh, this message translates to:
  /// **'同步已取消：{name}'**
  String logSyncCancelledTask(String name);

  /// No description provided for @logSyncFailed.
  ///
  /// In zh, this message translates to:
  /// **'同步失败：{error}'**
  String logSyncFailed(String error);

  /// No description provided for @logUploaded.
  ///
  /// In zh, this message translates to:
  /// **'上传文件 [{index}/{total}]：{name}（{size}）'**
  String logUploaded(int index, int total, String name, String size);

  /// No description provided for @logUploadDone.
  ///
  /// In zh, this message translates to:
  /// **'上传完成：{dirs} 个目录，{files} 个文件'**
  String logUploadDone(int dirs, int files);

  /// No description provided for @logCreatedLocalDir.
  ///
  /// In zh, this message translates to:
  /// **'创建本地目录：{path}'**
  String logCreatedLocalDir(String path);

  /// No description provided for @logDownloadingDir.
  ///
  /// In zh, this message translates to:
  /// **'下载目录：{path}'**
  String logDownloadingDir(String path);

  /// No description provided for @logScanningRemote.
  ///
  /// In zh, this message translates to:
  /// **'正在扫描远程文件...'**
  String get logScanningRemote;

  /// No description provided for @logScanDone.
  ///
  /// In zh, this message translates to:
  /// **'扫描完成：{files} 个文件，{size}'**
  String logScanDone(int files, String size);

  /// No description provided for @logScanFailed.
  ///
  /// In zh, this message translates to:
  /// **'扫描远程目录失败：{path}'**
  String logScanFailed(String path);

  /// No description provided for @logRemoteDirEmpty.
  ///
  /// In zh, this message translates to:
  /// **'远程目录为空：{path}'**
  String logRemoteDirEmpty(String path);

  /// No description provided for @logDownloaded.
  ///
  /// In zh, this message translates to:
  /// **'下载文件 [{index}]：{name}（{size}）'**
  String logDownloaded(int index, String name, String size);

  /// No description provided for @logDownloadRetry.
  ///
  /// In zh, this message translates to:
  /// **'下载失败（第 {attempt} 次），重试：{name} - {error}'**
  String logDownloadRetry(int attempt, String name, String error);

  /// No description provided for @logDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'下载失败（已重试 3 次）：{name} - {error}'**
  String logDownloadFailed(String name, String error);

  /// No description provided for @logCreatedRemoteDir.
  ///
  /// In zh, this message translates to:
  /// **'创建远程目录：{path}'**
  String logCreatedRemoteDir(String path);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
