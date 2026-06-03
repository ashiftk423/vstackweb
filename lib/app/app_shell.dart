import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vstackweb/pages/admin/admin_login_page.dart';
import 'package:vstackweb/pages/landing_page.dart';
import 'package:vstackweb/providers/site_content_provider.dart';

class OpenAdminLoginIntent extends Intent {
  const OpenAdminLoginIntent();
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.firebaseReady, this.firebaseError});

  final bool firebaseReady;
  final String? firebaseError;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyO, shift: true, control: true):
            OpenAdminLoginIntent(),
      },
      child: Actions(
        actions: {
          OpenAdminLoginIntent: CallbackAction<OpenAdminLoginIntent>(
            onInvoke: (_) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AdminLoginPage()),
              );
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Consumer<SiteContentProvider>(
            builder: (context, provider, _) {
              if (provider.loading && !provider.content.fromFirebase) {
                return const Scaffold(
                  backgroundColor: Color(0xFF06080F),
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return LandingPage(
                content: provider.content,
                service: provider.hasFirebase ? provider.service : null,
                firebaseReady: firebaseReady,
              );
            },
          ),
        ),
      ),
    );
  }
}
