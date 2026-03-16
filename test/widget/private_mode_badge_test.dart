import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/presentation/widgets/private_mode_badge.dart';

void main() {
  group('PrivateModeBadge', () {
    testWidgets('shows icon and text in normal mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivateModeBadge())),
      );

      expect(find.byIcon(Icons.shield), findsOneWidget);
      expect(find.text('Private'), findsOneWidget);
    });

    testWidgets('shows only icon in compact mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PrivateModeBadge(compact: true)),
        ),
      );

      expect(find.byIcon(Icons.shield), findsOneWidget);
      expect(find.text('Private'), findsNothing);
    });
  });
}
