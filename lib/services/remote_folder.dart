import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/sync_log.dart';
import 'graph_api.dart';

/// Handles remote directory operations on Microsoft Graph.
class RemoteFolder {
  final GraphApi _graph;

  void Function(SyncLogEntry entry)? onLogAppended;

  RemoteFolder(this._graph);

  /// Ensures the full directory path exists remotely, creating missing folders.
  Future<void> ensureExists(String remoteDir) async {
    final normalized = GraphApi.normalizePath(remoteDir);
    if (normalized.isEmpty) return;

    final segments = normalized.split('/');
    String current = '';
    for (final segment in segments) {
      if (segment.isEmpty) continue;
      current = current.isEmpty ? segment : '$current/$segment';
      final exists = await _graph.graphPathExists(current);
      if (!exists) {
        final parent = _parent(current);
        final response = await _graph.graphCreateFolder(parent, segment);
        if (!response.isSuccess) {
          throw Exception('Failed to create remote dir: $current (${response.data})');
        }
        _log('Created remote dir: $current', level: LogLevel.success, type: LogMessageType.createdRemoteDir, params: {'path': current});
      }
    }
  }

  /// Lists children of a remote directory. Returns a list of (name, isFolder, size, lastModified).
  Future<List<RemoteItem>> listChildren(String remotePath) async {
    final response = await _graph.graphList(remotePath);
    if (!response.isSuccess || response.data == null) {
      throw Exception('Failed to list remote: $remotePath');
    }

    final json = jsonDecode(response.data!);
    final values = json['value'] as List?;
    if (values == null || values.isEmpty) return [];

    return values.map((item) {
      final name = item['name'] as String? ?? '';
      final isFolder = item.containsKey('folder');
      final size = (item['size'] as int?) ?? 0;
      final lastModified = item['lastModifiedDateTime'] != null
          ? DateTime.tryParse(item['lastModifiedDateTime'] as String)
          : null;
      return RemoteItem(name: name, isFolder: isFolder, size: size, lastModified: lastModified);
    }).toList();
  }

  /// Recursively counts files and total bytes under a remote path.
  Future<RemoteFileCounts> countFiles(String remotePath) async {
    int files = 0;
    int bytes = 0;

    final response = await _graph.graphList(remotePath);
    if (!response.isSuccess || response.data == null) {
      _log('Failed to scan remote dir: $remotePath', level: LogLevel.warning, type: LogMessageType.scanFailed, params: {'path': remotePath});
      return RemoteFileCounts(0, 0);
    }

    final json = jsonDecode(response.data!);
    final values = json['value'] as List? ?? [];

    final childFutures = <Future<RemoteFileCounts>>[];
    for (final item in values) {
      if (item.containsKey('folder')) {
        final name = item['name'] as String? ?? '';
        final childPath = remotePath.isEmpty ? name : '$remotePath/$name';
        childFutures.add(countFiles(childPath));
      } else {
        files++;
        bytes += (item['size'] as int?) ?? 0;
      }
    }

    final childResults = await Future.wait(childFutures);
    for (final child in childResults) {
      files += child.files;
      bytes += child.bytes;
    }

    return RemoteFileCounts(files, bytes);
  }

  String _parent(String remotePath) {
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
}

class RemoteItem {
  final String name;
  final bool isFolder;
  final int size;
  final DateTime? lastModified;

  RemoteItem({required this.name, required this.isFolder, this.size = 0, this.lastModified});
}

class RemoteFileCounts {
  final int files;
  final int bytes;
  RemoteFileCounts(this.files, this.bytes);
}
