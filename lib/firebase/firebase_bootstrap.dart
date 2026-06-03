import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:vstackweb/firebase/firebase_options.dart';

/// Tracks whether Firebase Core started (Auth/Firestore/Storage need this).
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool initialized = false;
  static String? initError;

  static Future<void> initialize() async {
    if (initialized) return;
    initError = null;

    if (!DefaultFirebaseOptions.isConfigured) {
      initError = 'firebase_options.dart is missing project keys.';
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
      initialized = true;
      debugPrint('Firebase initialized: ${DefaultFirebaseOptions.web.projectId}');
    } catch (e, stack) {
      initError = e.toString();
      debugPrint('Firebase init failed: $e\n$stack');
    }
  }
}
