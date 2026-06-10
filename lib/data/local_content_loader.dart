import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:vstackweb/models/site_models.dart';

/// Loads all website content from assets/content/site_content.json
class LocalContentLoader {
  static const assetPath = 'assets/content/site_content.json';

  static Future<SiteContent> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    List<T> parseList<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson,
    ) {
      final list = json[key] as List<dynamic>? ?? [];
      return list
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) {
          final ao = (a as dynamic).sortOrder as int;
          final bo = (b as dynamic).sortOrder as int;
          return ao.compareTo(bo);
        });
    }

    return SiteContent(
      site: SiteInfo.fromJson(json['site'] as Map<String, dynamic>? ?? {}),
      capabilities: parseList('capabilities', Capability.fromJson),
      projects: parseList('projects', Project.fromJson),
      team: parseList('team', TeamMember.fromJson),
      contact: ContactInfo.fromJson(json['contact'] as Map<String, dynamic>? ?? {}),
    );
  }
}
