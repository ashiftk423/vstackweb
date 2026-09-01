class EnquiryConfig {
  const EnquiryConfig({
    required this.requirementTypes,
    required this.statuses,
  });

  final List<String> requirementTypes;
  final List<String> statuses;

  factory EnquiryConfig.fromJson(Map<String, dynamic> json) => EnquiryConfig(
        requirementTypes: (json['requirementTypes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        statuses: (json['statuses'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      );
}

/// Payload shape for future backend integration.
class EnquiryPayload {
  const EnquiryPayload({
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.requirementType,
    this.service,
    this.product,
    this.demo,
    required this.message,
    required this.source,
  });

  final String name;
  final String company;
  final String phone;
  final String email;
  final String requirementType;
  final String? service;
  final String? product;
  final String? demo;
  final String message;
  final String source;

  Map<String, String> toFields() => {
        'name': name,
        'company': company,
        'phone': phone,
        'email': email,
        'requirementType': requirementType,
        if (service != null) 'service': service!,
        if (product != null) 'product': product!,
        if (demo != null) 'demo': demo!,
        'message': message,
        'source': source,
      };
}
