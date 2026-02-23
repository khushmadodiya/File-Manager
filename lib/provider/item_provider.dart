

import 'dart:io';
import 'package:android_to_mac_drop/provider/states/file_itme_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final fileItemProvider = StateNotifierProvider.autoDispose.family<
    FileItemNotifier,
    FileItemState,
    String>((ref, key) {
  return FileItemNotifier();
});

class FileItemNotifier extends StateNotifier<FileItemState> {
  FileItemNotifier() : super( FileItemState());

  void setHover(bool value) {
    if (state.hover == value) return; // ✅ FIXED
    state = state.copyWith(hover: value);
  }

  void setLoading(bool value) {
    if (state.isLoading == value) return;
    state = state.copyWith(isLoading: value);
  }

  void setPreviewFile(File? file) {
    state = state.copyWith(previewFile: file);
  }
}