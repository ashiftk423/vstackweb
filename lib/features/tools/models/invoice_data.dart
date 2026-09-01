import 'dart:typed_data';

import 'package:vstackweb/features/tools/models/invoice_currency.dart';
import 'package:vstackweb/features/tools/models/invoice_layout.dart';

class InvoiceLineItemData {
  const InvoiceLineItemData({
    required this.desc,
    required this.qty,
    required this.rate,
    required this.tax,
  });

  final String desc;
  final double qty;
  final double rate;
  final double tax;

  double get amount => qty * rate;
  double get taxAmount => amount * tax / 100;
}

class InvoiceData {
  const InvoiceData({
    required this.bizName,
    required this.bizAddr,
    required this.bizGst,
    required this.custName,
    required this.custAddr,
    required this.invNo,
    required this.items,
    required this.currency,
    required this.layout,
    this.logoBytes,
  });

  final String bizName;
  final String bizAddr;
  final String bizGst;
  final String custName;
  final String custAddr;
  final String invNo;
  final List<InvoiceLineItemData> items;
  final InvoiceCurrency currency;
  final InvoiceLayout layout;
  final Uint8List? logoBytes;

  double get subtotal => items.fold(0, (s, i) => s + i.amount);
  double get taxTotal => items.fold(0, (s, i) => s + i.taxAmount);
  double get total => subtotal + taxTotal;

  String money(double amount, {required bool forPdf, required bool unicodeFontLoaded}) {
    if (forPdf) return currency.formatPdf(amount, unicodeFontLoaded: unicodeFontLoaded);
    return currency.formatUi(amount);
  }
}
