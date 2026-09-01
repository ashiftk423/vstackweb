class WorkProject {
  const WorkProject({
    required this.id,
    required this.sortOrder,
    required this.slug,
    required this.title,
    required this.category,
    required this.description,
    required this.challenge,
    required this.solution,
    required this.features,
    required this.tech,
    required this.year,
    required this.images,
    this.link,
  });

  final String id;
  final int sortOrder;
  final String slug;
  final String title;
  final String category;
  final String description;
  final String challenge;
  final String solution;
  final List<String> features;
  final String tech;
  final String year;
  final List<String> images;
  final String? link;

  String? get primaryImage => images.isNotEmpty ? images.first : null;

  factory WorkProject.fromJson(Map<String, dynamic> json) => WorkProject(
        id: json['id'] as String? ?? '',
        sortOrder: json['sortOrder'] as int? ?? 0,
        slug: json['slug'] as String? ?? '',
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? '',
        description: json['description'] as String? ?? '',
        challenge: json['challenge'] as String? ?? '',
        solution: json['solution'] as String? ?? '',
        features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        tech: json['tech'] as String? ?? '',
        year: json['year'] as String? ?? '',
        images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        link: json['link'] as String?,
      );
}
