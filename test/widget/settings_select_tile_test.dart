import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/settings/presentation/widgets/settings_select_tile.dart';

/// Dedicated widget tests for [SettingsSelectTile].
void main() {
  group('SettingsSelectTile', () {
    testWidgets('label is visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsSelectTile<String>(
              title: 'Search Engine',
              value: 'Google',
              options: const ['Google', 'DuckDuckGo', 'Bing'],
              labelOf: (v) => v,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search Engine'), findsOneWidget);
    });

    testWidgets('current value shown as subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsSelectTile<String>(
              title: 'Theme',
              value: 'Dark',
              options: const ['Light', 'Dark', 'System'],
              labelOf: (v) => v,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('chevron icon visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsSelectTile<String>(
              title: 'Engine',
              value: 'Google',
              options: const ['Google'],
              labelOf: (v) => v,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('tap opens dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsSelectTile<String>(
              title: 'Pick One',
              value: 'A',
              options: const ['A', 'B', 'C'],
              labelOf: (v) => v,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pick One'));
      await tester.pumpAndSettle();

      // Dialog should show options
      expect(find.text('A'), findsWidgets);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });
  });
}
