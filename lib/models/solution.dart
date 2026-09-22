class SolutionWork {
  const SolutionWork({
    required this.id,
    required this.title,
    required this.mediaType,
    required this.media,
    this.description,
    this.insightImage,
  });

  final String id;
  final String title;

  /// `image` or `video`
  final String mediaType;
  final String media;
  final String? description;
  final String? insightImage;

  bool get isVideo => mediaType.toLowerCase() == 'video';
  bool get hasDescription => description != null && description!.trim().isNotEmpty;
  bool get hasInsightImage => insightImage != null && insightImage!.trim().isNotEmpty;
  bool get hasMoreInfo => hasDescription || hasInsightImage;

  factory SolutionWork.fromJson(Map<String, dynamic> json) {
    String? opt(String key) {
      final v = json[key];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return SolutionWork(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mediaType: json['mediaType'] as String? ?? 'image',
      media: json['media'] as String? ?? '',
      description: opt('description'),
      insightImage: opt('insightImage'),
    );
  }
}

class SolutionDifferentiator {
  const SolutionDifferentiator({required this.title, required this.body});

  final String title;
  final String body;

  factory SolutionDifferentiator.fromJson(Map<String, dynamic> json) => SolutionDifferentiator(
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );
}

class Solution {
  const Solution({
    required this.id,
    required this.sortOrder,
    required this.slug,
    required this.title,
    required this.shortDescription,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.problem,
    required this.solutionText,
    required this.features,
    required this.process,
    required this.ctaLabel,
    required this.ctaRoute,
    required this.icon,
    required this.homeCardDescription,
    this.works = const [],
    this.differentiators = const [],
    this.differentiatorsTitle = "Why we're different",
    this.worksIntro,
  });

  final String id;
  final int sortOrder;
  final String slug;
  final String title;
  final String shortDescription;
  final String heroTitle;
  final String heroSubtitle;
  final String problem;
  final String solutionText;
  final List<String> features;
  final List<String> process;
  final String ctaLabel;
  final String ctaRoute;
  final String icon;
  final String homeCardDescription;
  final List<SolutionWork> works;
  final List<SolutionDifferentiator> differentiators;
  final String differentiatorsTitle;
  final String? worksIntro;

  bool get showOnHome =>
      const {
        'software-business-solutions',
        'digital-marketing',
        'hardware-it',
        'cctv-security',
        'custom-websites-apps',
      }.contains(slug);

  factory Solution.fromJson(Map<String, dynamic> json) {
    final worksIntroRaw = json['worksIntro']?.toString().trim();
    return Solution(
      id: json['id'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      heroTitle: json['heroTitle'] as String? ?? '',
      heroSubtitle: json['heroSubtitle'] as String? ?? '',
      problem: json['problem'] as String? ?? '',
      solutionText: json['solutionText'] as String? ?? '',
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      process: (json['process'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      ctaLabel: json['ctaLabel'] as String? ?? 'Start a Project',
      ctaRoute: json['ctaRoute'] as String? ?? '/start-project',
      icon: json['icon'] as String? ?? 'build',
      homeCardDescription: json['homeCardDescription'] as String? ?? '',
      works: (json['works'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => SolutionWork.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      differentiators: (json['differentiators'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => SolutionDifferentiator.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      differentiatorsTitle: (json['differentiatorsTitle'] as String?)?.trim().isNotEmpty == true
          ? (json['differentiatorsTitle'] as String).trim()
          : "Why we're different",
      worksIntro: (worksIntroRaw == null || worksIntroRaw.isEmpty) ? null : worksIntroRaw,
    );
  }
}
