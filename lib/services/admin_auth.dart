import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Staff sign-in for restricted pages (team ID cards).
///
/// Only salted PBKDF2-SHA256 hashes of the credentials are stored here.
/// The session lives in memory, so a page reload signs the user out.
class AdminAuth {
  AdminAuth._();

  static final signedIn = ValueNotifier<bool>(false);

  static const _salt = 'vbs-staff-gate-7f3c91e2a4d8';
  static const _iterations = 20000;
  static const _loginIdHash = 'zG+JVrsCjS9ywHh11KF5BphLXjlbBoeKj4I8VHFQS9A=';
  static const _passwordHash = 'GtiWY02mkULge5vwM2U1UC81zzW/Ny3f6+2jH4PNgnY=';

  static bool signIn(String loginId, String password) {
    final idOk = hash(loginId.trim(), 'id') == _loginIdHash;
    final passOk = hash(password, 'pw') == _passwordHash;
    signedIn.value = idOk && passOk;
    return signedIn.value;
  }

  static void signOut() => signedIn.value = false;

  @visibleForTesting
  static String hash(String value, String purpose) {
    final hmac = Hmac(sha256, utf8.encode(value));
    final salt = utf8.encode('$_salt:$purpose');
    var u = Uint8List.fromList(
      hmac.convert([...salt, 0, 0, 0, 1]).bytes,
    );
    final out = Uint8List.fromList(u);
    for (var i = 1; i < _iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (var j = 0; j < out.length; j++) {
        out[j] ^= u[j];
      }
    }
    return base64.encode(out);
  }
}
