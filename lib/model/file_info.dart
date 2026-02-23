// models/file_info.dart
class FileInfo {
  final String path;
  final int size;
  final bool isDirectory;
  final String permissions;
  final DateTime? accessTime;
  final DateTime? modifyTime;
  final DateTime? changeTime;

  FileInfo({
    required this.path,
    required this.size,
    required this.isDirectory,
    required this.permissions,
    this.accessTime,
    this.modifyTime,
    this.changeTime,
  });

  @override
  String toString() {
    return '''
FileInfo(
  path: $path,
  size: $size,
  isDirectory: $isDirectory,
  permissions: $permissions,
  access: $accessTime,
  modify: $modifyTime,
  change: $changeTime
)
''';
  }
}