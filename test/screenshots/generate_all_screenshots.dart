import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_journal/core/theme/app_theme.dart';
import 'package:e_journal/features/dashboard/presentation/dashboard_screen.dart';
import 'package:e_journal/features/tasks/presentation/tasks_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate Dashboard Dark and Light screenshots', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1300, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Dashboard Dark
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/dashboard_dark_layout.png'),
    );

    // 2. Tasks Kanban Board (Dark)
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          home: const Scaffold(
            backgroundColor: Color(0xFF050811),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: TasksScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/tasks_kanban_dark.png'),
    );

    // 3. Tasks Kanban Board (Light)
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const Scaffold(
            backgroundColor: Color(0xFFF1F5F9),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: TasksScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/tasks_kanban_light.png'),
    );
  });
}
