/// Resolves page title, description, and canonical path for site-wide SEO.
library;

import 'package:vstackweb/models/site_models.dart';

class SiteSeoMeta {
  const SiteSeoMeta({
    required this.title,
    required this.description,
    required this.canonicalPath,
  });

  final String title;
  final String description;
  final String canonicalPath;
}

abstract final class SiteSeoDefaults {
  static const baseUrl = 'https://vstackbusinesssolutions.com';
  static const siteTitle = 'VStack Business Solutions';
  static const defaultTitle =
      'We Stack Your Business | VStack Business Solutions — Best Software Company Kerala & India';
  static const defaultDescription =
      'VStack Business Solutions — custom software, billing & POS, Flutter apps, websites, digital marketing, hardware, CCTV & complete IT in Kerala, India. vstackitsolutions@gmail.com · +91 81568 25205';
}

SiteSeoMeta resolveSiteSeo(SiteContent content, String path) {
  final normalized = path.isEmpty ? '/' : path;
  if (normalized == '/') {
    return const SiteSeoMeta(
      title: SiteSeoDefaults.defaultTitle,
      description: SiteSeoDefaults.defaultDescription,
      canonicalPath: '/',
    );
  }

  if (normalized == '/solutions') {
    return SiteSeoMeta(
      title: 'Business Solutions | ${SiteSeoDefaults.siteTitle}',
      description:
          'Software, digital marketing, hardware, CCTV, websites & apps — complete business technology from VStack in Kerala & India.',
      canonicalPath: '/solutions',
    );
  }

  if (normalized.startsWith('/solutions/')) {
    final slug = normalized.split('/').last;
    final s = content.solutionBySlug(slug);
    if (s != null) {
      return SiteSeoMeta(
        title: '${s.title} | ${SiteSeoDefaults.siteTitle}',
        description: '${s.shortDescription} — Kerala & India. ${SiteSeoDefaults.siteTitle}.',
        canonicalPath: '/solutions/$slug',
      );
    }
  }

  if (normalized == '/products') {
    return SiteSeoMeta(
      title: 'Products | ${SiteSeoDefaults.siteTitle}',
      description:
          'VStack-owned products — QuickRent rental management, and upcoming platforms. Built in Kerala, India.',
      canonicalPath: '/products',
    );
  }

  if (normalized.startsWith('/products/')) {
    final slug = normalized.split('/').last;
    final p = content.productBySlug(slug);
    if (p != null) {
      return SiteSeoMeta(
        title: '${p.name} — ${p.category} | ${SiteSeoDefaults.siteTitle}',
        description: '${p.tagline} ${p.description}',
        canonicalPath: '/products/$slug',
      );
    }
  }

  if (normalized == '/work') {
    return SiteSeoMeta(
      title: 'Our Work & Client Projects | ${SiteSeoDefaults.siteTitle}',
      description:
          'Selected client projects delivered by VStack — websites, mobile apps, and business software in Kerala and worldwide.',
      canonicalPath: '/work',
    );
  }

  if (normalized.startsWith('/work/')) {
    final slug = normalized.split('/').last;
    final w = content.workBySlug(slug);
    if (w != null) {
      return SiteSeoMeta(
        title: '${w.title} | ${SiteSeoDefaults.siteTitle}',
        description: w.description,
        canonicalPath: '/work/$slug',
      );
    }
  }

  if (normalized == '/about') {
    return SiteSeoMeta(
      title: 'About Us | ${SiteSeoDefaults.siteTitle}',
      description: content.about.text.split('\n').first.trim(),
      canonicalPath: '/about',
    );
  }

  if (normalized == '/contact') {
    return SiteSeoMeta(
      title: 'Contact | ${SiteSeoDefaults.siteTitle}',
      description:
          'Contact VStack Business Solutions — ${content.contact.email} · ${content.contact.phoneDisplay}. Kerala, India · Remote worldwide.',
      canonicalPath: '/contact',
    );
  }

  if (normalized == '/careers') {
    return SiteSeoMeta(
      title: 'Careers & Vacancies | ${SiteSeoDefaults.siteTitle}',
      description:
          'VStack is hiring Flutter, Frontend, and Backend developers in Kerala. Send CV to ${content.careers.cvEmail}.',
      canonicalPath: '/careers',
    );
  }

  if (normalized == '/start-project') {
    return SiteSeoMeta(
      title: 'Start a Project | ${SiteSeoDefaults.siteTitle}',
      description:
          'Tell VStack about your software, website, marketing, or IT project. Get a tailored quote from our Kerala-based team.',
      canonicalPath: '/start-project',
    );
  }

  if (normalized == '/tools') {
    return const SiteSeoMeta(
      title: 'Free Online Tools | ${SiteSeoDefaults.siteTitle}',
      description:
          'Free browser tools — GST calculator, invoice generator, QR codes, PDF merge, image compress, JSON formatter and more. By VStack Business Solutions, Kerala India.',
      canonicalPath: '/tools',
    );
  }

  if (normalized.startsWith('/tools/')) {
    return const SiteSeoMeta(
      title: SiteSeoDefaults.defaultTitle,
      description: SiteSeoDefaults.defaultDescription,
      canonicalPath: '/tools',
    );
  }
  return const SiteSeoMeta(
    title: SiteSeoDefaults.defaultTitle,
    description: SiteSeoDefaults.defaultDescription,
    canonicalPath: '/',
  );
}
