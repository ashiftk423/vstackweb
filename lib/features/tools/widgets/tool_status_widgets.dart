import 'package:flutter/material.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

enum ToolMessageType { info, success, error }

class ToolStatusMessage extends StatelessWidget {
  const ToolStatusMessage({
    super.key,
    required this.message,
    this.type = ToolMessageType.info,
  });

  final String message;
  final ToolMessageType type;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (type) {
      ToolMessageType.success => (const Color(0xFF34C759), Icons.check_circle_outline),
      ToolMessageType.error => (Colors.redAccent, Icons.error_outline),
      ToolMessageType.info => (VStackColors.accent, Icons.info_outline),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: color, height: 1.4))),
        ],
      ),
    );
  }
}

class ToolProcessingIndicator extends StatelessWidget {
  const ToolProcessingIndicator({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: VStackColors.muted)),
      ],
    );
  }
}

class ToolDownloadButton extends StatelessWidget {
  const ToolDownloadButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.download_rounded,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class ToolResultCard extends StatelessWidget {
  const ToolResultCard({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VStackColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VStackColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.$1, style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
                  Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
