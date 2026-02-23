// services/adb_file_info_service.dart

import '../model/file_info.dart';
import 'adb_service.dart';

class AdbFileInfoService {
  final String deviceId;
  final String devicePath;
  AdbFileInfoService({required this.deviceId,required this.devicePath});

   Future<FileInfo> getFileInfo() async {
    final output = await AdbService.runShell(
      deviceId,
     'stat "$devicePath"',
    );
    print("file info abb output $output");

    return await _parseStatOutput(devicePath, output);
  }

   Future<FileInfo> _parseStatOutput(String path, String output) async{
    final lines = output.split('\n');

    int size = 0;
    bool isDirectory = false;
    String permissions = '';
    DateTime? access;
    DateTime? modify;
    DateTime? change;

    for (final line in lines) {
      final l = line.trim();

      /// Size + type
      if (l.startsWith('Size:')) {
        final sizeMatch = RegExp(r'Size:\s+(\d+)').firstMatch(l);
        if (sizeMatch != null) {
          size = int.parse(sizeMatch.group(1)!);
        }

        isDirectory = l.contains('directory');
      }

      /// Permissions
      if (l.startsWith('Access: (')) {
        final permMatch = RegExp(r'\((\d+\/[rwx\-]+)\)').firstMatch(l);
        if (permMatch != null) {
          permissions = permMatch.group(1)!;
        }
      }

      /// Access time
      if (l.startsWith('Access: ') && !l.contains('(')) {
        access = _parseDate(l.replaceFirst('Access: ', ''));
      }

      /// Modify time
      if (l.startsWith('Modify: ')) {
        modify = _parseDate(l.replaceFirst('Modify: ', ''));
      }

      /// Change time
      if (l.startsWith('Change: ')) {
        change = _parseDate(l.replaceFirst('Change: ', ''));
      }
    }
    ///is directory
    if(isDirectory){
      final result = await AdbService.runShell(
        deviceId,
        'du -sb "$devicePath"',
      );
      final output = result.toString().trim();
      size += int.parse(output.split(RegExp(r'\s+')).first);
    }

    return FileInfo(
      path: path,
      size: size,
      isDirectory: isDirectory,
      permissions: permissions,
      accessTime: access,
      modifyTime: modify,
      changeTime: change,
    );
  }

  static DateTime? _parseDate(String raw) {
    try {
      // Example: 2025-09-14 13:04:23.000000000 +0530
      final clean = raw.split('.').first;
      return DateTime.parse(clean.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }
}