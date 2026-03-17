import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_buddy/features/settings/domain/browser_settings.dart';
import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';

/// Unit tests for domain models and [BrowserController] state updates.
void main() {
  // ═══════════════════════════════════════════════════════════════════
  // BrowserSettings
  // ═══════════════════════════════════════════════════════════════════

  group('BrowserSettings — defaults', () {
    test('has system theme mode', () {
      const s = BrowserSettings();
      expect(s.themeMode, ThemeMode.system);
    });

    test('has Google as default search engine', () {
      const s = BrowserSettings();
      expect(s.searchEngine, SearchEngine.google);
    });

    test('has ad-block enabled', () {
      const s = BrowserSettings();
      expect(s.adBlockEnabled, isTrue);
    });

    test('has HTTPS upgrade enabled', () {
      const s = BrowserSettings();
      expect(s.httpsUpgradeEnabled, isTrue);
    });

    test('has about:blank as home page', () {
      const s = BrowserSettings();
      expect(s.homePage, 'about:blank');
    });
  });

  group('BrowserSettings — copyWith', () {
    test('changes only theme mode', () {
      const original = BrowserSettings();
      final updated = original.copyWith(themeMode: ThemeMode.dark);

      expect(updated.themeMode, ThemeMode.dark);
      expect(updated.searchEngine, original.searchEngine);
      expect(updated.adBlockEnabled, original.adBlockEnabled);
      expect(updated.httpsUpgradeEnabled, original.httpsUpgradeEnabled);
      expect(updated.homePage, original.homePage);
    });

    test('changes multiple fields at once', () {
      const original = BrowserSettings();
      final updated = original.copyWith(
        searchEngine: SearchEngine.duckDuckGo,
        adBlockEnabled: false,
        homePage: 'https://example.com',
      );

      expect(updated.searchEngine, SearchEngine.duckDuckGo);
      expect(updated.adBlockEnabled, isFalse);
      expect(updated.homePage, 'https://example.com');
      expect(updated.themeMode, ThemeMode.system);
    });
  });

  group('BrowserSettings — serialization', () {
    test('round-trips through toMap/fromMap', () {
      final original = const BrowserSettings().copyWith(
        themeMode: ThemeMode.dark,
        searchEngine: SearchEngine.brave,
        adBlockEnabled: false,
      );
      final restored = BrowserSettings.fromMap(original.toMap());
      expect(restored, equals(original));
    });

    test('fromMap handles empty map gracefully', () {
      final s = BrowserSettings.fromMap({});
      expect(s, equals(const BrowserSettings()));
    });
  });

  group('BrowserSettings — equality', () {
    test('identical defaults are equal', () {
      expect(const BrowserSettings(), equals(const BrowserSettings()));
    });

    test('different settings are not equal', () {
      const a = BrowserSettings();
      final b = a.copyWith(themeMode: ThemeMode.light);
      expect(a, isNot(equals(b)));
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // BrowserPageState
  // ═══════════════════════════════════════════════════════════════════

  group('BrowserPageState — defaults', () {
    test('starts with flutter.dev URL', () {
      const s = BrowserPageState();
      expect(s.currentUrl, 'https://flutter.dev');
    });

    test('starts with empty title', () {
      const s = BrowserPageState();
      expect(s.title, '');
    });

    test('starts not loading', () {
      const s = BrowserPageState();
      expect(s.isLoading, isFalse);
    });

    test('starts with zero progress', () {
      const s = BrowserPageState();
      expect(s.progress, 0.0);
    });

    test('starts with no back navigation', () {
      const s = BrowserPageState();
      expect(s.canGoBack, isFalse);
    });

    test('starts with no forward navigation', () {
      const s = BrowserPageState();
      expect(s.canGoForward, isFalse);
    });
  });

  group('BrowserPageState — copyWith', () {
    test('updates URL only', () {
      const original = BrowserPageState();
      final updated = original.copyWith(currentUrl: 'https://dart.dev');

      expect(updated.currentUrl, 'https://dart.dev');
      expect(updated.title, original.title);
      expect(updated.isLoading, original.isLoading);
    });

    test('updates loading and progress together', () {
      const original = BrowserPageState();
      final updated = original.copyWith(isLoading: true, progress: 0.42);

      expect(updated.isLoading, isTrue);
      expect(updated.progress, closeTo(0.42, 0.001));
    });

    test('updates navigation state', () {
      const original = BrowserPageState();
      final updated = original.copyWith(canGoBack: true, canGoForward: true);

      expect(updated.canGoBack, isTrue);
      expect(updated.canGoForward, isTrue);
    });
  });

  group('BrowserPageState — equality', () {
    test('identical defaults are equal', () {
      expect(const BrowserPageState(), equals(const BrowserPageState()));
    });

    test('different URLs are not equal', () {
      const a = BrowserPageState();
      final b = a.copyWith(currentUrl: 'https://dart.dev');
      expect(a, isNot(equals(b)));
    });

    test('equal objects have same hashCode', () {
      expect(
        const BrowserPageState().hashCode,
        equals(const BrowserPageState().hashCode),
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // BrowserController — state update methods (no WebView attached)
  // ═══════════════════════════════════════════════════════════════════

  group('BrowserController — state callbacks', () {
    late BrowserController controller;

    setUp(() {
      controller = BrowserController(const BrowserSettings());
    });

    test('initial state has default BrowserPageState', () {
      expect(
        controller.state,
        equals(const BrowserPageState(currentUrl: 'about:blank')),
      );
    });

    test('onPageStarted sets URL, loading true, progress 0', () {
      controller.onPageStarted('https://dart.dev');

      expect(controller.state.currentUrl, 'https://dart.dev');
      expect(controller.state.isLoading, isTrue);
      expect(controller.state.progress, 0.0);
    });

    test('onProgress updates progress and loading state', () {
      controller.onProgress(50);

      expect(controller.state.progress, closeTo(0.50, 0.001));
      expect(controller.state.isLoading, isTrue);
    });

    test('onProgress at 100 sets loading false', () {
      controller.onProgress(100);

      expect(controller.state.progress, closeTo(1.0, 0.001));
      expect(controller.state.isLoading, isFalse);
    });

    test(
      'onPageFinished sets loading false, progress 1, updates URL',
      () async {
        controller.onPageFinished('https://dart.dev');
        // onPageFinished is async — give microtasks time to complete.
        await Future<void>.delayed(Duration.zero);

        expect(controller.state.currentUrl, 'https://dart.dev');
        expect(controller.state.isLoading, isFalse);
        expect(controller.state.progress, 1.0);
      },
    );

    test('loadInput with URL sets state and marks loading', () async {
      // No WebView attached, so loadRequest is a no-op, but state updates.
      await controller.loadInput('example.com');

      expect(controller.state.currentUrl, 'https://example.com');
      expect(controller.state.isLoading, isTrue);
    });

    test('loadInput with search query builds search URL', () async {
      await controller.loadInput('flutter widgets');

      expect(
        controller.state.currentUrl,
        startsWith('https://www.google.com/search?q='),
      );
      expect(controller.state.currentUrl, contains('flutter'));
    });

    test('loadInput with empty string is a no-op', () async {
      final before = controller.state;
      await controller.loadInput('');
      expect(controller.state, equals(before));
    });

    test('loadInput with whitespace-only string is a no-op', () async {
      final before = controller.state;
      await controller.loadInput('   ');
      expect(controller.state, equals(before));
    });

    test('stopLoading sets isLoading to false', () async {
      controller.onPageStarted('https://example.com');
      expect(controller.state.isLoading, isTrue);

      await controller.stopLoading();
      expect(controller.state.isLoading, isFalse);
    });

    test('goBack is safe when canGoBack is false', () async {
      // Should not throw.
      await controller.goBack();
      expect(controller.state.canGoBack, isFalse);
    });

    test('goForward is safe when canGoForward is false', () async {
      await controller.goForward();
      expect(controller.state.canGoForward, isFalse);
    });
  });
}
