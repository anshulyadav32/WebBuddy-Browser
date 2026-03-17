import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/settings/domain/browser_settings.dart';

/// Tests for find-in-page logic in [BrowserController].
void main() {
  group('Find in page logic', () {
    late BrowserController controller;

    setUp(() {
      controller = BrowserController(const BrowserSettings());
    });

    test('empty search query returns false', () async {
      final result = await controller.findInPage('');
      expect(result, isFalse);
    });

    test('whitespace-only query returns false', () async {
      final result = await controller.findInPage('   ');
      expect(result, isFalse);
    });

    test('findInPage without webview returns false', () async {
      final result = await controller.findInPage('some text');
      expect(result, isFalse);
    });

    test('clearFind does not throw without webview', () async {
      // Should complete safely with no webview attached.
      await controller.clearFind();
    });

    test('findInPage with valid query does not throw', () async {
      // Even though no webview is attached, should not throw.
      final result = await controller.findInPage('test query');
      expect(result, isFalse);
    });
  });
}
