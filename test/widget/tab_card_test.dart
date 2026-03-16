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
          body: TabCard(
            tab: tab,
            isActive: true,
            onTap: () {},
            onClose: () {},
          ),
        ),
      ),
    );

    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('https://flutter.dev'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
