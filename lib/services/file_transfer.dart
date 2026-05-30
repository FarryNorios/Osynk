import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/sync_log.dart';
import '../models/sync_progress.dart';
import 'graph_api.dart';
import 'remote_folder.dart';

/// Handles file upload/download operations with progress tracking,
/// retry logic, and temp file management.
class FileTransfer {
  final GraphApi _graph;
  final RemoteFolder _remoteFolder;

  void Function(SyncProgress progress)? onProgressChanged;
  void Function(SyncLogEntry entry)? onLogAppended;
  bool Function()? onCancelCheck;

  FileTransfer(this._graph, this._remoteFolder);

  // ─── Upload ───

  /// Uploads all files under localRoot to remoteRoot (mirror mode).
  /// Returns (fileCount, dirCount).
  Future<(int files, int dirs)> uploadDirectory(String localRoot, String remoteRoot) async {
    final localDir = Directory(localRoot);
    final root = GraphApi.normalizePath(remoteRoot);

    final files = <_FileInfo>[];
    int dirCount = 0;

    await for (final entity in localDir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final length = await entity.length();
        files.add(_FileInfo(entity.path, length));
      } else if (entity is Directory) {
        dirCount++;
      }
    }

    final totalBytes = files.fold<int>(0, (sum, f) => sum + f.size);
    _updateProgress(totalFiles: files.length, completedFiles: 0, totalBytes: totalBytes, transferredBytes: 0);

    int fileCount = 0;
    int transferred = 0;
    final stopwatch = Stopwatch()..start();

    for (final fileInfo in files) {
      _checkCancelled();

      final relativePath = fileInfo.path.substring(localDir.path.length).replaceAll(RegExp(r'^[\\/]+'), '');
      if (relativePath.isEmpty) continue;

      final targetRemotePath = root.isEmpty ? relativePath : '$root/$relativePath';

      final parent = _remoteParent(targetRemotePath);
      if (parent.isNotEmpty) await _remoteFolder.ensureExists(parent);

      _setProgressField(
        currentFile: relativePath,
        speed: stopwatch.elapsedMilliseconds > 0 ? transferred / (stopwatch.elapsedMilliseconds / 1000) : 0,
      );

      final bytes = await File(fileInfo.path).readAsBytes();
      final response = await _graph.graphUploadFile(targetRemotePath, bytes);
      if (!response.isSuccess) {
        throw Exception('Upload failed: $targetRemotePath (${response.data})');
      }

      fileCount++;
      transferred += fileInfo.size;
      _updateProgress(
        completedFiles: fileCount,
        transferredBytes: transferred,
        speed: stopwatch.elapsedMilliseconds > 0 ? transferred / (stopwatch.elapsedMilliseconds / 1000) : 0,
      );
      _log('Uploaded [$fileCount/${files.length}]: $relativePath (${SyncProgress.formatBytes(fileInfo.size)})',
          level: LogLevel.success, type: LogMessageType.uploaded,
          params: {'index': '$fileCount', 'total': '${files.length}', 'name': relativePath, 'size': SyncProgress.formatBytes(fileInfo.size)});
    }

    _log('Upload done: $dirCount dirs, $fileCount files', level: LogLevel.success, type: LogMessageType.uploadDone, params: {'dirs': '$dirCount', 'files': '$fileCount'});
    return (fileCount, dirCount);
  }

  // ─── Download ───

  int _dlFileCount = 0;
  int _dlTransferred = 0;
  Stopwatch? _dlStopwatch;

  /// Downloads all files from remoteRoot to localRoot (mirror mode).
  /// Skips unchanged files (same size and local not older than remote).
  Future<void> downloadDirectory(String localRoot, String remoteRoot) async {
    final localDir = Directory(localRoot);
    if (!await localDir.exists()) {
      try {
        await localDir.create(recursive: true);
        _log('Created local dir: $localRoot', level: LogLevel.success, type: LogMessageType.createdLocalDir, params: {'path': localRoot});
      } catch (e) {
        throw Exception('Cannot create local dir: $localRoot - $e');
      }
    }

    final root = GraphApi.normalizePath(remoteRoot);
    _log('Downloading remote dir: $root', type: LogMessageType.downloadingDir, params: {'path': root});

    await cleanTempFiles(localDir);

    _log('Scanning remote files...', type: LogMessageType.scanningRemote);
    final counts = await _remoteFolder.countFiles(root);
    _updateProgress(totalFiles: counts.files, completedFiles: 0, totalBytes: counts.bytes, transferredBytes: 0);
    _log('Scan done: ${counts.files} files, ${SyncProgress.formatBytes(counts.bytes)}',
        level: LogLevel.success, type: LogMessageType.scanDone,
        params: {'files': '${counts.files}', 'size': SyncProgress.formatBytes(counts.bytes)});

    _dlFileCount = 0;
    _dlTransferred = 0;
    _dlStopwatch = null;
    await _downloadRemoteDir(root, localDir.path);
  }

  Future<void> _downloadRemoteDir(String remotePath, String localPath) async {
    final items = await _remoteFolder.listChildren(remotePath);
    if (items.isEmpty) {
      _log('Remote dir empty: $remotePath', level: LogLevel.warning, type: LogMessageType.remoteDirEmpty, params: {'path': remotePath});
      return;
    }

    _dlStopwatch ??= Stopwatch()..start();

    for (final item in items) {
      _checkCancelled();

      if (item.name.isEmpty) continue;

      final childRemotePath = remotePath.isEmpty ? item.name : '$remotePath/${item.name}';
      final childLocalPath = '$localPath${Platform.pathSeparator}${item.name}';

      if (item.isFolder) {
        final childDir = Directory(childLocalPath);
        if (!await childDir.exists()) await childDir.create(recursive: true);
        _log('Downloading dir: $childRemotePath', type: LogMessageType.downloadingDir, params: {'path': childRemotePath});
        await _downloadRemoteDir(childRemotePath, childLocalPath);
      } else {
        await _downloadFile(childRemotePath, childLocalPath, item.size, item.lastModified);
      }
    }
  }

  Future<void> _downloadFile(String remotePath, String localPath, int fileSize, DateTime? remoteModified) async {
    // Skip unchanged files
    final localFile = File(localPath);
    if (await localFile.exists()) {
      final localSize = await localFile.length();
      if (localSize == fileSize) {
        if (remoteModified != null) {
          final localModified = localFile.lastModifiedSync();
          if (!localModified.isBefore(remoteModified.toLocal())) {
            _dlFileCount++;
            _dlTransferred += fileSize;
            _updateProgress(completedFiles: _dlFileCount, transferredBytes: _dlTransferred);
            return;
          }
        } else {
          _dlFileCount++;
          _dlTransferred += fileSize;
          _updateProgress(completedFiles: _dlFileCount, transferredBytes: _dlTransferred);
          return;
        }
      }
    }

    final name = remotePath.split('/').last;

    // Download with retry (max 3 attempts)
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        _setProgressField(
          currentFile: name,
          speed: _dlStopwatch!.elapsedMilliseconds > 0
              ? _dlTransferred / (_dlStopwatch!.elapsedMilliseconds / 1000)
              : 0,
        );

        final fileBytes = await _graph.graphDownloadFile(
          remotePath,
          onProgress: (bytesReceived) {
            _updateProgress(
              currentFile: name,
              speed: _dlStopwatch!.elapsedMilliseconds > 0
                  ? (_dlTransferred + bytesReceived) / (_dlStopwatch!.elapsedMilliseconds / 1000)
                  : 0,
            );
          },
        );
        // Write to temp file first, then atomic rename to prevent corruption
        final tempFile = File('$localPath.osynktmp');
        await localFile.parent.create(recursive: true);
        await tempFile.writeAsBytes(fileBytes);
        await tempFile.rename(localPath);

        _dlFileCount++;
        _dlTransferred += fileSize;
        _updateProgress(
          completedFiles: _dlFileCount,
          transferredBytes: _dlTransferred,
          speed: _dlStopwatch!.elapsedMilliseconds > 0
              ? _dlTransferred / (_dlStopwatch!.elapsedMilliseconds / 1000)
              : 0,
        );
        _log('Downloaded [$_dlFileCount]: $name (${SyncProgress.formatBytes(fileSize)})',
            level: LogLevel.success, type: LogMessageType.downloaded,
            params: {'index': '$_dlFileCount', 'name': name, 'size': SyncProgress.formatBytes(fileSize)});
        return;
      } catch (e) {
        if (attempt < 3) {
          _log('Download failed (attempt $attempt), retrying: $name - $e',
              level: LogLevel.warning, type: LogMessageType.downloadRetry,
              params: {'attempt': '$attempt', 'name': name, 'error': e.toString()});
          await Future.delayed(Duration(seconds: attempt * 2));
        } else {
          _log('Download failed (3 attempts): $name - $e',
              level: LogLevel.error, type: LogMessageType.downloadFailed,
              params: {'name': name, 'error': e.toString()});
        }
      }
    }
    // Single file failure does not abort entire sync
  }

  // ─── Temp File Cleanup ───

  Future<void> cleanTempFiles(Directory dir) async {
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.osynktmp')) {
          try {
            await entity.delete();
          } catch (e) {
            debugPrint('Failed to delete temp file: ${entity.path} - $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to scan temp files: $e');
    }
  }

  // ─── Internal helpers ───

  void _checkCancelled() {
    if (onCancelCheck?.call() == true) throw SyncCancelledException();
  }

  String _remoteParent(String remotePath) {
    final normalized = GraphApi.normalizePath(remotePath);
    final index = normalized.lastIndexOf('/');
    if (index <= 0) return '';
    return normalized.substring(0, index);
  }

  void _log(String message, {LogLevel level = LogLevel.info, LogMessageType? type, Map<String, String> params = const {}}) {
    final entry = SyncLogEntry(level: level, message: message, messageType: type, params: params);
    debugPrint('[${entry.timeText}] ${entry.message}');
    onLogAppended?.call(entry);
  }

  void _updateProgress({
    int? totalFiles,
    int? completedFiles,
    int? totalBytes,
    int? transferredBytes,
    String? currentFile,
    double? speed,
  }) {
    final p = SyncProgress(
      totalFiles: totalFiles ?? _currentProgress.totalFiles,
      completedFiles: completedFiles ?? _currentProgress.completedFiles,
      totalBytes: totalBytes ?? _currentProgress.totalBytes,
      transferredBytes: transferredBytes ?? _currentProgress.transferredBytes,
      currentFile: currentFile ?? _currentProgress.currentFile,
      speed: speed ?? _currentProgress.speed,
    );
    _currentProgress = p;
    onProgressChanged?.call(p);
  }

  void _setProgressField({String? currentFile, double? speed}) {
    _updateProgress(currentFile: currentFile, speed: speed);
  }

  SyncProgress _currentProgress = SyncProgress();

  void resetProgress() {
    _currentProgress = SyncProgress();
    onProgressChanged?.call(_currentProgress);
  }
}

class _FileInfo {
  final String path;
  final int size;
  _FileInfo(this.path, this.size);
}
