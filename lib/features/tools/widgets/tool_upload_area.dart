import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class ToolUploadArea extends StatelessWidget {
  const ToolUploadArea({
    super.key,
    required this.onPick,
    this.label = 'Upload Image',
    this.hint = 'Drag & Drop or Browse',
    this.formats = 'JPG • PNG • WebP',
    this.allowMultiple = false,
  });

  final VoidCallback onPick;
  final String label;
  final String hint;
  final String formats;
  final bool allowMultiple;

  static Future<List<PlatformFile>> pickFiles({
    required FileType type,
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: allowMultiple,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    return result?.files ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(VStackRadius.lg),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VStackRadius.lg),
            border: Border.all(color: VStackColors.accent.withValues(alpha: 0.35), width: 1.5),
            color: VStackColors.surfaceLight.withValues(alpha: 0.5),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined, size: 36, color: VStackColors.accent.withValues(alpha: 0.8)),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              Text(hint, style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
              const SizedBox(height: 8),
              Text(formats, style: TextStyle(color: VStackColors.muted.withValues(alpha: 0.7), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
