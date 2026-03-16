import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_progress_bar.dart';

class _FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  _FakeBrowserController([super.initial = const BrowserPageState()]);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _testApp(Widget child, {BrowserPageState? state}) {
  return ProviderScope(
    overrides: [
      browserControllerProvider.overrideWith(
        (ref) => _FakeBrowserController(state ?? const BrowserPageState()),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('BrowserHomeScreen rendering', () {
    testWidgets('omnibox renders', (tester) async {
      await tester.pumpWidget(_testApp(const Scaffold(body: BrowserToolbar())));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('back button renders', (tester) async {
      await tester.pumpWidget(_testApp(const Scaffold(body: BrowserToolbar())));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('forward button renders', (tester) async {
      await tester.pumpWidget(_testApp(const Scaffold(body: BrowserToolbar())));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('refresh button renders when not loading', (tester) async {
      await tester.pumpWidget(_testApp(const Scaffold(body: BrowserToolbar())));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('progress bar hidden when not loading', (tester) async {
      await tester.pumpWidget(
        _testApp(
          const Scaffold(
            body: Column(children: [BrowserToolbar(), BrowserProgressBar()]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('private shield icon shown when isPrivateMode', (tester) async {
      await tester.pumpWidget(
        _testApp(const Scaffold(body: BrowserToolbar(isPrivateMode: true))),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('no shield icon in regular mode', (tester) async {
      await tester.pumpWidget(
        _testApp(const Scaffold(body: BrowserToolbar(isPrivateMode: false))),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shield), findsNothing);
    });

    testWidgets('downloads button visible', (tester) async {
      await tester.pumpWidget(_testApp(const Scaffold(body: BrowserToolbar())));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.download), findsOneWidget);
    });
  });
}
