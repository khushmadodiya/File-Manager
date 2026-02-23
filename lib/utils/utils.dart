import 'dart:io';

import 'package:open_filex/open_filex.dart';

class Utils {
  bool isImage({File? file, String? path}) {
    final filePath = path ?? file?.path ?? '';
    final ext = filePath.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(ext);
  }

  Future<void> openFile(String path) async {
    final result = await OpenFilex.open(path);
    print("can not open file ${result.message}"); // success / error
  }
}
