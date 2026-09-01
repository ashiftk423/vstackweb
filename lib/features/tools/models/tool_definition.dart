import 'package:flutter/material.dart';

enum ToolCategory {
  popular,
  image,
  pdf,
  business,
  marketing,
  developer,
  design,
}

enum ToolStatus { active, comingSoon, pro }

class ToolSeoMeta {
  const ToolSeoMeta({
    required this.title,
    required this.description,
    required this.h1,
    this.faq = const [],
  });

  final String title;
  final String description;
  final String h1;
  final List<(String, String)> faq;
}

class ToolDefinition {
  const ToolDefinition({
    required this.id,
    required this.name,
    required this.slug,
    required this.shortDescription,
    required this.description,
    required this.category,
    required this.icon,
    required this.keywords,
    required this.route,
    this.isPopular = false,
    this.isActive = true,
    this.isFree = true,
    this.requiresServer = false,
    this.status = ToolStatus.active,
    required this.seo,
    this.relatedToolIds = const [],
    this.tags = const [],
    this.howItWorks = const [],
    this.contextCtaLabel,
    this.contextCtaRoute,
  });

  final String id;
  final String name;
  final String slug;
  final String shortDescription;
  final String description;
  final ToolCategory category;
  final IconData icon;
  final List<String> keywords;
  final String route;
  final bool isPopular;
  final bool isActive;
  final bool isFree;
  final bool requiresServer;
  final ToolStatus status;
  final ToolSeoMeta seo;
  final List<String> relatedToolIds;
  final List<String> tags;
  final List<String> howItWorks;
  final String? contextCtaLabel;
  final String? contextCtaRoute;

  String get categoryLabel => switch (category) {
        ToolCategory.popular => 'Popular',
        ToolCategory.image => 'Image',
        ToolCategory.pdf => 'PDF',
        ToolCategory.business => 'Business',
        ToolCategory.marketing => 'Marketing',
        ToolCategory.developer => 'Developer',
        ToolCategory.design => 'Design',
      };
}
