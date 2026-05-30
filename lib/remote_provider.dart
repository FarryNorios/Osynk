import 'dart:convert';
import 'source_provider.dart';
import 'services/graph_service.dart';

class RemoteSourceProvider implements SourceProvider {
  final Future<GraphResponse> Function(String path) _listFn;

  RemoteSourceProvider(this._listFn);

  @override
  String get rootPath => '';

  @override
  String get rootName => 'OneDrive';

  @override
  Future<List<FileItem>> list(String path) async {
    final relativePath = path.replaceAll(RegExp(r'^/+'), '');
    final response = await _listFn(relativePath);
    if (!response.isSuccess || response.data == null) {
      throw Exception('Failed to list remote directory');
    }

    final json = jsonDecode(response.data!);
    final values = json['value'] as List?;
    if (values == null) return [];

    return values.map((item) {
      final name = item['name'] as String? ?? '';
      final isDir = item.containsKey('folder');
      final fullPath = relativePath.isEmpty ? '/$name' : '/$relativePath/$name';
      return FileItem(name: name, path: fullPath, isDirectory: isDir);
    }).toList();
  }
}
