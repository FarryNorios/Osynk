// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Osynk';

  @override
  String get sync => '同步';

  @override
  String get syncSubtitle => '点击按钮开始同步';

  @override
  String get loadingLogin => '正在加载登录信息...';

  @override
  String get startSync => '开始同步';

  @override
  String get syncing => '正在同步';

  @override
  String get cancelling => '正在取消...';

  @override
  String get cancelSync => '取消同步';

  @override
  String get log => '日志';

  @override
  String get logSubtitle => '点击查看完整日志';

  @override
  String get noLogs => '暂无同步日志';

  @override
  String get account => '账户';

  @override
  String get accountSubtitle => '管理您的账户设置';

  @override
  String get loginMicrosoft => '登录 Microsoft 账户';

  @override
  String get unknownUser => '未知用户';

  @override
  String get unknownEmail => '未知邮箱';

  @override
  String get confirmLogout => '确认登出';

  @override
  String get confirmLogoutMessage => '登出后需要重新登录才能同步文件。';

  @override
  String get cancel => '取消';

  @override
  String get logout => '登出';

  @override
  String get syncTasks => '同步任务';

  @override
  String get syncTasksSubtitle => '管理您的同步任务';

  @override
  String get noTasks => '暂无同步任务';

  @override
  String get addTask => '添加同步任务';

  @override
  String get editTask => '编辑同步任务';

  @override
  String get taskName => '任务名称';

  @override
  String get taskNameRequired => '任务名称不能为空';

  @override
  String get localPath => '本地路径';

  @override
  String get localPathRequired => '本地路径不能为空';

  @override
  String get remotePath => '远程路径';

  @override
  String get remotePathRequired => '远程路径不能为空';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get bidirectional => '双向同步';

  @override
  String get uploadMirror => '上传镜像';

  @override
  String get downloadMirror => '下载镜像';

  @override
  String get fullLog => '完整日志';

  @override
  String get clearLog => '清空日志';

  @override
  String get noLogRecords => '暂无日志记录';

  @override
  String logCount(int count) {
    return '$count 条';
  }

  @override
  String get latestLog => '最新日志';

  @override
  String get selectFile => '选择文件/文件夹';

  @override
  String get emptyFolder => '空文件夹';

  @override
  String get select => '选择';

  @override
  String get internalStorage => '内部存储';

  @override
  String get noFolderPermission => '没有权限访问该文件夹';

  @override
  String get needStoragePermission => '需要存储权限';

  @override
  String get settings => '设置';

  @override
  String get appearance => '外观';

  @override
  String get followSystem => '跟随系统';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get themeColor => '主题色';

  @override
  String get language => '语言';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get syncStateIdle => '未在同步';

  @override
  String get syncStateStarting => '开始同步全部任务';

  @override
  String get syncStateCancelled => '同步已取消';

  @override
  String get syncStateAllDone => '全部同步任务完成';

  @override
  String get syncStatePartialFail => '同步中断，部分任务失败';

  @override
  String syncStateProgress(String name) {
    return '同步进行中：$name';
  }

  @override
  String syncStateDone(String name) {
    return '同步完成：$name';
  }

  @override
  String syncStateFailed(String error) {
    return '同步失败：$error';
  }

  @override
  String uploadingFile(String name) {
    return '上传中：$name';
  }

  @override
  String downloadingFile(String name) {
    return '下载中：$name';
  }

  @override
  String get notifSyncing => '正在同步';

  @override
  String get notifComplete => '同步完成';

  @override
  String get notifFailed => '同步失败';

  @override
  String get notifChannelName => '同步通知';

  @override
  String get notifChannelDesc => '文件同步进度通知';

  @override
  String filesTransferred(int completed, int total) {
    return '$completed / $total 个文件';
  }

  @override
  String get logCancelRequested => '用户请求取消...';

  @override
  String get logSyncInProgress => '已有同步任务正在进行中';

  @override
  String get logLoadingLogin => '正在加载登录信息，请稍后再试';

  @override
  String get logPleaseLogin => '请先登录后再执行同步';

  @override
  String get logNoEnabledTasks => '没有启用的同步任务';

  @override
  String get logStartingAll => '开始同步全部任务';

  @override
  String logStartingTask(String name) {
    return '开始任务：$name';
  }

  @override
  String logTaskStopped(String name) {
    return '任务停止：$name';
  }

  @override
  String get logSyncCancelled => '同步已取消';

  @override
  String get logAllTasksCompleted => '全部同步任务完成';

  @override
  String logTaskStarted(String name) {
    return '任务开始：$name';
  }

  @override
  String get logVerifyingRemote => '验证远程连接...';

  @override
  String get logRunningUpload => '执行上传镜像';

  @override
  String get logRunningDownload => '执行下载镜像';

  @override
  String get logRunningBidirectional => '执行双向同步（先上传后下载）';

  @override
  String logSyncCompleted(String name) {
    return '同步完成：$name';
  }

  @override
  String logSyncCancelledTask(String name) {
    return '同步已取消：$name';
  }

  @override
  String logSyncFailed(String error) {
    return '同步失败：$error';
  }

  @override
  String logUploaded(int index, int total, String name, String size) {
    return '上传文件 [$index/$total]：$name（$size）';
  }

  @override
  String logUploadDone(int dirs, int files) {
    return '上传完成：$dirs 个目录，$files 个文件';
  }

  @override
  String logCreatedLocalDir(String path) {
    return '创建本地目录：$path';
  }

  @override
  String logDownloadingDir(String path) {
    return '下载目录：$path';
  }

  @override
  String get logScanningRemote => '正在扫描远程文件...';

  @override
  String logScanDone(int files, String size) {
    return '扫描完成：$files 个文件，$size';
  }

  @override
  String logScanFailed(String path) {
    return '扫描远程目录失败：$path';
  }

  @override
  String logRemoteDirEmpty(String path) {
    return '远程目录为空：$path';
  }

  @override
  String logDownloaded(int index, String name, String size) {
    return '下载文件 [$index]：$name（$size）';
  }

  @override
  String logDownloadRetry(int attempt, String name, String error) {
    return '下载失败（第 $attempt 次），重试：$name - $error';
  }

  @override
  String logDownloadFailed(String name, String error) {
    return '下载失败（已重试 3 次）：$name - $error';
  }

  @override
  String logCreatedRemoteDir(String path) {
    return '创建远程目录：$path';
  }
}
