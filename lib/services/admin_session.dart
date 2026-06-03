/// In-memory admin session after hardcoded login succeeds.
class AdminSession {
  AdminSession._();

  static bool isLoggedIn = false;

  static void signIn() => isLoggedIn = true;

  static void signOut() => isLoggedIn = false;
}
