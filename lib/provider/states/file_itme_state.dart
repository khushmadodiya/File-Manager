// file_item_state.dart
import 'dart:io';


import '../../model/device_file.dart';

class FileItemState {
  final bool hover;
  final bool isLoading;
  final File? previewFile;
  final DeviceFile? fileDetails;

  const FileItemState({
    this.hover = false,
    this.isLoading = false,
    this.previewFile,
    this.fileDetails
  });

  FileItemState copyWith({
    bool? hover,
    bool? isLoading,
    File? previewFile,
    DeviceFile? fileDetails
  }) {
    return FileItemState(
      hover: hover ?? this.hover,
      isLoading: isLoading ?? this.isLoading,
      previewFile: previewFile ?? this.previewFile,
      fileDetails: fileDetails ?? this.fileDetails,
    );
  }
}