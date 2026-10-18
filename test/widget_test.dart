import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_journal/main.dart';

void main() {
  testWidgets('E-Journal dashboard basic smoke test', (WidgetTester tester) async {
    // Set screen size to desktop width for comprehensive test
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build app with ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: EJournalApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify key elements appear
    expect(find.text('Stay up to date, Ankush'), findsOneWidget);
    expect(find.text('E-Journal'), findsOneWidget);
  });
}
