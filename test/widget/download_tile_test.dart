import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/downloads/domain/download_item.dart';
import 'package:web_buddy/features/downloads/presentation/widgets/download_tile.dart';

void main() {
  group('DownloadTile', () {
    testWidgets('displays filename for completed download', (tester) async {
      final item = DownloadItem(
        id: '1',
        url: 'https://example.com/report.pdf',
        fileName: 'report.pdf',
        status: DownloadStatus.completed,
        totalBytes: 2048,
        receivedBytes: 2048,
        startedAt: DateTime(2025, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadTile(
              item: item,
              onOpen: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows progress for downloading item', (tester) async {
      final item = DownloadItem(
        id: '2',
        url: 'https://example.com/video.mp4',
        fileName: 'video.mp4',
        status: DownloadStatus.downloading,
        totalBytes: 10000,
        receivedBytes: 5000,
        startedAt: DateTime(2025, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadTile(
              item: item,
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('video.mp4'), findsOneWidget);
      // Cancel button should be visible.
      expect(find.byIcon(Icons.close), findsOneWidget);
      // Progress indicator.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows failed state', (tester) async {
      final item = DownloadItem(
        id: '3',
        url: 'https://example.com/broken.zip',
        fileName: 'broken.zip',
        status: DownloadStatus.failed,
        startedAt: DateTime(2025, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadTile(
              item: item,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('broken.zip'), findsOneWidget);
      expect(find.text('Download failed'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows cancelled state', (tester) async {
      final item = DownloadItem(
        id: '4',
        url: 'https://example.com/cancelled.zip',
        fileName: 'cancelled.zip',
        status: DownloadStatus.cancelled,
        startedAt: DateTime(2025, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadTile(
              item: item,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('cancelled.zip'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('shows queued state', (tester) async {
      final item = DownloadItem(
        id: '5',
        url: 'https://example.com/queued.zip',
        fileName: 'queued.zip',
        status: DownloadStatus.queued,
        startedAt: DateTime(2025, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadTile(item: item, onDelete: () {}),
          ),
        ),
      );

      expect(find.text('queued.zip'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
    });
  });
}
