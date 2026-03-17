import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/browser/domain/browser_page_state.dart';

void main() {
  group('BrowserPageState — error state', () {
    test('error state set correctly', () {
      const state = BrowserPageState();
      final withError = state.copyWith(
        hasError: true,
        errorDescription: 'net::ERR_NAME_NOT_RESOLVED',
        errorCode: -105,
      );

      expect(withError.hasError, isTrue);
      expect(withError.errorDescription, 'net::ERR_NAME_NOT_RESOLVED');
      expect(withError.errorCode, -105);
    });

    test('retry/reset clears error state', () {
      final errorState = const BrowserPageState().copyWith(
        hasError: true,
        errorDescription: 'net::ERR_NAME_NOT_RESOLVED',
        errorCode: -105,
      );

      final cleared = errorState.copyWith(
        hasError: false,
        errorDescription: '',
        errorCode: 0,
      );

      expect(cleared.hasError, isFalse);
      expect(cleared.errorDescription, '');
      expect(cleared.errorCode, 0);
    });

    test('error state does not affect other fields', () {
      const state = BrowserPageState(
        currentUrl: 'https://example.com',
        title: 'Example',
      );
      final withError = state.copyWith(
        hasError: true,
        errorDescription: 'error',
      );

      expect(withError.currentUrl, 'https://example.com');
      expect(withError.title, 'Example');
    });

    test('constructor defaults have no error', () {
      const state = BrowserPageState();
      expect(state.hasError, isFalse);
      expect(state.errorDescription, '');
      expect(state.errorCode, 0);
    });

    test('multiple error codes are distinguishable', () {
      final dns = const BrowserPageState().copyWith(
        hasError: true,
        errorDescription: 'net::ERR_NAME_NOT_RESOLVED',
        errorCode: -105,
      );
      final timeout = const BrowserPageState().copyWith(
        hasError: true,
        errorDescription: 'net::ERR_CONNECTION_TIMED_OUT',
        errorCode: -7,
      );

      expect(dns, isNot(equals(timeout)));
    });
  });
}
