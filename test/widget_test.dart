import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_progress_bar.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';

/// A fake [BrowserController] that does nothing but hold state.
class FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  FakeBrowserController([super.initial = const BrowserPageState()]);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestWidget(Widget child, {BrowserPageState? initialState}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        browserControllerProvider.overrideWith(
          (ref) => FakeBrowserController(
            initialState ?? const BrowserPageState(),
          ),
        ),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('BrowserToolbar', () {
    testWidgets('renders omnibox with hint text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const Scaffold(body: BrowserToolbar()),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search or enter URL'), findsOneWidget);
    });

    testWidgets('shows navigation buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const Scaffold(body: BrowserToolbar()),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('back/forward buttons disabled when cannot navigate',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const Scaffold(body: BrowserToolbar()),
        initialState: const BrowserPageState(
          canGoBack: false,
          canGoForward: false,
        ),
      ));
      await tester.pumpAndSettle();

      // Find IconButtons and check they are disabled (onPressed == null).
      final backButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_back),
      );
      expect(backButton.onPressed, isNull);

      final fwdButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_forward),
      );
      expect(fwdButton.onPressed, isNull);
    });

    testWidgets('shows stop icon when loading', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const Scaffold(body: BrowserToolbar()),
        initialState: const BrowserPageState(isLoading: true),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });
  });

  group('BrowserProgressBar', () {
    testWidgets('hidden when not loading', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const Scaffold(body: BrowserProgressBar()),
        initialState: const BrowserPageState(isLoading: false),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('visible when loading', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const Scaffold(body: BrowserProgressBar()),
        initialState: const BrowserPageState(
          isLoading: true,
          progress: 0.5,
        ),
      ));
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('Browser shell layout', () {
    testWidgets('toolbar + progress bar render in a column', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const Scaffold(
          body: Column(
            children: [
              BrowserToolbar(),
              BrowserProgressBar(),
              Expanded(child: Placeholder()),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(BrowserToolbar), findsOneWidget);
      expect(find.byType(BrowserProgressBar), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
    });
  });
}
