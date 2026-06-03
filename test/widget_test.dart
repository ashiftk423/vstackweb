import 'package:flutter_test/flutter_test.dart';
import 'package:vstackweb/main.dart';
import 'package:vstackweb/models/site_models.dart';

void main() {
  testWidgets('VStack landing loads with default content', (tester) async {
    await tester.pumpWidget(const VStackWebApp(service: null, firebaseReady: false));
    await tester.pump();
    expect(find.text('VStack'), findsOneWidget);
    expect(find.textContaining('We build software'), findsOneWidget);
    expect(SiteContent.defaults().projects.isNotEmpty, isTrue);
  });
}
