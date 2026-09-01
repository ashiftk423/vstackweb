import 'package:flutter/material.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class EnquirySendButtons extends StatelessWidget {
  const EnquirySendButtons({
    super.key,
    required this.onEmail,
    required this.onWhatsApp,
    this.compact = false,
  });

  final VoidCallback onEmail;
  final VoidCallback onWhatsApp;
  final bool compact;

  static const _whatsappGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: onEmail,
          icon: const Icon(Icons.email_outlined, size: 18),
          label: Text(compact ? 'Email' : 'Send via Email'),
        ),
        OutlinedButton.icon(
          onPressed: onWhatsApp,
          style: OutlinedButton.styleFrom(
            foregroundColor: _whatsappGreen,
            side: const BorderSide(color: _whatsappGreen),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          icon: const Icon(Icons.chat_outlined, size: 18),
          label: Text(compact ? 'WhatsApp' : 'Send via WhatsApp'),
        ),
      ],
    );
  }
}

void showEnquiryLaunchSnackBar(BuildContext context, {required bool isWhatsApp}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isWhatsApp
            ? 'Opening WhatsApp with your enquiry draft…'
            : 'Opening your email app with your enquiry draft…',
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: VStackColors.surface,
    ),
  );
}
