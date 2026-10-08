import 'package:flutter_test/flutter_test.dart';
import 'package:vstackweb/services/admin_auth.dart';

void main() {
  tearDown(AdminAuth.signOut);

  test('wrong credentials are rejected', () {
    expect(AdminAuth.signIn('admin', 'password'), isFalse);
    expect(AdminAuth.signIn('', ''), isFalse);
    expect(AdminAuth.signedIn.value, isFalse);
  });

  test('hashes are salted per field', () {
    expect(AdminAuth.hash('same', 'id'), isNot(AdminAuth.hash('same', 'pw')));
  });
}
