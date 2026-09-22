import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:vstackweb/constants/brand_assets.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/models/solution.dart';

/// Builds a WhatsApp-shareable PDF portfolio from the current solution works.
class MarketingPortfolioPdfBuilder {
  MarketingPortfolioPdfBuilder._();

  static const _baseUrl = 'https://vstackbusinesssolutions.com';

  static pw.ThemeData? _cachedTheme;

  static Future<pw.ThemeData?> _loadTheme() async {
    if (_cachedTheme != null) return _cachedTheme;
    try {
      final regular = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final bold = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      _cachedTheme = pw.ThemeData.withFont(
        base: pw.Font.ttf(regular),
        bold: pw.Font.ttf(bold),
      );
      return _cachedTheme;
    } catch (_) {
      return null;
    }
  }

  static Future<pw.MemoryImage?> _loadImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  static Future<List<int>> build({
    required Solution solution,
    required ContactInfo contact,
  }) async {
    final theme = await _loadTheme();
    final pdf = pw.Document(theme: theme);
    final pageUrl = '$_baseUrl/solutions/${solution.slug}';

    pw.MemoryImage? logo = await _loadImage(BrandAssets.logo);

    // Cover
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logo != null) pw.Image(logo, width: 64, height: 64),
            pw.SizedBox(height: 24),
            pw.Text(
              'VStack Business Solutions',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              solution.title,
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              solution.heroSubtitle,
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 2, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 28),
            pw.Text('Live page', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            pw.UrlLink(
              destination: pageUrl,
              child: pw.Text(
                pageUrl,
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.blue700,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ),
            pw.Spacer(),
            pw.Text(
              '${solution.works.length} selected works · Generated from live site content',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Contact: ${contact.email}'
              '${contact.phoneDisplay != null && contact.phoneDisplay!.isNotEmpty ? ' · ${contact.phoneDisplay}' : ''}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    );

    // Work pages (batch a few per page when short text)
    for (final work in solution.works) {
      final image = work.isVideo ? null : await _loadImage(work.media);
      final insight = work.hasInsightImage ? await _loadImage(work.insightImage!) : null;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      work.title,
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: work.isVideo ? PdfColors.indigo100 : PdfColors.teal50,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      work.isVideo ? 'VIDEO' : 'IMAGE',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              if (work.hasDescription)
                pw.Text(
                  work.description!,
                  style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5, color: PdfColors.grey800),
                ),
              if (work.hasDescription) pw.SizedBox(height: 12),
              if (image != null)
                pw.Center(
                  child: pw.Image(image, height: 320, fit: pw.BoxFit.contain),
                )
              else if (work.isVideo) ...[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Video reel / campaign clip',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Watch this piece on the live Digital Marketing page (best for WhatsApp sharing — full video stays online).',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 10),
                      pw.UrlLink(
                        destination: pageUrl,
                        child: pw.Text(
                          'Open: $pageUrl',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.blue700,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (insight != null) ...[
                pw.SizedBox(height: 16),
                pw.Text('Insights', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                pw.SizedBox(height: 8),
                pw.Center(child: pw.Image(insight, height: 200, fit: pw.BoxFit.contain)),
              ],
              pw.Spacer(),
              pw.UrlLink(
                destination: pageUrl,
                child: pw.Text(
                  pageUrl,
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return pdf.save();
  }
}
