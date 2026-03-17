import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/browser/domain/browser_page_state.dart';

void main() {
  group('BrowserPageState — defaults', () {
    test('default URL is flutter.dev', () {
      const s = BrowserPageState();
      expect(s.currentUrl, 'https://flutter.dev');
    });

    test('default title is empty', () {
      const s = BrowserPageState();
      expect(s.title, '');
    });

    test('default is not loading', () {
      const s = BrowserPageState();
      expect(s.isLoading, isFalse);
    });

    test('default progress is zero', () {
      const s = BrowserPageState();
      expect(s.progress, 0.0);
    });

    test('default canGoBack is false', () {
      const s = BrowserPageState();
      expect(s.canGoBack, isFalse);
    });

    test('default canGoForward is false', () {
      const s = BrowserPageState();
      expect(s.canGoForward, isFalse);
    });

    test('default hasError is false', () {
      const s = BrowserPageState();
      expect(s.hasError, isFalse);
    });

    test('default errorDescription is empty', () {
      const s = BrowserPageState();
      expect(s.errorDescription, '');
    });

    test('default errorCode is 0', () {
      const s = BrowserPageState();
      expect(s.errorCode, 0);
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

    test('updates title', () {
      const original = BrowserPageState();
      final updated = original.copyWith(title: 'Flutter Docs');

      expect(updated.title, 'Flutter Docs');
    });

    test('updates error state', () {
      const original = BrowserPageState();
      final updated = original.copyWith(
        hasError: true,
        errorDescription: 'net::ERR_NAME_NOT_RESOLVED',
        errorCode: -105,
      );

      expect(updated.hasError, isTrue);
      expect(updated.errorDescription, 'net::ERR_NAME_NOT_RESOLVED');
      expect(updated.errorCode, -105);
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
}
