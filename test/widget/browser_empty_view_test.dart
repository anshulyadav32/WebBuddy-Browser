import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_buddy/features/browser/presentation/widgets/browser_empty_view.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BrowserEmptyView', () {
    testWidgets('renders icon, title, and subtitle', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserEmptyView(
          icon: Icons.bookmark_outline_rounded,
          title: 'No bookmarks yet',
          subtitle: 'Pages you bookmark will appear here.',
        )),
      );

      expect(find.byIcon(Icons.bookmark_outline_rounded), findsOneWidget);
      expect(find.text('No bookmarks yet'), findsOneWidget);
      expect(find.text('Pages you bookmark will appear here.'), findsOneWidget);
    });

    testWidgets('renders action button when actionLabel provided',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(BrowserEmptyView(
          icon: Icons.search,
          title: 'Nothing here',
          actionLabel: 'Go back',
          onAction: () => tapped = true,
        )),
      );

      expect(find.text('Go back'), findsOneWidget);
      await tester.tap(find.text('Go back'));
      expect(tapped, isTrue);
    });

    testWidgets('hides action button when actionLabel is null',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserEmptyView(
          icon: Icons.search,
          title: 'Nothing here',
        )),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('.newTab convenience renders correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserEmptyView.newTab()),
      );

      expect(find.text('Start exploring'), findsOneWidget);
      expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
    });

    testWidgets('.bookmarks convenience renders correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserEmptyView.bookmarks()),
      );

      expect(find.text('No bookmarks yet'), findsOneWidget);
    });

    testWidgets('.history convenience renders correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserEmptyView.history()),
      );

      expect(find.text('No history yet'), findsOneWidget);
    });

    testWidgets('.downloads convenience renders correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserEmptyView.downloads()),
      );

      expect(find.text('No downloads yet'), findsOneWidget);
    });

    testWidgets('.blockedRequests convenience renders correctly',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserEmptyView.blockedRequests()),
      );

      expect(find.text('No blocked requests'), findsOneWidget);
    });
  });
}
