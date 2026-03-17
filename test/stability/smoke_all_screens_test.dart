import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/presentation/first_run_screen.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_empty_view.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_error_view.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_progress_bar.dart';
import 'package:web_buddy/features/downloads/presentation/downloads_screen.dart';
import 'package:web_buddy/features/history/presentation/history_screen.dart';
import 'package:web_buddy/features/privacy/presentation/shields_controller.dart';
import 'package:web_buddy/features/privacy/presentation/widgets/shields_panel.dart';
import 'package:web_buddy/features/settings/presentation/settings_controller.dart';
import 'package:web_buddy/features/settings/presentation/settings_screen.dart';
import 'package:web_buddy/features/settings/presentation/site_settings_controller.dart';
import 'package:web_buddy/features/settings/domain/site_settings.dart';
import 'package:web_buddy/features/tabs/presentation/tab_switcher_screen.dart';

// ── Fakes ────────────────────────────────────────────────────────────

class _FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  _FakeBrowserController() : super(const BrowserPageState());

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

/// Smoke tests that verify every top-level screen and major widget can be
/// instantiated and rendered without throwing.
///
/// These are deliberately shallow — the goal is crash detection, not
/// functional correctness. Each test pumps the widget tree and verifies
/// it settles without exception.
void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('Smoke – Top-level screens render', () {
    testWidgets('TabSwitcherScreen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: TabSwitcherScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TabSwitcherScreen), findsOneWidget);
    });

    testWidgets('BookmarksScreen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: BookmarksScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BookmarksScreen), findsOneWidget);
    });

    testWidgets('HistoryScreen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: HistoryScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HistoryScreen), findsOneWidget);
    });

    testWidgets('DownloadsScreen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: DownloadsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DownloadsScreen), findsOneWidget);
    });

    testWidgets('SettingsScreen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('FirstRunScreen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: FirstRunScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FirstRunScreen), findsOneWidget);
    });
  });

  group('Smoke – Reusable widgets render', () {
    testWidgets('BrowserToolbar default', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: Scaffold(body: BrowserToolbar())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BrowserToolbar), findsOneWidget);
    });

    testWidgets('BrowserProgressBar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: Scaffold(body: BrowserProgressBar())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BrowserProgressBar), findsOneWidget);
    });

    testWidgets('BrowserErrorView with all error types', (tester) async {
      // DNS error
      await tester.pumpWidget(
        MaterialApp(
          home: BrowserErrorView(
            url: 'https://unknown.test',
            errorDescription: 'net::ERR_NAME_NOT_RESOLVED',
            errorCode: -105,
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BrowserErrorView), findsOneWidget);

      // Timeout
      await tester.pumpWidget(
        MaterialApp(
          home: BrowserErrorView(
            url: 'https://slow.test',
            errorDescription: 'net::ERR_TIMED_OUT',
            errorCode: -7,
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BrowserErrorView), findsOneWidget);

      // SSL error
      await tester.pumpWidget(
        MaterialApp(
          home: BrowserErrorView(
            url: 'https://expired.test',
            errorDescription: 'net::ERR_CERT_DATE_INVALID',
            errorCode: -201,
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BrowserErrorView), findsOneWidget);

      // Offline
      await tester.pumpWidget(
        MaterialApp(
          home: BrowserErrorView(
            url: 'https://any.test',
            errorDescription: 'net::ERR_INTERNET_DISCONNECTED',
            errorCode: -106,
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BrowserErrorView), findsOneWidget);
    });

    testWidgets('BrowserEmptyView all named constructors', (tester) async {
      for (final factory in [
        () => const BrowserEmptyView.newTab(),
        () => const BrowserEmptyView.bookmarks(),
        () => const BrowserEmptyView.history(),
        () => const BrowserEmptyView.downloads(),
      ]) {
        await tester.pumpWidget(MaterialApp(home: factory()));
        await tester.pumpAndSettle();
        expect(find.byType(BrowserEmptyView), findsOneWidget);
      }
    });

    testWidgets('ShieldsPanel renders without crashing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(prefs),
          child: const MaterialApp(home: Scaffold(body: ShieldsPanel())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ShieldsPanel), findsOneWidget);
    });
  });

  group('Smoke – Error recovery', () {
    testWidgets('BrowserErrorView retry callback fires', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: BrowserErrorView(
            url: 'https://fail.test',
            errorDescription: 'Connection refused',
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });
  });
}
