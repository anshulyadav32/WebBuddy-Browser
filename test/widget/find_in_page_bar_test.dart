import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_buddy/features/browser/presentation/widgets/find_in_page_bar.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('FindInPageBar', () {
    testWidgets('renders text field with hint', (tester) async {
      await tester.pumpWidget(
        _wrap(FindInPageBar(
          onSearch: (_) {},
          onClose: () {},
        )),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Find in page'), findsWidgets); // hint text + semantics
    });

    testWidgets('calls onSearch on submit', (tester) async {
      String? searchedQuery;
      await tester.pumpWidget(
        _wrap(FindInPageBar(
          onSearch: (q) => searchedQuery = q,
          onClose: () {},
        )),
      );

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(searchedQuery, 'hello');
    });

    testWidgets('calls onClose when close button tapped', (tester) async {
      bool closed = false;
      await tester.pumpWidget(
        _wrap(FindInPageBar(
          onSearch: (_) {},
          onClose: () => closed = true,
        )),
      );

      await tester.tap(find.byTooltip('Close find bar'));
      expect(closed, isTrue);
    });

    testWidgets('find-next button disabled when empty', (tester) async {
      await tester.pumpWidget(
        _wrap(FindInPageBar(
          onSearch: (_) {},
          onClose: () {},
        )),
      );

      // The find-next button should be disabled (null onPressed)
      final button = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.keyboard_arrow_down),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('find-next button enabled when text entered', (tester) async {
      await tester.pumpWidget(
        _wrap(FindInPageBar(
          onSearch: (_) {},
          onClose: () {},
        )),
      );

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      final button = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.keyboard_arrow_down),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls onClear when clear button tapped', (tester) async {
      bool cleared = false;
      await tester.pumpWidget(
        _wrap(FindInPageBar(
          onSearch: (_) {},
          onClose: () {},
          onClear: () => cleared = true,
        )),
      );

      await tester.enterText(find.byType(TextField), 'something');
      await tester.pump();

      await tester.tap(find.byTooltip('Clear'));
      expect(cleared, isTrue);
    });
  });
}
