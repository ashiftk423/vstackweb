import 'package:url_launcher/url_launcher.dart';

/// Opens the user's email app or WhatsApp with a pre-filled enquiry draft.
class EnquiryLauncher {
  static String whatsappDigits(String number) =>
      number.replaceAll(RegExp(r'[^0-9]'), '');

  static Future<bool> openEmailDraft({
    required String to,
    required String subject,
    required String body,
  }) {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      query: _encodeQuery({
        'subject': subject,
        'body': body,
      }),
    );
    return launchUrl(uri);
  }

  static Future<bool> openWhatsAppDraft({
    required String whatsappNumber,
    required String message,
  }) {
    final uri = Uri.parse(
      'https://wa.me/${whatsappDigits(whatsappNumber)}?text=${Uri.encodeComponent(message)}',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static String? _encodeQuery(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
  }
}
