class ProductReleasePlatform {
  const ProductReleasePlatform({
    required this.platform,
    required this.fileSize,
    required this.url,
    this.releaseNotes,
    this.status = 'latest',
    this.checksum,
  });

  final String platform;
  final String fileSize;
  final String url;
  final String? releaseNotes;
  final String status;
  final String? checksum;

  factory ProductReleasePlatform.fromJson(Map<String, dynamic> json) =>
      ProductReleasePlatform(
        platform: json['platform'] as String? ?? '',
        fileSize: json['fileSize'] as String? ?? '',
        url: json['url'] as String? ?? '',
        releaseNotes: json['releaseNotes'] as String?,
        status: json['status'] as String? ?? 'latest',
        checksum: json['checksum'] as String?,
      );
}

class ProductRelease {
  const ProductRelease({
    required this.version,
    required this.date,
    required this.platforms,
  });

  final String version;
  final String date;
  final List<ProductReleasePlatform> platforms;

  factory ProductRelease.fromJson(Map<String, dynamic> json) => ProductRelease(
        version: json['version'] as String? ?? '',
        date: json['date'] as String? ?? '',
        platforms: (json['platforms'] as List<dynamic>?)
                ?.map((e) => ProductReleasePlatform.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class Product {
  const Product({
    required this.id,
    required this.sortOrder,
    required this.slug,
    required this.name,
    required this.status,
    required this.tagline,
    required this.description,
    required this.category,
    required this.platforms,
    this.logo,
    required this.screenshots,
    required this.features,
    required this.demoAvailable,
    required this.downloadAvailable,
    required this.releases,
  });

  final String id;
  final int sortOrder;
  final String slug;
  final String name;
  final String status;
  final String tagline;
  final String description;
  final String category;
  final List<String> platforms;
  final String? logo;
  final List<String> screenshots;
  final List<String> features;
  final bool demoAvailable;
  final bool downloadAvailable;
  final List<ProductRelease> releases;

  bool get isLive => status == 'live';
  bool get isUpcoming => status == 'upcoming';

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String? ?? '',
        sortOrder: json['sortOrder'] as int? ?? 0,
        slug: json['slug'] as String? ?? '',
        name: json['name'] as String? ?? '',
        status: json['status'] as String? ?? 'upcoming',
        tagline: json['tagline'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? '',
        platforms: (json['platforms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        logo: json['logo'] as String?,
        screenshots: (json['screenshots'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        demoAvailable: json['demoAvailable'] as bool? ?? false,
        downloadAvailable: json['downloadAvailable'] as bool? ?? false,
        releases: (json['releases'] as List<dynamic>?)
                ?.map((e) => ProductRelease.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
