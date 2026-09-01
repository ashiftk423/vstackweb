import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:vstackweb/features/tools/models/invoice_data.dart';
import 'package:vstackweb/features/tools/models/invoice_layout.dart';

class InvoicePdfBuilder {
  InvoicePdfBuilder._();

  static pw.ThemeData? _cachedTheme;
  static bool _fontLoadFailed = false;

  static Future<pw.ThemeData?> _loadTheme() async {
    if (_fontLoadFailed) return null;
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
      _fontLoadFailed = true;
      return null;
    }
  }

  static Future<List<int>> build(InvoiceData data) async {
    final theme = await _loadTheme();
    final unicodeLoaded = theme != null;
    final pdf = pw.Document(theme: theme);
    final fmt = (double v) => data.money(v, forPdf: true, unicodeFontLoaded: unicodeLoaded);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => switch (data.layout) {
          InvoiceLayout.classic => _buildClassic(data, fmt),
          InvoiceLayout.modern => _buildModern(data, fmt),
          InvoiceLayout.gstIndia => _buildGstIndia(data, fmt),
          InvoiceLayout.gulf => _buildGulf(data, fmt),
        },
      ),
    );
    return pdf.save();
  }

  static pw.Widget? _logo(InvoiceData data) {
    if (data.logoBytes == null) return null;
    return pw.Image(pw.MemoryImage(data.logoBytes!), width: 72, height: 72);
  }

  static pw.Widget _itemsTable(InvoiceData data, String Function(double) fmt) {
    return pw.TableHelper.fromTextArray(
      headers: ['Item', 'Qty', 'Rate', 'GST%', 'Amount'],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 10),
      data: [
        ...data.items.map((i) => [
              i.desc,
              _formatQty(i.qty),
              fmt(i.rate),
              _formatTax(i.tax),
              fmt(i.amount),
            ]),
        ['', '', '', 'Subtotal', fmt(data.subtotal)],
        ['', '', '', 'Tax', fmt(data.taxTotal)],
        ['', '', '', 'Total', fmt(data.total)],
      ],
    );
  }

  static String _formatQty(double qty) {
    if (qty % 1 == 0) return qty.toInt().toString();
    return qty.toStringAsFixed(2);
  }

  static String _formatTax(double tax) {
    if (tax % 1 == 0) return '${tax.toInt()}%';
    return '${tax.toStringAsFixed(1)}%';
  }

  static pw.Widget _footer() {
    return pw.Text('Powered by VSTACK', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600));
  }

  static pw.Widget _buildClassic(InvoiceData data, String Function(double) fmt) {
    final logo = _logo(data);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (logo != null)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              logo,
              pw.SizedBox(width: 12),
              pw.Expanded(child: _bizBlock(data)),
            ],
          )
        else
          _bizBlock(data),
        pw.SizedBox(height: 24),
        pw.Text('Invoice #${data.invNo}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text('Bill To: ${data.custName}'),
        if (data.custAddr.isNotEmpty) pw.Text(data.custAddr),
        pw.SizedBox(height: 16),
        _itemsTable(data, fmt),
        pw.Spacer(),
        _footer(),
      ],
    );
  }

  static pw.Widget _bizBlock(InvoiceData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(data.bizName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        if (data.bizAddr.isNotEmpty) pw.Text(data.bizAddr),
        if (data.bizGst.isNotEmpty) pw.Text('GSTIN: ${data.bizGst}'),
      ],
    );
  }

  static pw.Widget _buildModern(InvoiceData data, String Function(double) fmt) {
    final logo = _logo(data);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(color: PdfColors.blue800, width: 4)),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (logo != null) ...[logo, pw.SizedBox(width: 12)],
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(data.bizName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      if (data.bizAddr.isNotEmpty) pw.Text(data.bizAddr, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('INVOICE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('#${data.invNo}'),
                  pw.Text(data.currency.code, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bill To', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(data.custName),
                if (data.custAddr.isNotEmpty) pw.Text(data.custAddr, style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            if (data.bizGst.isNotEmpty)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Tax ID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text(data.bizGst),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 16),
        _itemsTable(data, fmt),
        pw.Spacer(),
        _footer(),
      ],
    );
  }

  static pw.Widget _buildGstIndia(InvoiceData data, String Function(double) fmt) {
    final logo = _logo(data);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text('TAX INVOICE', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              if (logo != null) pw.Padding(padding: const pw.EdgeInsets.only(top: 8), child: logo),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Text(data.bizName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        if (data.bizAddr.isNotEmpty) pw.Text(data.bizAddr, style: const pw.TextStyle(fontSize: 10)),
        if (data.bizGst.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text('GSTIN: ${data.bizGst}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          ),
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bill To', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(data.custName),
                if (data.custAddr.isNotEmpty) pw.Text(data.custAddr, style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Invoice No: ${data.invNo}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Currency: ${data.currency.code}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        _itemsTable(data, fmt),
        pw.Spacer(),
        _footer(),
      ],
    );
  }

  static pw.Widget _buildGulf(InvoiceData data, String Function(double) fmt) {
    final logo = _logo(data);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logo != null) logo,
        if (logo != null) pw.SizedBox(height: 12),
        pw.Text(data.bizName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
        if (data.bizAddr.isNotEmpty)
          pw.Text(data.bizAddr, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Invoice: ${data.invNo}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('To: ${data.custName}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Text(data.currency.code, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        if (data.custAddr.isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(top: 8), child: pw.Text(data.custAddr, style: const pw.TextStyle(fontSize: 10))),
        pw.SizedBox(height: 16),
        pw.Align(alignment: pw.Alignment.centerLeft, child: _itemsTable(data, fmt)),
        pw.Spacer(),
        _footer(),
      ],
    );
  }
}
