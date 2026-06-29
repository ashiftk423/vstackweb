class SiteContent {
  const SiteContent({
    required this.site,
    required this.about,
    required this.cta,
    required this.capabilities,
    required this.projects,
    required this.team,
    required this.contact,
  });

  final SiteInfo site;
  final AboutSection about;
  final CtaSection cta;
  final List<Capability> capabilities;
  final List<Project> projects;
  final List<TeamMember> team;
  final ContactInfo contact;
}

class SiteInfo {
  const SiteInfo({
    required this.companyName,
    required this.heroBadge,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.stats,
  });

  final String companyName;
  final String heroBadge;
  final String heroTitle;
  final String heroSubtitle;
  final List<StatItem> stats;

  factory SiteInfo.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'] as List<dynamic>? ?? [];
    return SiteInfo(
      companyName: json['companyName'] as String? ?? 'VStack Business Solutions',
      heroBadge: json['heroBadge'] as String? ?? '',
      heroTitle: json['heroTitle'] as String? ?? '',
      heroSubtitle: json['heroSubtitle'] as String? ?? '',
      stats: statsJson
          .map((e) => StatItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AboutSection {
  const AboutSection({
    required this.tag,
    required this.title,
    required this.text,
  });

  final String tag;
  final String title;
  final String text;

  factory AboutSection.fromJson(Map<String, dynamic> json) => AboutSection(
        tag: json['tag'] as String? ?? 'ABOUT US',
        title: json['title'] as String? ?? '',
        text: json['text'] as String? ?? '',
      );
}

class CtaSection {
  const CtaSection({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  factory CtaSection.fromJson(Map<String, dynamic> json) => CtaSection(
        title: json['title'] as String? ?? '',
        text: json['text'] as String? ?? '',
      );
}

class StatItem {
  const StatItem({required this.value, required this.label});

  final String value;
  final String label;

  factory StatItem.fromJson(Map<String, dynamic> json) => StatItem(
        value: json['value'] as String? ?? '',
        label: json['label'] as String? ?? '',
      );
}

class Capability {
  const Capability({
    required this.id,
    required this.sortOrder,
    required this.title,
    required this.description,
  });

  final String id;
  final int sortOrder;
  final String title;
  final String description;

  factory Capability.fromJson(Map<String, dynamic> json) => Capability(
        id: json['id'] as String? ?? '',
        sortOrder: json['sortOrder'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}

class Project {
  const Project({
    required this.id,
    required this.sortOrder,
    required this.title,
    required this.category,
    required this.description,
    required this.tech,
    required this.year,
    this.image,
    this.link,
  });

  final String id;
  final int sortOrder;
  final String title;
  final String category;
  final String description;
  final String tech;
  final String year;
  final String? image;
  final String? link;

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String? ?? '',
        sortOrder: json['sortOrder'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? '',
        description: json['description'] as String? ?? '',
        tech: json['tech'] as String? ?? '',
        year: json['year'] as String? ?? '',
        image: json['image'] as String?,
        link: json['link'] as String?,
      );
}

class TeamMember {
  const TeamMember({
    required this.id,
    required this.sortOrder,
    required this.name,
    required this.role,
    required this.bio,
    required this.initials,
    required this.isLeadership,
    this.photo,
  });

  final String id;
  final int sortOrder;
  final String name;
  final String role;
  final String bio;
  final String initials;
  final bool isLeadership;
  final String? photo;

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: json['id'] as String? ?? '',
        sortOrder: json['sortOrder'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        initials: json['initials'] as String? ?? '',
        isLeadership: json['isLeadership'] as bool? ?? false,
        photo: json['photo'] as String?,
      );
}

class ContactInfo {
  const ContactInfo({
    required this.email,
    required this.whatsappNumber,
    required this.location,
    required this.enquiryTypes,
  });

  final String email;
  final String whatsappNumber;
  final String location;
  final List<String> enquiryTypes;

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
        email: json['email'] as String? ?? '',
        whatsappNumber: json['whatsappNumber'] as String? ?? '',
        location: json['location'] as String? ?? '',
        enquiryTypes: (json['enquiryTypes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const ['New project'],
      );
}
