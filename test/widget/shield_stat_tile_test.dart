import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/domain/shield_stats.dart';
import 'package:web_buddy/features/privacy/presentation/widgets/shield_stat_tile.dart';

void main() {
  group('ShieldStatTile', () {
    testWidgets('displays label and count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShieldStatTile(
              label: 'Ads blocked',
              count: 42,
              icon: Icons.block,
            ),
          ),
        ),
      );

      expect(find.text('Ads blocked'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('displays zero count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShieldStatTile(
              label: 'Trackers',
              count: 0,
              icon: Icons.visibility_off,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('Trackers'), findsOneWidget);
    });

    testWidgets('fromStats creates three tiles', (tester) async {
      const stats = ShieldStats(
        adsBlocked: 5,
        trackersBlocked: 3,
        totalBlocked: 8,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final cs = Theme.of(context).colorScheme;
                return Row(
                  children: ShieldStatTile.fromStats(
                    stats,
                    colorScheme: cs,
                  ).map((t) => Expanded(child: t)).toList(),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('Ads blocked'), findsOneWidget);
      expect(find.text('Trackers blocked'), findsOneWidget);
      expect(find.text('Total blocked'), findsOneWidget);
    });
  });
}
