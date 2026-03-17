import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_buddy/features/browser/presentation/widgets/browser_error_view.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BrowserErrorView', () {
    testWidgets('renders retry button', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        _wrap(BrowserErrorView(
          url: 'https://example.com',
          onRetry: () => retried = true,
        )),
      );

      expect(find.text('Try again'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('renders URL', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserErrorView(url: 'https://example.com')),
      );

      expect(find.text('https://example.com'), findsOneWidget);
    });

    testWidgets('shows friendly title for generic error', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserErrorView(url: 'https://example.com')),
      );

      expect(find.text('Can\u2019t reach this page'), findsOneWidget);
    });

    testWidgets('shows no-internet title for disconnected error',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserErrorView(
          url: 'https://example.com',
          errorDescription: 'net::ERR_INTERNET_DISCONNECTED',
        )),
      );

      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('shows site-not-found for DNS error', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserErrorView(
          url: 'https://nope.invalid',
          errorDescription: 'net::ERR_NAME_NOT_RESOLVED',
        )),
      );

      expect(find.text('Site not found'), findsOneWidget);
    });

    testWidgets('shows timeout title', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserErrorView(
          url: 'https://slow.example.com',
          errorDescription: 'net::ERR_CONNECTION_TIMED_OUT',
        )),
      );

      expect(find.text('Connection timed out'), findsOneWidget);
    });

    testWidgets('shows SSL error title', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserErrorView(
          url: 'https://expired.example.com',
          errorDescription: 'net::ERR_SSL_PROTOCOL_ERROR',
        )),
      );

      expect(find.text('Connection is not secure'), findsOneWidget);
    });

    testWidgets('shows error description when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserErrorView(
          url: 'https://example.com',
          errorDescription: 'some_custom_error',
        )),
      );

      expect(find.text('some_custom_error'), findsOneWidget);
    });

    testWidgets('shows cloud_off icon for generic error', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserErrorView(url: 'https://example.com')),
      );

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('shows wifi_off icon for network error', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserErrorView(
          url: 'https://example.com',
          errorDescription: 'net::ERR_INTERNET_DISCONNECTED',
        )),
      );

      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('maps iOS error code -1009 to no-internet', (tester) async {
      await tester.pumpWidget(
        _wrap(const BrowserErrorView(
          url: 'https://example.com',
          errorCode: -1009,
        )),
      );

      expect(find.text('No internet connection'), findsOneWidget);
    });
  });
}
