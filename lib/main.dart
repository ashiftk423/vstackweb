import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/data/local_content_loader.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/router/app_router.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Load content before runApp so GoRouter is created on the first frame with
  // the real browser URL (deep links like /solutions/digital-marketing).
  // Creating MaterialApp.router only after a FutureBuilder made GoRouter
  // start at initialLocation '/' and wipe the shared path.
  try {
    final content = await LocalContentLoader.load();
    runApp(VStackWebApp(content: content));
  } catch (e, st) {
    debugPrint('Failed to load site content: $e\n$st');
    runApp(VStackWebAppError(error: e));
  }
}

class VStackWebApp extends StatefulWidget {
  const VStackWebApp({super.key, required this.content});

  final SiteContent content;

  @override
  State<VStackWebApp> createState() => _VStackWebAppState();
}

class _VStackWebAppState extends State<VStackWebApp> {
  late final GoRouter _router = createAppRouter(widget.content);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VStack Business Solutions',
      debugShowCheckedModeBanner: false,
      theme: buildVStackTheme(),
      routerConfig: _router,
    );
  }
}

class VStackWebAppError extends StatelessWidget {
  const VStackWebAppError({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildVStackTheme(),
      home: Scaffold(
        backgroundColor: VStackColors.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load site content.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }
}
