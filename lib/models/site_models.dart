import 'package:vstackweb/data/site_data.dart' as demo;

class SiteSettings {
  const SiteSettings({
    required this.heroBadge,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.stat1Value,
    required this.stat1Label,
    required this.stat2Value,
    required this.stat2Label,
    required this.stat3Value,
    required this.stat3Label,
    required this.contactEmail,
    required this.whatsappNumber,
    required this.enquiryTypes,
  });

  final String heroBadge;
  final String heroTitle;
  final String heroSubtitle;
  final String stat1Value;
  final String stat1Label;
  final String stat2Value;
  final String stat2Label;
  final String stat3Value;
  final String stat3Label;
  final String contactEmail;
  final String whatsappNumber;
  final List<String> enquiryTypes;

  factory SiteSettings.defaults() => const SiteSettings(
        heroBadge: 'Software company · Kerala · Remote worldwide',
        heroTitle: 'We build software\nthat proves what we can do.',
        heroSubtitle:
            'VStack IT Solutions delivers web apps, mobile products, and cloud systems — with scroll-perfect animations and polish your clients will remember.',
        stat1Value: '40+',
        stat1Label: 'Projects shipped',
        stat2Value: '12',
        stat2Label: 'Team specialists',
        stat3Value: '8 yrs',
        stat3Label: 'Building products',
        contactEmail: 'hello@vstackitsolutions.com',
        whatsappNumber: '919876543210',
        enquiryTypes: demo.enquiryTypes,
      );

  factory SiteSettings.fromMap(Map<String, dynamic> m) {
    return SiteSettings(
      heroBadge: m['heroBadge'] as String? ?? SiteSettings.defaults().heroBadge,
      heroTitle: m['heroTitle'] as String? ?? SiteSettings.defaults().heroTitle,
      heroSubtitle: m['heroSubtitle'] as String? ?? SiteSettings.defaults().heroSubtitle,
      stat1Value: m['stat1Value'] as String? ?? '40+',
      stat1Label: m['stat1Label'] as String? ?? 'Projects shipped',
      stat2Value: m['stat2Value'] as String? ?? '12',
      stat2Label: m['stat2Label'] as String? ?? 'Team specialists',
      stat3Value: m['stat3Value'] as String? ?? '8 yrs',
      stat3Label: m['stat3Label'] as String? ?? 'Building products',
      contactEmail: m['contactEmail'] as String? ?? SiteSettings.defaults().contactEmail,
      whatsappNumber: m['whatsappNumber'] as String? ?? SiteSettings.defaults().whatsappNumber,
      enquiryTypes: (m['enquiryTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          demo.enquiryTypes,
    );
  }

  Map<String, dynamic> toMap() => {
        'heroBadge': heroBadge,
        'heroTitle': heroTitle,
        'heroSubtitle': heroSubtitle,
        'stat1Value': stat1Value,
        'stat1Label': stat1Label,
        'stat2Value': stat2Value,
        'stat2Label': stat2Label,
        'stat3Value': stat3Value,
        'stat3Label': stat3Label,
        'contactEmail': contactEmail,
        'whatsappNumber': whatsappNumber,
        'enquiryTypes': enquiryTypes,
      };
}

class ProjectDoc {
  const ProjectDoc({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.tech,
    required this.year,
    required this.sortOrder,
    this.imageUrl,
    this.imageStoragePath,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String tech;
  final String year;
  final int sortOrder;
  final String? imageUrl;
  final String? imageStoragePath;

  factory ProjectDoc.fromMap(String id, Map<String, dynamic> m) {
    return ProjectDoc(
      id: id,
      title: m['title'] as String? ?? '',
      category: m['category'] as String? ?? '',
      description: m['description'] as String? ?? '',
      tech: m['tech'] as String? ?? '',
      year: m['year'] as String? ?? '',
      sortOrder: m['sortOrder'] as int? ?? 0,
      imageUrl: m['imageUrl'] as String?,
      imageStoragePath: m['imageStoragePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'description': description,
        'tech': tech,
        'year': year,
        'sortOrder': sortOrder,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (imageStoragePath != null) 'imageStoragePath': imageStoragePath,
      };

  demo.ProjectItem toItem() => demo.ProjectItem(
        title: title,
        category: category,
        description: description,
        tech: tech,
        year: year,
      );

  static ProjectDoc fromDemo(demo.ProjectItem p, int order, {String? id}) {
    return ProjectDoc(
      id: id ?? '',
      title: p.title,
      category: p.category,
      description: p.description,
      tech: p.tech,
      year: p.year,
      sortOrder: order,
    );
  }
}

class TeamDoc {
  const TeamDoc({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    required this.initials,
    required this.isLeadership,
    required this.sortOrder,
    this.photoUrl,
    this.photoStoragePath,
  });

  final String id;
  final String name;
  final String role;
  final String bio;
  final String initials;
  final bool isLeadership;
  final int sortOrder;
  final String? photoUrl;
  final String? photoStoragePath;

  factory TeamDoc.fromMap(String id, Map<String, dynamic> m) {
    return TeamDoc(
      id: id,
      name: m['name'] as String? ?? '',
      role: m['role'] as String? ?? '',
      bio: m['bio'] as String? ?? '',
      initials: m['initials'] as String? ?? '',
      isLeadership: m['isLeadership'] as bool? ?? false,
      sortOrder: m['sortOrder'] as int? ?? 0,
      photoUrl: m['photoUrl'] as String?,
      photoStoragePath: m['photoStoragePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'role': role,
        'bio': bio,
        'initials': initials,
        'isLeadership': isLeadership,
        'sortOrder': sortOrder,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (photoStoragePath != null) 'photoStoragePath': photoStoragePath,
      };

  demo.TeamMember toMember() => demo.TeamMember(
        name: name,
        role: role,
        bio: bio,
        initials: initials,
        isLeadership: isLeadership,
      );

  static TeamDoc fromDemo(demo.TeamMember m, int order, {String? id}) {
    return TeamDoc(
      id: id ?? '',
      name: m.name,
      role: m.role,
      bio: m.bio,
      initials: m.initials,
      isLeadership: m.isLeadership,
      sortOrder: order,
    );
  }
}

class CapabilityDoc {
  const CapabilityDoc({
    required this.id,
    required this.title,
    required this.description,
    required this.sortOrder,
  });

  final String id;
  final String title;
  final String description;
  final int sortOrder;

  factory CapabilityDoc.fromMap(String id, Map<String, dynamic> m) {
    return CapabilityDoc(
      id: id,
      title: m['title'] as String? ?? '',
      description: m['description'] as String? ?? '',
      sortOrder: m['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'sortOrder': sortOrder,
      };
}

class SiteContent {
  const SiteContent({
    required this.settings,
    required this.projects,
    required this.team,
    required this.capabilities,
    required this.fromFirebase,
  });

  final SiteSettings settings;
  final List<ProjectDoc> projects;
  final List<TeamDoc> team;
  final List<CapabilityDoc> capabilities;
  final bool fromFirebase;

  factory SiteContent.defaults() {
    return SiteContent(
      settings: SiteSettings.defaults(),
      projects: demo.projects
          .asMap()
          .entries
          .map((e) => ProjectDoc.fromDemo(e.value, e.key))
          .toList(),
      team: demo.team.asMap().entries.map((e) => TeamDoc.fromDemo(e.value, e.key)).toList(),
      capabilities: demo.capabilities
          .asMap()
          .entries
          .map(
            (e) => CapabilityDoc(
              id: '',
              title: e.value.$1,
              description: e.value.$2,
              sortOrder: e.key,
            ),
          )
          .toList(),
      fromFirebase: false,
    );
  }
}
