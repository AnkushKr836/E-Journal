import 'package:flutter_test/flutter_test.dart';
import 'package:e_journal/main.dart';

void main() {
  testWidgets('E-Journal dashboard basic smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EJournalApp());

    // Verify that the title appears.
    expect(find.text('E-Journal'), findsOneWidget);
  });
}
