// Same Firebase project as portfolio (ashifportfolio-27f49).
// VStack site data is isolated under vstackweb/* — see VStackFirebasePaths.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static bool get isConfigured => web.apiKey.isNotEmpty && web.projectId.isNotEmpty;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA2ur-ZtBGt30Hj9oCVuPBenvXlkQENmVc',
    authDomain: 'ashifportfolio-27f49.firebaseapp.com',
    projectId: 'ashifportfolio-27f49',
    storageBucket: 'ashifportfolio-27f49.firebasestorage.app',
    messagingSenderId: '336833825246',
    appId: '1:336833825246:web:3cdf46cb002cde7056f54f',
    measurementId: 'G-KGJK479FMT',
  );

  static const FirebaseOptions android = web;
  static const FirebaseOptions ios = web;
  static const FirebaseOptions windows = web;
}
