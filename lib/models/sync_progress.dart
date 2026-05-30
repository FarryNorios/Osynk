class SyncProgress {
  final int totalFiles;
  final int completedFiles;
  final int totalBytes;
  final int transferredBytes;
  final String currentFile;
  final double speed; // bytes per second

  SyncProgress({
    this.totalFiles = 0,
    this.completedFiles = 0,
    this.totalBytes = 0,
    this.transferredBytes = 0,
    this.currentFile = '',
    this.speed = 0,
  });

  double get fileProgress => totalFiles > 0 ? completedFiles / totalFiles : 0;
  double get byteProgress => totalBytes > 0 ? transferredBytes / totalBytes : 0;
  double get overallProgress => totalBytes > 0 ? byteProgress : fileProgress;

  String get speedText {
    if (speed <= 0) return '--';
    if (speed < 1024) return '${speed.toStringAsFixed(0)} B/s';
    if (speed < 1024 * 1024) return '${(speed / 1024).toStringAsFixed(1)} KB/s';
    return '${(speed / 1024 / 1024).toStringAsFixed(1)} MB/s';
  }

  String transferredTextFormatted(String Function(int, int) filesTransferred) {
    if (totalBytes <= 0) return filesTransferred(completedFiles, totalFiles);
    return '${formatBytes(transferredBytes)} / ${formatBytes(totalBytes)}';
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }
}

class SyncCancelledException implements Exception {
  @override
  String toString() => 'Sync cancelled';
}
