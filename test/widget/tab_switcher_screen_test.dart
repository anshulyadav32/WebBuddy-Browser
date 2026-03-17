import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/features/tabs/presentation/tab_switcher_screen.dart';

void main() {
  testWidgets('Tab switcher renders', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: TabSwitcherScreen())),
    );

    await tester.pump();

    // Title is a Text.rich with 'Tabs' as first span.
    expect(find.textContaining('Tabs'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
