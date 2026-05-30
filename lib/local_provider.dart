import 'dart:io';
import 'source_provider.dart';

class LocalSourceProvider implements SourceProvider {
  final String _rootName;
  LocalSourceProvider({String rootName = '内部存储'}) : _rootName = rootName;

  @override
  String get rootPath => '/storage/emulated/0';

  @override
  String get rootName => _rootName;

  @override
  Future<List<FileItem>> list(String path) async {
    final dir = Directory(path);
    final list = await dir.list().toList();
    return list
        .map((e) => FileItem(
              name: e.path.split(Platform.pathSeparator).last,
              path: e.path,
              isDirectory: e is Directory,
            ))
        .toList();
  }
}
