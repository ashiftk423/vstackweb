import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vstackweb/app/app_shell.dart';
import 'package:vstackweb/firebase/firebase_bootstrap.dart';
import 'package:vstackweb/providers/site_content_provider.dart';
import 'package:vstackweb/services/vstack_content_service.dart';
import 'package:vstackweb/services/vstack_storage_service.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseBootstrap.initialize();

  VStackContentService? contentService;
  if (FirebaseBootstrap.initialized) {
    try {
      contentService = VStackContentService(
        firestore: FirebaseFirestore.instance,
        storage: VStackStorageService(FirebaseStorage.instance),
      );
    } catch (e) {
      debugPrint('Content service setup failed: $e');
    }
  }

  runApp(
    VStackWebApp(
      service: contentService,
      firebaseReady: FirebaseBootstrap.initialized,
      firebaseError: FirebaseBootstrap.initError,
    ),
  );
}

class VStackWebApp extends StatelessWidget {
  const VStackWebApp({
    super.key,
    required this.service,
    required this.firebaseReady,
    this.firebaseError,
  });

  final VStackContentService? service;
  final bool firebaseReady;
  final String? firebaseError;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SiteContentProvider(service),
      child: MaterialApp(
        title: 'VStack IT Solutions',
        debugShowCheckedModeBanner: false,
        theme: buildVStackTheme(),
        home: AppShell(firebaseReady: firebaseReady, firebaseError: firebaseError),
      ),
    );
  }
}
