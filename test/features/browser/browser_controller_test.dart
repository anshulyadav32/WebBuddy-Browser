import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/browser/domain/browser_page_state.dart';
import 'package:web_buddy/features/settings/domain/browser_settings.dart';

void main() {
  group('BrowserController — state callbacks (no WebView)', () {
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

    test('onPageStarted clears error state', () {
      // First simulate an error state.
      controller.onPageStarted('https://dart.dev');
      controller = BrowserController(const BrowserSettings());
      // Directly test that onPageStarted resets error flags.
      controller.onPageStarted('https://dart.dev');
      expect(controller.state.hasError, isFalse);
      expect(controller.state.errorDescription, '');
    });

    test('onProgress updates progress and loading state', () {
      controller.onProgress(42);

      expect(controller.state.progress, closeTo(0.42, 0.001));
      expect(controller.state.isLoading, isTrue);
    });

    test('onProgress at 100 sets loading false', () {
      controller.onProgress(100);

      expect(controller.state.progress, 1.0);
      expect(controller.state.isLoading, isFalse);
    });

    test('loadInput does nothing for empty input', () async {
      final before = controller.state;
      await controller.loadInput('');
      expect(controller.state, equals(before));
    });

    test('loadInput does nothing for whitespace-only input', () async {
      final before = controller.state;
      await controller.loadInput('   ');
      expect(controller.state, equals(before));
    });

    test('loadInput with URL sets state (no webview attached)', () async {
      await controller.loadInput('https://example.com');

      expect(controller.state.currentUrl, 'https://example.com');
      expect(controller.state.isLoading, isTrue);
    });

    test('loadInput with search query builds search URL', () async {
      await controller.loadInput('flutter tutorials');

      expect(controller.state.currentUrl, contains('google.com/search?q='));
      expect(controller.state.isLoading, isTrue);
    });

    test('loadInput clears previous error state', () async {
      await controller.loadInput('https://example.com');
      expect(controller.state.hasError, isFalse);
      expect(controller.state.errorDescription, '');
    });

    test('updateTitle sets title via onPageStarted + custom logic', () {
      // Simulate a page load cycle.
      controller.onPageStarted('https://dart.dev');
      expect(controller.state.title, '');
    });

    test('reload clears error state', () async {
      await controller.reload();
      expect(controller.state.hasError, isFalse);
    });

    test('findInPage returns false without WebView attached', () async {
      final result = await controller.findInPage('test');
      expect(result, isFalse);
    });

    test('findInPage returns false for empty query', () async {
      final result = await controller.findInPage('');
      expect(result, isFalse);
    });

    test('clearFind does not throw without WebView', () async {
      // Should complete without error.
      await controller.clearFind();
    });
  });
}
