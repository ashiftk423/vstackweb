class DemoEntry {
  const DemoEntry({
    required this.id,
    required this.sortOrder,
    required this.slug,
    required this.title,
    required this.category,
    required this.description,
    this.previewImage,
    required this.interactiveType,
    required this.featured,
  });

  final String id;
  final int sortOrder;
  final String slug;
  final String title;
  final String category;
  final String description;
  final String? previewImage;
  final String interactiveType;
  final bool featured;

  factory DemoEntry.fromJson(Map<String, dynamic> json) => DemoEntry(
        id: json['id'] as String? ?? '',
        sortOrder: json['sortOrder'] as int? ?? 0,
        slug: json['slug'] as String? ?? '',
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? '',
        description: json['description'] as String? ?? '',
        previewImage: json['previewImage'] as String?,
        interactiveType: json['interactiveType'] as String? ?? 'website',
        featured: json['featured'] as bool? ?? false,
      );
}
