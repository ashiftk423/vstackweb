import 'package:flutter_test/flutter_test.dart';
import 'package:vstackweb/data/local_content_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads site content from assets', () async {
    final content = await LocalContentLoader.load();
    expect(content.site.heroTitle, isNotEmpty);
    expect(content.projects.length, greaterThanOrEqualTo(1));
    expect(content.team.length, greaterThanOrEqualTo(1));
    expect(content.contact.email, contains('@'));
  });
}
