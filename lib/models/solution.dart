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

  bool get showOnHome =>
      const {
        'software-business-solutions',
        'digital-marketing',
        'hardware-it',
        'cctv-security',
        'custom-websites-apps',
      }.contains(slug);

  factory Solution.fromJson(Map<String, dynamic> json) => Solution(
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
      );
}
