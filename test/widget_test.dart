// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/tabs/presentation/pages/tab_switcher_page.dart';
import 'package:web_buddy/features/tabs/presentation/providers/tab_provider.dart';

void main() {
  testWidgets('Tab switcher shows tab count', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const TabSwitcherPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The initial session has 1 tab
    expect(find.text('1 Tabs'), findsOneWidget);
  });

  testWidgets('Tab switcher add tab button works', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const TabSwitcherPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap the add tab button (in app bar)
    await tester.tap(find.byIcon(Icons.add));
    // Pop should be called, but since we're not in a navigator stack,
    // just verify the tap doesn't crash
    await tester.pump();
  });
}
