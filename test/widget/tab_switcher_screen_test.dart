import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/features/tabs/presentation/tab_switcher_screen.dart';

void main() {
  testWidgets('Tab switcher renders', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TabSwitcherScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Tabs'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
