/// Local admin login (no Firebase Authentication).
abstract final class AdminAuthConfig {
  static const String username = 'vstackadmin';
  static const String password = 'Vstack@123#admin';

  static bool verify(String user, String pass) {
    return user.trim() == username && pass == password;
  }
}
