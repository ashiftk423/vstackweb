import 'package:flutter/material.dart';
import 'package:vstackweb/data/local_content_loader.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/pages/landing_page.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VStackWebApp());
}

class VStackWebApp extends StatelessWidget {
  const VStackWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VStack Business Solutions',
      debugShowCheckedModeBanner: false,
      theme: buildVStackTheme(),
      home: FutureBuilder<SiteContent>(
        future: LocalContentLoader.load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              backgroundColor: Color(0xFF06080F),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: const Color(0xFF06080F),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load assets/content/site_content.json\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            );
          }
          return LandingPage(content: snapshot.data!);
        },
      ),
    );
  }
}
