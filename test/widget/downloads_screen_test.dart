import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/downloads/data/download_service.dart';
import 'package:web_buddy/features/downloads/data/downloads_repository.dart';
import 'package:web_buddy/features/downloads/domain/download_item.dart';
import 'package:web_buddy/features/downloads/presentation/downloads_controller.dart';
import 'package:web_buddy/features/downloads/presentation/downloads_screen.dart';

/// Minimal fake service that never does real HTTP.
class _FakeService extends DownloadService {
  @override
  Future<DownloadItem> startDownload(
    String url, {
    DownloadProgressCallback? onProgress,
    DownloadCompleteCallback? onComplete,
  }) async {
    return DownloadItem(
      id: 'x',
      url: url,
      fileName: 'x',
      status: DownloadStatus.downloading,
      startedAt: DateTime(2025),
    );
  }

  @override
  void cancelDownload(String downloadId) {}
}

/// Creates a real controller seeded with [items].
Future<DownloadsController> _seededController(List<DownloadItem> items) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final repo = DownloadsRepository(StorageService(prefs));
  final ctrl = DownloadsController(repo, _FakeService());
  ctrl.state = items;
  return ctrl;
}

void main() {
  group('DownloadsScreen', () {
    testWidgets('shows empty state when no downloads', (tester) async {
      final ctrl = await _seededController([]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            downloadsControllerProvider.overrideWith((ref) => ctrl),
          ],
          child: const MaterialApp(home: DownloadsScreen()),
        ),
      );

      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('No downloads yet'), findsOneWidget);
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
    });

    testWidgets('shows download items', (tester) async {
      final items = [
        DownloadItem(
          id: '1',
          url: 'https://example.com/a.pdf',
          fileName: 'report.pdf',
          status: DownloadStatus.completed,
          totalBytes: 2048,
          receivedBytes: 2048,
          startedAt: DateTime(2025, 1, 1),
        ),
        DownloadItem(
          id: '2',
          url: 'https://example.com/b.png',
          fileName: 'image.png',
          status: DownloadStatus.downloading,
          totalBytes: 4096,
          receivedBytes: 1024,
          startedAt: DateTime(2025, 1, 2),
        ),
      ];

      final ctrl = await _seededController(items);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            downloadsControllerProvider.overrideWith((ref) => ctrl),
          ],
          child: const MaterialApp(home: DownloadsScreen()),
        ),
      );

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.text('image.png'), findsOneWidget);
    });

    testWidgets('shows overflow menu when items exist', (tester) async {
      final items = [
        DownloadItem(
          id: '1',
          url: 'https://example.com/a.pdf',
          fileName: 'report.pdf',
          status: DownloadStatus.completed,
          startedAt: DateTime(2025, 1, 1),
        ),
      ];

      final ctrl = await _seededController(items);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            downloadsControllerProvider.overrideWith((ref) => ctrl),
          ],
          child: const MaterialApp(home: DownloadsScreen()),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });
}
