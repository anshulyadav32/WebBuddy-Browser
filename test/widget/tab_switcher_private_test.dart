import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/tabs/presentation/tab_switcher_screen.dart';

void main() {
  group('TabSwitcherScreen — private tab action', () {
    testWidgets('shows new private tab button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TabSwitcherScreen())),
      );

      await tester.pump();

      // Shield icon for new private tab.
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      // Plus icon for new regular tab.
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
