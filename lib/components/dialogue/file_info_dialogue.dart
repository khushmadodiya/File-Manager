import 'package:flutter/material.dart';
import '../../model/file_info.dart';
import '../BubbleWidget.dart';

class FileInfoDialog extends StatelessWidget {
  final FileInfo info;

  const FileInfoDialog({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: BubbleWidget(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔹 Header
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF77BEE5)),
                  const SizedBox(width: 8),
                  const Text(
                    'File Info',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
        
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
        
              /// 🔹 Info rows
              _infoRow('Path', info.path),
              _infoRow('Type', info.isDirectory ? 'Folder' : 'File'),
              _infoRow('Size', _formatSize(info.size)),
              _infoRow('Permissions', info.permissions),
              if (info.modifyTime != null)
                _infoRow('Modified', info.modifyTime!.toString()),
        
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
        
              /// 🔹 Done button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF2C2C2C),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}