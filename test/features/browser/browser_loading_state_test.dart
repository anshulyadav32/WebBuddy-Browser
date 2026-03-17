import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:web_buddy/features/settings/domain/browser_settings.dart';

/// Tests for loading-state transitions in [BrowserController].
void main() {
  group('Browser loading state transitions', () {
    late BrowserController controller;

    setUp(() {
      controller = BrowserController(const BrowserSettings());
    });

    test('page start event triggers loading state', () {
      controller.onPageStarted('https://example.com');

      expect(controller.state.isLoading, isTrue);
      expect(controller.state.progress, 0.0);
      expect(controller.state.currentUrl, 'https://example.com');
    });

    test('progress events update loading percentage', () {
      controller.onPageStarted('https://example.com');
      controller.onProgress(50);

      expect(controller.state.isLoading, isTrue);
      expect(controller.state.progress, closeTo(0.5, 0.01));
    });

    test('page finish event resets loading to false', () {
      controller.onPageStarted('https://example.com');
      controller.onProgress(50);

      // Simulate page finish via progress=100
      controller.onProgress(100);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.progress, 1.0);
    });

    test('page error can be modeled via copyWith', () {
      controller.onPageStarted('https://example.com');

      // Simulate error state (onWebResourceError requires WebResourceError
      // from the platform — test via state model instead).
      final errorState = controller.state.copyWith(
        hasError: true,
        isLoading: false,
        errorDescription: 'net::ERR_NAME_NOT_RESOLVED',
        errorCode: -105,
      );

      expect(errorState.hasError, isTrue);
      expect(errorState.isLoading, isFalse);
    });

    test('sequential page loads reset progress', () {
      controller.onPageStarted('https://first.com');
      controller.onProgress(80);

      controller.onPageStarted('https://second.com');

      expect(controller.state.currentUrl, 'https://second.com');
      expect(controller.state.progress, 0.0);
      expect(controller.state.isLoading, isTrue);
    });

    test('progress at 0 still shows as loading', () {
      controller.onProgress(0);
      expect(controller.state.isLoading, isTrue);
      expect(controller.state.progress, 0.0);
    });

    test('progress at 99 still shows as loading', () {
      controller.onProgress(99);
      expect(controller.state.isLoading, isTrue);
    });
  });
}
