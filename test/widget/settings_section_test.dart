import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/settings/presentation/widgets/settings_section.dart';

/// Dedicated widget tests for [SettingsSection].
void main() {
  group('SettingsSection', () {
    testWidgets('section title renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSection(
              title: 'Appearance',
              children: [Text('Child')],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('children render', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSection(
              title: 'Test',
              children: [
                Text('Child 1'),
                Text('Child 2'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
    });

    testWidgets('empty children list renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSection(title: 'Empty', children: []),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Empty'), findsOneWidget);
    });
  });
}
