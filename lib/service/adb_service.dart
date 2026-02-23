import 'dart:io';

import '../model/device.dart';
import '../model/device_file.dart';
import '../output_parser/parser.dart';

class AdbService {
  static const String adbPath = '/opt/homebrew/bin/adb';
  String shellSafe(String path) => "$path";
  static Future<String> run(List<String> args) async {
    final result = await Process.run(
      adbPath,
      args,
    );

    if (result.exitCode != 0) {
      throw Exception(result.stderr.toString());
    }

    return result.stdout.toString();
  }
  static Future<String> runShell(
      String deviceId,
      String shellCommand,
      ) async {
    final result = await Process.run(
      adbPath,
      ['-s', deviceId, 'shell', shellCommand],
    );

    if (result.exitCode != 0) {
      throw Exception(result.stderr.toString());
    }

    return result.stdout.toString();
  }
  static Future<List<Device>> getDevices() async {
    final output = await run(['devices', '-l']);
    return OutputParser.parseAdbOutput(output);
  }

  static Future<List<DeviceFile>> listFiles(String path, String deviceId) async {
    print("listFiles path $path");

    final output = await runShell(
      deviceId,
      'ls -t "$path"',
    );

    print(output);
    List<DeviceFile> files = output
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .map((e) => DeviceFile(
      name: e.trim(),
      isDirectory: !e.contains("."),
    )).toList();
    return files;
  }



  Future<File> pullFile({
    required String devicePath,
    required String deviceId,
    required String fileName,
    String? localFilePath
  }) async {
    final tempDir = Directory.systemTemp;
    final localPath = localFilePath ?? '${tempDir.path}/$fileName';

    final parentDir = Directory(File(localPath).parent.path);
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }
    print("locapath $localPath");
    print("filepath $devicePath");
    print("deviceId $deviceId");
    await run([
      '-s',
      deviceId,
      'pull',
      '$devicePath/$fileName',
      localPath,
    ]);

    return File(localPath);
  }

  String getDownloadPath() {
    final home = Platform.environment['HOME'];
    if (home == null) {
      throw Exception('HOME directory not found');
    }
    return '$home/Downloads';
  }

  static Future<void> deleteFile({
    required String deviceId,
    required String devicePath,
    required String fileName,
    bool isDirectory = false,
  }) async {
    final fullPath = '$devicePath/$fileName';

    final args = [
      '-s',
      deviceId,
      'shell',
      'rm',
      if (isDirectory) '-r',
      '"$fullPath"',
    ];

    final result = await Process.run(adbPath, args);

    if (result.exitCode != 0) {
      throw Exception(result.stderr.toString());
    }
  }
}