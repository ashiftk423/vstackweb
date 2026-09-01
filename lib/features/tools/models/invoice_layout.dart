enum InvoiceLayout {
  classic('Classic', 'Universal invoice'),
  modern('Modern', 'US / International'),
  gstIndia('GST India', 'India tax invoice'),
  gulf('Gulf', 'Middle East');

  const InvoiceLayout(this.label, this.description);

  final String label;
  final String description;
}
