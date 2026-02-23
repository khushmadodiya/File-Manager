import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../components/dialogue/delete_dialogue.dart';
import '../../components/snackbar.dart';
import '../../model/context_menu_item.dart';
import '../../model/device_file.dart';
import '../../model/file_info.dart';
import '../../provider/item_provider.dart';
import '../../provider/states/file_itme_state.dart';
import '../../components/context_menue.dart';
import '../../components/dialogue/download_dialogue.dart';
import '../../components/dialogue/file_info_dialogue.dart';
import '../../service/adb_service.dart';
import '../../service/file_info_service.dart';
import '../../utils/utils.dart';

class FileItem extends ConsumerStatefulWidget {
  final DeviceFile file;
  final String devicePath;
  final String deviceId;
  final VoidCallback? onOpen;
  final VoidCallback? reload;

  const FileItem({
    super.key,
    required this.file,
    required this.devicePath,
    required this.deviceId,
    this.onOpen,
    this.reload,
  });

  @override
  ConsumerState<FileItem> createState() => _FileItemState();
}

class _FileItemState extends ConsumerState<FileItem> {
  late final String providerKey;

  @override
  void initState() {
    super.initState();
    providerKey = '${widget.devicePath}/${widget.file.name}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.file.isDirectory && Utils().isImage(path: widget.file.name)) {
        _loadPreview();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fileItemProvider(providerKey));
    final notifier = ref.read(fileItemProvider(providerKey).notifier);
    return MouseRegion(
      onEnter: (_) {
        notifier.setHover(true);
      },
      onExit: (_) {
        notifier.setHover(false);
      },
      child: GestureDetector(
        onDoubleTap: widget.file.isDirectory ? widget.onOpen : null,
        // onSecondaryTapDown: (details) {
        //   _showContextMenu(context, details.globalPosition);
        // },
        behavior: HitTestBehavior.opaque,
        onSecondaryTapDown: (details) {
          showContextMenu(context, details.globalPosition, state);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: state.hover
                ? Colors.blue.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 🔹 Preview / Icon area (FIXED HEIGHT)
              SizedBox(height: 70, child: Center(child: _buildPreview(state))),

              const SizedBox(height: 4),

              /// 🔹 Text must be flexible
              Expanded(
                child: Text(
                  widget.file.name,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(FileItemState state) {
    if (state.previewFile != null &&
        Utils().isImage(file: state.previewFile!)) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(state.previewFile!, fit: BoxFit.cover));
    }
    return Icon(
      widget.file.isDirectory ? Icons.folder : Icons.insert_drive_file,
      size: 60,
      color: widget.file.isDirectory ? Color(0xff77BEE5) : Colors.grey.shade500,
    );
  }

  void showContextMenu(
    BuildContext context,
    Offset position,
    FileItemState state,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => entry.remove(),
              onDoubleTap: () {
                entry.remove();
                widget.file.isDirectory ? widget.onOpen?.call() : null;
              },
              onSecondaryTapUp: (val) => entry.remove(),
              behavior: HitTestBehavior.translucent,
            ),
          ),
          Positioned(
            left: position.dx,
            top: position.dy,
            child: MacosContextMenu(
              items: [
                ContextMenuItem(
                  label: 'Download',
                  icon: Icons.file_download_outlined,
                  onTap: () {
                    entry.remove();
                    _showDownloadBubble(context);
                  },
                ),
                ContextMenuItem(divider: true, label: '', icon: Icons.clear),
                ContextMenuItem(
                  label: 'Open',
                  icon: Icons.open_in_new_sharp,
                  onTap: () {
                    entry.remove();
                    widget.file.isDirectory
                        ? widget.onOpen?.call()
                        : prepareFile(state, () {
                            open();
                          });
                  },
                ),
                ContextMenuItem(divider: true, label: '', icon: Icons.clear),
                ContextMenuItem(
                  label: 'Delete',
                  icon: Icons.delete_outline_outlined,
                  onTap: () {
                    entry.remove();
                    showDeleteConfirmDialog(
                      context: context,
                      name: widget.file.name,
                      isDirectory: widget.file.isDirectory,
                      onDelete: () {
                        // delete or move to bin logic
                        deleteFileOrFolder();
                      },
                    );
                  },
                ),
                ContextMenuItem(divider: true, label: '', icon: Icons.clear),
                ContextMenuItem(
                  label: 'Get info',
                  icon: Icons.info_outline,
                  onTap: () {
                    entry.remove();
                    getFileInfo(context);
                  },
                ),
                ContextMenuItem(label: 'Rename', icon: Icons.edit),
                ContextMenuItem(divider: true, label: '', icon: Icons.clear),
                ContextMenuItem(label: 'Copy', icon: Icons.file_copy_outlined),
                ContextMenuItem(
                  label: 'Share',
                  icon: Icons.file_upload_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    overlay.insert(entry);
  }

  Future<void> _loadPreview() async {
    final notifier = ref.read(fileItemProvider(providerKey).notifier);
    final state = ref.read(fileItemProvider(providerKey));

    if (state.previewFile == null) {
      notifier.setLoading(true);
      final f = await AdbService().pullFile(
        devicePath: widget.devicePath,
        deviceId: widget.deviceId,
        fileName: widget.file.name,
      );
      notifier.setPreviewFile(f);
      notifier.setLoading(false);
    }
  }

  void _showDownloadBubble(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Downloading',
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (BuildContext context) {
        _startDownload(context);
        return Center(child: BubbleDownloadDialog());
      },
    );
  }

  void _showPreparingFileBubble(BuildContext context, VoidCallback finish) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Preparing File',
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (BuildContext context) {
        _startPreparingFile(context);
        return Center(child: BubbleDownloadDialog(msg: "Preparing file.."));
      },
    );
    Duration(seconds: 5);
    finish.call();
  }

  Future<void> _startPreparingFile(BuildContext context) async {
    try {
      final notifier = ref.read(fileItemProvider(providerKey).notifier);
      final state = ref.read(fileItemProvider(providerKey));

      if (state.previewFile == null) {
        final f = await AdbService().pullFile(
          devicePath: widget.devicePath,
          deviceId: widget.deviceId,
          fileName: widget.file.name,
        );
        notifier.setPreviewFile(f);
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: BubbleSnackBar(message: 'Download failed'),
        ),
      );
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> _startDownload(BuildContext context) async {
    try {
      final localPath = AdbService().getDownloadPath();
      await AdbService().pullFile(
        devicePath: widget.devicePath,
        deviceId: widget.deviceId,
        fileName: widget.file.name,
        localFilePath: "$localPath/${widget.file.name}",
      );
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: BubbleSnackBar(message: 'Download failed'),
        ),
      );
    } finally {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: BubbleSnackBar(message: 'Download completed'),
        ),
      );
      Navigator.of(context).pop(); // close dialog
    }
  }

  void prepareFile(FileItemState state, VoidCallback fun) {
    if (state.previewFile == null) {
      _showPreparingFileBubble(context, () {
        fun.call();
      });
    } else {
      fun.call();
    }
  }

  void open() {
    final state = ref.read(fileItemProvider(providerKey));
    try {
      Utils().openFile(state.previewFile!.path);
    } catch (e) {
      if (state.previewFile == null) {
        Future.delayed(Duration(seconds: 2)).then((val) {
          open();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: BubbleSnackBar(
              message: 'Can not open file : ${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  Future getFileInfo(BuildContext context) async {
    final info = await AdbFileInfoService(
      deviceId: widget.deviceId,
      devicePath: "${widget.devicePath}/${widget.file.name}",
    ).getFileInfo();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => FileInfoDialog(info: info),
    );
  }

  Future deleteFileOrFolder()async{
    await AdbService.deleteFile(
      deviceId: widget.deviceId,
      devicePath: widget.devicePath,
      fileName: widget.file.name,
      isDirectory: widget.file.isDirectory,
    );
    widget.reload?.call();
  }
}
