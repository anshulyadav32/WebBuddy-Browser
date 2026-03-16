import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/settings/presentation/widgets/settings_section.dart';
import 'package:web_buddy/features/settings/presentation/widgets/settings_toggle_tile.dart';
import 'package:web_buddy/features/settings/presentation/widgets/settings_select_tile.dart';

void main() {
  group('SettingsSection', () {
    testWidgets('renders title and children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSection(
              title: 'Test Section',
              children: [Text('Child A'), Text('Child B')],
            ),
          ),
        ),
      );

      expect(find.text('Test Section'), findsOneWidget);
      expect(find.text('Child A'), findsOneWidget);
      expect(find.text('Child B'), findsOneWidget);
    });
  });

  group('SettingsToggleTile', () {
    testWidgets('renders title, subtitle and switch', (tester) async {
      var toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsToggleTile(
              title: 'Toggle',
              subtitle: 'Description',
              value: false,
              onChanged: (v) => toggled = v,
              icon: Icons.settings,
            ),
          ),
        ),
      );

      expect(find.text('Toggle'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Tap the switch
      await tester.tap(find.byType(Switch));
      expect(toggled, true);
    });

    testWidgets('works without subtitle and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsToggleTile(
              title: 'Simple',
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Simple'), findsOneWidget);
    });
  });

  group('SettingsSelectTile', () {
    testWidgets('renders title with current value label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsSelectTile<String>(
              title: 'Color',
              value: 'Red',
              options: const ['Red', 'Blue', 'Green'],
              labelOf: (v) => v,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Red'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('opens dialog on tap and selects option', (tester) async {
      String selected = 'Red';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SettingsSelectTile<String>(
                  title: 'Color',
                  value: selected,
                  options: const ['Red', 'Blue', 'Green'],
                  labelOf: (v) => v,
                  onChanged: (v) => setState(() => selected = v),
                );
              },
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Color'));
      await tester.pumpAndSettle();

      // Dialog shows all options
      expect(find.text('Red'), findsWidgets); // in tile + dialog
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);

      // Select Blue
      await tester.tap(find.text('Blue'));
      await tester.pumpAndSettle();

      expect(selected, 'Blue');
    });
  });
}
