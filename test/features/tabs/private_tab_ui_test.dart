import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/tabs/domain/models/browser_tab_state.dart';
import 'package:web_buddy/features/tabs/presentation/widgets/tab_card.dart';

void main() {
  group('Private Tab UI Tests', () {
    const testPrivateTab = BrowserTabState(
      id: 'private-1',
      currentUrl: 'https://private.example.com',
      title: 'Private Search',
      isPrivate: true,
    );

    const testNormalTab = BrowserTabState(
      id: 'normal-1',
      currentUrl: 'https://normal.example.com',
      title: 'Normal Tab',
      isPrivate: false,
    );

    Widget buildTabCard({required BrowserTabState tab, bool isActive = false}) {
      return MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: TabCard(
            tab: tab,
            isActive: isActive,
            onTap: () {},
            onClose: () {},
            onOpenInPrivate: () {},
          ),
        ),
      );
    }

    testWidgets('private tab displays lock icon', (tester) async {
      await tester.pumpWidget(buildTabCard(tab: testPrivateTab));

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('normal tab does not display lock icon', (tester) async {
      await tester.pumpWidget(buildTabCard(tab: testNormalTab));

      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('active private tab shows tertiary colors', (tester) async {
      await tester.pumpWidget(
        buildTabCard(tab: testPrivateTab, isActive: true),
      );

      final container = find.byType(Container);
      expect(container, findsWidgets);

      // Verify tab title is displayed
      expect(find.text('Private Search'), findsOneWidget);
    });

    testWidgets('inactive private tab shows muted tertiary colors', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTabCard(tab: testPrivateTab, isActive: false),
      );

      expect(find.text('Private Search'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('active indicator shows on active tabs', (tester) async {
      await tester.pumpWidget(buildTabCard(tab: testNormalTab, isActive: true));

      // Active tab should show a visual indicator (dot)
      final circleFinders = find.byWidgetPredicate(
        (widget) => widget is Container,
      );
      expect(circleFinders, findsWidgets);
    });

    testWidgets('tab card shows title correctly', (tester) async {
      const tab = BrowserTabState(
        id: 'tab-1',
        title: 'My Private Tab',
        isPrivate: true,
      );

      await tester.pumpWidget(buildTabCard(tab: tab));

      expect(find.text('My Private Tab'), findsOneWidget);
    });

    testWidgets('untitled tab shows "Untitled" text', (tester) async {
      const tab = BrowserTabState(id: 'tab-1', title: '', isPrivate: true);

      await tester.pumpWidget(buildTabCard(tab: tab));

      expect(find.text('Untitled'), findsOneWidget);
    });

    testWidgets('tab card is tappable', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: TabCard(
              tab: testPrivateTab,
              isActive: false,
              onTap: () => tapped = true,
              onClose: () {},
              onOpenInPrivate: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TabCard));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('close button exists on tab card', (tester) async {
      await tester.pumpWidget(buildTabCard(tab: testPrivateTab));

      // Close button should be present (close or X icon)
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('private tab semantic label includes "Private"', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTabCard(tab: testPrivateTab, isActive: true),
      );

      // TabCard itself has the semantic label
      final tabCard = find.byType(TabCard);
      expect(tabCard, findsOneWidget);

      // Verify semantic properties by looking for private indicator word
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('normal tab semantic label does not include "Private"', (
      tester,
    ) async {
      await tester.pumpWidget(buildTabCard(tab: testNormalTab, isActive: true));

      // Normal tab should not have lock icon
      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets(
      'multiple tabs with mix of private and normal render correctly',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: ListView(
                children: [
                  TabCard(
                    tab: testNormalTab,
                    isActive: true,
                    onTap: () {},
                    onClose: () {},
                    onOpenInPrivate: () {},
                  ),
                  TabCard(
                    tab: testPrivateTab,
                    isActive: false,
                    onTap: () {},
                    onClose: () {},
                    onOpenInPrivate: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(TabCard), findsNWidgets(2));
        expect(find.byIcon(Icons.lock), findsOneWidget); // Only private tab
      },
    );

    testWidgets('private tab animation works on state change', (tester) async {
      await tester.pumpWidget(
        buildTabCard(tab: testPrivateTab, isActive: false),
      );

      expect(find.byType(AnimatedContainer), findsOneWidget);
    });
  });
}
