import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/presentation/widgets/private_tab_placeholder.dart';

void main() {
  group('PrivateTabPlaceholder', () {
    testWidgets('displays private browsing heading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivateTabPlaceholder())),
      );

      expect(find.text('Private Browsing'), findsOneWidget);
    });

    testWidgets('displays shield icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivateTabPlaceholder())),
      );

      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('displays info about history not recorded', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivateTabPlaceholder())),
      );

      expect(find.text('History is not recorded'), findsOneWidget);
    });

    testWidgets('displays info about cookies cleared', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivateTabPlaceholder())),
      );

      expect(find.text('Cookies cleared on close'), findsOneWidget);
    });

    testWidgets('displays info about bookmarks still saveable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivateTabPlaceholder())),
      );

      expect(find.text('Bookmarks can still be saved'), findsOneWidget);
    });

    testWidgets('displays info about downloads', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivateTabPlaceholder())),
      );

      expect(find.text('Downloads are still saved to disk'), findsOneWidget);
    });

    testWidgets('displays ISP visibility warning', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivateTabPlaceholder())),
      );

      expect(find.text('Your ISP can still see your traffic'), findsOneWidget);
    });
  });
}
