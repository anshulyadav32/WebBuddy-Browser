import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/settings/presentation/widgets/settings_toggle_tile.dart';

/// Dedicated widget tests for [SettingsToggleTile].
void main() {
  group('SettingsToggleTile', () {
    testWidgets('label is visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsToggleTile(
              title: 'Enable JavaScript',
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enable JavaScript'), findsOneWidget);
    });

    testWidgets('switch is visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsToggleTile(
              title: 'Test Toggle',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('callback fires on toggle', (tester) async {
      bool? received;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsToggleTile(
              title: 'Test Toggle',
              value: false,
              onChanged: (v) => received = v,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(received, isNotNull);
    });

    testWidgets('subtitle shown when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsToggleTile(
              title: 'JS',
              subtitle: 'Controls JavaScript execution',
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Controls JavaScript execution'), findsOneWidget);
    });
  });
}
