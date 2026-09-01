import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/layouts/app_shell.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/pages/about_page.dart';
import 'package:vstackweb/pages/careers_page.dart';
import 'package:vstackweb/pages/contact_page.dart';
import 'package:vstackweb/pages/demo_lab/demo_detail_page.dart';
import 'package:vstackweb/pages/demo_lab/demo_lab_page.dart';
import 'package:vstackweb/pages/home_page.dart';
import 'package:vstackweb/pages/products/product_detail_page.dart';
import 'package:vstackweb/pages/products/products_page.dart';
import 'package:vstackweb/pages/solutions/solution_detail_page.dart';
import 'package:vstackweb/pages/solutions/solutions_hub_page.dart';
import 'package:vstackweb/pages/start_project_page.dart';
import 'package:vstackweb/pages/work/work_detail_page.dart';
import 'package:vstackweb/pages/work/work_page.dart';
import 'package:vstackweb/features/tools/pages/tools_hub_page.dart';
import 'package:vstackweb/features/tools/tools_route.dart';

GoRouter createAppRouter(SiteContent content) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => SiteContentScope(
          content: content,
          child: AppShell(child: child),
        ),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomePage()),
          GoRoute(path: '/solutions', builder: (_, __) => const SolutionsHubPage()),
          GoRoute(
            path: '/solutions/:slug',
            builder: (_, state) => SolutionDetailPage(slug: state.pathParameters['slug']!),
          ),
          GoRoute(path: '/products', builder: (_, __) => const ProductsPage()),
          GoRoute(
            path: '/products/:slug',
            builder: (_, state) => ProductDetailPage(slug: state.pathParameters['slug']!),
          ),
          GoRoute(path: '/work', builder: (_, __) => const WorkPage()),
          GoRoute(
            path: '/work/:slug',
            builder: (_, state) => WorkDetailPage(slug: state.pathParameters['slug']!),
          ),
          GoRoute(path: '/demo-lab', builder: (_, __) => const DemoLabPage()),
          GoRoute(
            path: '/demo-lab/:slug',
            builder: (_, state) => DemoDetailPage(slug: state.pathParameters['slug']!),
          ),
          GoRoute(path: '/about', builder: (_, __) => const AboutPage()),
          GoRoute(path: '/contact', builder: (_, __) => const ContactPage()),
          GoRoute(path: '/careers', builder: (_, __) => const CareersPage()),
          GoRoute(path: '/tools', builder: (_, __) => const ToolsHubPage()),
          GoRoute(
            path: '/tools/:slug',
            builder: (_, state) => buildToolPage(state.pathParameters['slug']!, state),
          ),
          GoRoute(
            path: '/start-project',
            builder: (_, state) => StartProjectPage(
              initialService: state.uri.queryParameters['service'],
              initialProduct: state.uri.queryParameters['product'],
              initialDemo: state.uri.queryParameters['demo'],
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => SiteContentScope(
      content: content,
      child: AppShell(
        child: Center(
          child: Text('Page not found: ${state.uri.path}', style: const TextStyle(color: Colors.white70)),
        ),
      ),
    ),
  );
}
