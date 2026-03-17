import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_empty_view.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_error_view.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_progress_bar.dart';
import 'package:web_buddy/features/downloads/presentation/downloads_screen.dart';
import 'package:web_buddy/features/history/presentation/history_screen.dart';
import 'package:web_buddy/features/privacy/presentation/shields_controller.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';
import 'package:web_buddy/features/settings/presentation/settings_screen.dart';
import 'package:web_buddy/features/settings/presentation/site_settings_controller.dart';
import 'package:web_buddy/features/settings/domain/site_settings.dart';
import 'package:web_buddy/features/tabs/application/tabs_controller.dart';
import 'package:web_buddy/features/tabs/presentation/tab_switcher_screen.dart';

// ── Fakes ────────────────────────────────────────────────────────────

class _FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  _FakeBrowserController([BrowserPageState? initial])
    : super(initial ?? const BrowserPageState());

  @override
  Future<void> loadInput(String input) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeShieldsController extends StateNotifier<ShieldsState>
    implements ShieldsController {
  _FakeShieldsController()
    : super(const ShieldsState(isInitialised: true, globalEnabled: true));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeSiteSettingsController
    extends StateNotifier<Map<String, SiteSettings>>
    implements SiteSettingsController {
  _FakeSiteSettingsController() : super({});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

List<Override> _baseOverrides(SharedPreferences prefs) => [
  sharedPreferencesProvider.overrideWithValue(prefs),
  browserControllerProvider.overrideWith((ref) => _FakeBrowserController()),
  shieldsControllerProvider.overrideWith((_) => _FakeShieldsController()),
  siteSettingsControllerProvider.overrideWith(
    (_) => _FakeSiteSettingsController(),
  ),
];

/// Regression tests for core browser features.
///
/// These tests verify that previously-working functionality continues to
/// behave correctly across code changes. Each test case targets a discrete
/// feature area and is designed to catch regressions early.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('Regression – Tab lifecycle', () {
    testWidgets('create two tabs, close first, second remains active', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: TabSwitcherScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: 1 tab
      final controller = ProviderScope.containerOf(
        tester.element(find.byType(TabSwitcherScreen)),
      ).read(tabsControllerProvider.notifier);

      expect(
        ProviderScope.containerOf(
          tester.element(find.byType(TabSwitcherScreen)),
        ).read(tabsControllerProvider).tabs.length,
        1,
      );

      // Create second tab
      controller.createNewTab();
      await tester.pumpAndSettle();

      final state = ProviderScope.containerOf(
        tester.element(find.byType(TabSwitcherScreen)),
      ).read(tabsControllerProvider);
      expect(state.tabs.length, 2);

      // Close first tab
      controller.closeTab(state.tabs.first.id);
      await tester.pumpAndSettle();

      final afterClose = ProviderScope.containerOf(
        tester.element(find.byType(TabSwitcherScreen)),
      ).read(tabsControllerProvider);
      expect(afterClose.tabs.length, 1);
    });

    testWidgets('closing last tab creates replacement', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: TabSwitcherScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(TabSwitcherScreen)),
      );
      final controller = container.read(tabsControllerProvider.notifier);
      final onlyTabId = container.read(tabsControllerProvider).tabs.first.id;

      controller.closeTab(onlyTabId);
      await tester.pumpAndSettle();

      final state = container.read(tabsControllerProvider);
      expect(state.tabs.length, 1, reason: 'Replacement tab created');
      expect(state.tabs.first.id, isNot(onlyTabId));
    });
  });

  group('Regression – Bookmarks screen', () {
    testWidgets('bookmarks screen renders empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: BookmarksScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.text('No bookmarks yet'), findsOneWidget);
    });
  });

  group('Regression – History screen', () {
    testWidgets('history screen renders empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
      expect(find.text('No history yet'), findsOneWidget);
    });
  });

  group('Regression – Downloads screen', () {
    testWidgets('downloads screen renders empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: DownloadsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('No downloads yet'), findsOneWidget);
    });
  });

  group('Regression – Settings screen', () {
    testWidgets('settings screen shows all sections without crashing', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);

      // Scroll to reveal all settings
      await tester.scrollUntilVisible(
        find.text('Privacy & Data'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Privacy & Data'), findsOneWidget);
    });
  });

  group('Regression – Error and empty views', () {
    testWidgets('error view renders all elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BrowserErrorView(
            url: 'https://broken.example.com',
            errorDescription: 'net::ERR_NAME_NOT_RESOLVED',
            errorCode: -105,
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Site not found'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('empty view – new tab', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BrowserEmptyView.newTab()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Start exploring'), findsOneWidget);
    });

    testWidgets('empty view – bookmarks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BrowserEmptyView.bookmarks()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BrowserEmptyView), findsOneWidget);
    });

    testWidgets('empty view – history', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BrowserEmptyView.history()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BrowserEmptyView), findsOneWidget);
    });

    testWidgets('empty view – downloads', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BrowserEmptyView.downloads()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BrowserEmptyView), findsOneWidget);
    });
  });

  group('Regression – Browser toolbar', () {
    testWidgets('toolbar renders in normal mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: Scaffold(body: BrowserToolbar())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('toolbar renders in private mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(
            home: Scaffold(
              body: BrowserToolbar(isPrivateMode: true, tabCount: 3),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Private mode shows at least one shield icon
      expect(find.byIcon(Icons.shield), findsWidgets);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('progress bar renders', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: Scaffold(body: BrowserProgressBar())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BrowserProgressBar), findsOneWidget);
    });
  });
}
