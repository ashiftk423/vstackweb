enum InvoiceCurrency {
  inr('INR', '₹', 'Rs.'),
  usd('USD', r'$', 'USD'),
  eur('EUR', '€', 'EUR'),
  gbp('GBP', '£', 'GBP'),
  sar('SAR', 'SR', 'SAR'),
  aed('AED', 'AED', 'AED');

  const InvoiceCurrency(this.code, this.symbol, this.prefix);

  final String code;
  final String symbol;
  final String prefix;

  String formatUi(double amount) => '$symbol${amount.toStringAsFixed(2)}';

  String formatPdf(double amount, {required bool unicodeFontLoaded}) {
    if (unicodeFontLoaded) return formatUi(amount);
    return '$prefix ${amount.toStringAsFixed(2)}';
  }
}
