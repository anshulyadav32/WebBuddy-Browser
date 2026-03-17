import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_buddy/features/browser/presentation/widgets/page_actions_sheet.dart';

void main() {
  group('PageActionsSheet', () {
    testWidgets('renders page title and URL', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageActionsSheet(
              url: 'https://example.com',
              title: 'Example',
            ),
          ),
        ),
      );

      expect(find.text('Example'), findsOneWidget);
      expect(find.text('https://example.com'), findsOneWidget);
    });

    testWidgets('renders copy link action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageActionsSheet(
              url: 'https://example.com',
              title: 'Example',
            ),
          ),
        ),
      );

      expect(find.text('Copy link'), findsOneWidget);
    });

    testWidgets('renders share action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageActionsSheet(
              url: 'https://example.com',
              title: 'Example',
            ),
          ),
        ),
      );

      expect(find.text('Share page'), findsOneWidget);
    });

    testWidgets('renders find in page when callback provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageActionsSheet(
              url: 'https://example.com',
              title: 'Example',
              onFindInPage: () {},
            ),
          ),
        ),
      );

      expect(find.text('Find in page'), findsOneWidget);
    });

    testWidgets('hides find in page when callback is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageActionsSheet(
              url: 'https://example.com',
              title: 'Example',
            ),
          ),
        ),
      );

      expect(find.text('Find in page'), findsNothing);
    });

    testWidgets('renders reload when callback provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageActionsSheet(
              url: 'https://example.com',
              title: 'Example',
              onReload: () {},
            ),
          ),
        ),
      );

      expect(find.text('Reload'), findsOneWidget);
    });

    testWidgets('shows "Untitled" when title is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageActionsSheet(
              url: 'https://example.com',
              title: '',
            ),
          ),
        ),
      );

      expect(find.text('Untitled'), findsOneWidget);
    });
  });
}
