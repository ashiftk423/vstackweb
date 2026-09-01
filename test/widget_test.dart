import 'package:flutter_test/flutter_test.dart';
import 'package:vstackweb/data/local_content_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads site content from assets', () async {
    final content = await LocalContentLoader.load();
    expect(content.site.heroTitle, isNotEmpty);
    expect(content.products.length, 5);
    expect(content.work.length, 2);
    expect(content.solutions.length, greaterThanOrEqualTo(5));
    expect(content.demos.length, greaterThanOrEqualTo(5));
    expect(content.contact.email, contains('@'));
    expect(content.productBySlug('quickrent')?.isLive, isTrue);
    expect(content.productBySlug('kattar')?.isUpcoming, isTrue);
  });
}
