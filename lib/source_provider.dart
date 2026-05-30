abstract class SourceProvider {
  Future<List<FileItem>> list(String path);
  String get rootPath;
  String get rootName;
}

class FileItem {
  final String name;
  final String path;
  final bool isDirectory;

  FileItem({required this.name, required this.path, required this.isDirectory});
}
