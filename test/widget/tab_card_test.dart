import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:web_buddy/features/tabs/domain/models/browser_tab_state.dart';
import 'package:web_buddy/features/tabs/presentation/widgets/tab_card.dart';

void main() {
  testWidgets('TabCard displays title and url', (tester) async {
    const tab = BrowserTabState(
      id: '1',
      title: 'Flutter',
      currentUrl: 'https://flutter.dev',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TabCard(tab: tab, isActive: true, onTap: () {}, onClose: () {}),
        ),
      ),
    );

    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('https://flutter.dev'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('TabCard shows lock icon for private tabs', (tester) async {
    const tab = BrowserTabState(
      id: '2',
      title: 'Private',
      currentUrl: 'https://secret.com',
      isPrivate: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TabCard(tab: tab, isActive: false, onTap: () {}, onClose: () {}),
        ),
      ),
    );

    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets('TabCard shows activity dot for active tab', (tester) async {
    const tab = BrowserTabState(
      id: '3',
      title: 'Active',
      currentUrl: 'https://active.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TabCard(tab: tab, isActive: true, onTap: () {}, onClose: () {}),
        ),
      ),
    );

    // The active dot is a 6x6 Container — check for the primary container bg
    final containers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(containers, isNotEmpty);
  });

  testWidgets('TabCard shows progress bar when loading', (tester) async {
    const tab = BrowserTabState(
      id: '4',
      title: 'Loading',
      currentUrl: 'https://loading.com',
      isLoading: true,
      progress: 0.5,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TabCard(tab: tab, isActive: false, onTap: () {}, onClose: () {}),
        ),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('TabCard hides progress bar when not loading', (tester) async {
    const tab = BrowserTabState(
      id: '5',
      title: 'Idle',
      currentUrl: 'https://idle.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TabCard(tab: tab, isActive: false, onTap: () {}, onClose: () {}),
        ),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
