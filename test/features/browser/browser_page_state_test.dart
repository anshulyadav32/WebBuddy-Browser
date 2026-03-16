import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/browser/domain/browser_page_state.dart';

void main() {
  group('BrowserPageState defaults', () {
    test('has expected initial values', () {
      const s = BrowserPageState();
      expect(s.currentUrl, 'https://flutter.dev');
      expect(s.title, '');
      expect(s.isLoading, isFalse);
      expect(s.progress, 0.0);
      expect(s.canGoBack, isFalse);
      expect(s.canGoForward, isFalse);
    });
  });

  group('BrowserPageState.copyWith', () {
    test('updates only specified fields', () {
      const original = BrowserPageState();
      final updated = original.copyWith(
        currentUrl: 'https://dart.dev',
        isLoading: true,
      );

      expect(updated.currentUrl, 'https://dart.dev');
      expect(updated.isLoading, isTrue);
      // Unchanged
      expect(updated.title, original.title);
      expect(updated.progress, original.progress);
      expect(updated.canGoBack, original.canGoBack);
      expect(updated.canGoForward, original.canGoForward);
    });

    test('updates navigation state', () {
      const original = BrowserPageState();
      final updated = original.copyWith(
        canGoBack: true,
        canGoForward: true,
        progress: 0.5,
      );

      expect(updated.canGoBack, isTrue);
      expect(updated.canGoForward, isTrue);
      expect(updated.progress, 0.5);
    });
  });

  group('BrowserPageState equality', () {
    test('identical defaults are equal', () {
      expect(const BrowserPageState(), equals(const BrowserPageState()));
    });

    test('different states are not equal', () {
      const a = BrowserPageState();
      final b = a.copyWith(currentUrl: 'https://dart.dev');
      expect(a, isNot(equals(b)));
    });

    test('hashCode matches for equal objects', () {
      expect(
        const BrowserPageState().hashCode,
        equals(const BrowserPageState().hashCode),
      );
    });
  });
}
