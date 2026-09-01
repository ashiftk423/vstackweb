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
    required this.showcaseCategory,
    this.skills = const [],
    this.highlights = const [],
    this.modelAsset,
    this.accentColor,
    this.architectureNote,
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
  final String showcaseCategory;
  final List<String> skills;
  final List<String> highlights;
  final String? modelAsset;
  final String? accentColor;
  final String? architectureNote;

  factory DemoEntry.fromJson(Map<String, dynamic> json) => DemoEntry(
        id: json['id'] as String? ?? '',
        sortOrder: json['sortOrder'] as int? ?? 0,
        slug: json['slug'] as String? ?? '',
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? '',
        description: json['description'] as String? ?? '',
        previewImage: json['previewImage'] as String?,
        interactiveType: json['interactiveType'] as String? ?? 'website-saas',
        featured: json['featured'] as bool? ?? false,
        showcaseCategory: json['showcaseCategory'] as String? ?? 'website',
        skills: (json['skills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        highlights: (json['highlights'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        modelAsset: json['modelAsset'] as String?,
        accentColor: json['accentColor'] as String?,
        architectureNote: json['architectureNote'] as String?,
      );

  static const showcaseCategories = [
    ('all', 'All'),
    ('website', 'Websites'),
    ('desktop', 'Desktop Apps'),
    ('mobile', 'Mobile Apps'),
    ('motion', 'Motion & UI'),
    ('3d', '3D & Games'),
  ];
}
