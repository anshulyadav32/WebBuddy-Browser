import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/domain/blocked_request.dart';
import 'package:web_buddy/features/privacy/presentation/widgets/blocked_request_tile.dart';

void main() {
  group('BlockedRequestTile', () {
    testWidgets('displays domain and filter text', (tester) async {
      final request = BlockedRequest(
        url: 'https://ad.doubleclick.net/ad.js',
        domain: 'ad.doubleclick.net',
        matchedFilter: '||doubleclick.net^',
        blockedAt: DateTime(2025, 6, 15, 10, 30, 0),
        isTracker: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BlockedRequestTile(request: request)),
        ),
      );

      expect(find.text('ad.doubleclick.net'), findsOneWidget);
      expect(find.text('||doubleclick.net^'), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('shows tracker icon for tracker requests', (tester) async {
      final request = BlockedRequest(
        url: 'https://google-analytics.com/analytics.js',
        domain: 'google-analytics.com',
        matchedFilter: '||google-analytics.com^',
        blockedAt: DateTime(2025, 6, 15, 10, 30, 0),
        isTracker: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BlockedRequestTile(request: request)),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.text('google-analytics.com'), findsOneWidget);
    });

    testWidgets('displays time', (tester) async {
      final request = BlockedRequest(
        url: 'https://tracker.com/pixel',
        domain: 'tracker.com',
        matchedFilter: '||tracker.com^',
        blockedAt: DateTime(2025, 6, 15, 14, 5, 30),
        isTracker: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BlockedRequestTile(request: request)),
        ),
      );

      // The time should be displayed in HH:MM:SS format.
      expect(find.textContaining('14:05:30'), findsOneWidget);
    });
  });
}
