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
  runApp(const VStackWebApp());
}

class VStackWebApp extends StatefulWidget {
  const VStackWebApp({super.key});

  @override
  State<VStackWebApp> createState() => _VStackWebAppState();
}

class _VStackWebAppState extends State<VStackWebApp> {
  late final Future<SiteContent> _contentFuture = LocalContentLoader.load();
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _contentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            theme: buildVStackTheme(),
            home: const Scaffold(
              backgroundColor: VStackColors.bg,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            theme: buildVStackTheme(),
            home: Scaffold(
              backgroundColor: VStackColors.bg,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load site content.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
          );
        }
        _router ??= createAppRouter(snapshot.data!);
        return MaterialApp.router(
          title: 'VStack Business Solutions',
          debugShowCheckedModeBanner: false,
          theme: buildVStackTheme(),
          routerConfig: _router,
        );
      },
    );
  }
}
