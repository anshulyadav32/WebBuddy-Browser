import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/downloads/domain/download_item.dart';
import 'package:web_buddy/features/downloads/domain/file_name_utils.dart';

/// Tests for download service behavior (file path generation, callbacks).
///
/// Note: Actual file download tests require platform channels (path_provider,
/// dio network access) and are best covered in integration tests. These tests
/// verify the logic that can be tested without platform dependencies.
void main() {
  group('DownloadService — file path generation logic', () {
    test('FileNameUtils derives correct filename from URL', () {
      final name = FileNameUtils.deriveFromUrl(
        'https://cdn.example.com/files/report.pdf',
      );
      expect(name, 'report.pdf');
    });

    test('FileNameUtils falls back for URL without filename', () {
      final name = FileNameUtils.deriveFromUrl('https://example.com/');
      expect(name, 'download');
    });

    test('FileNameUtils derives from Content-Disposition', () {
      final name = FileNameUtils.deriveFromContentDisposition(
        'attachment; filename="data.csv"',
      );
      expect(name, 'data.csv');
    });
  });

  group('DownloadItem — progress and status', () {
    test('progress is 0 when totalBytes is 0', () {
      final item = DownloadItem(
        id: '1',
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        totalBytes: 0,
        receivedBytes: 100,
        startedAt: DateTime.now(),
      );
      expect(item.progress, 0.0);
    });

    test('progress calculated correctly', () {
      final item = DownloadItem(
        id: '1',
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        totalBytes: 1000,
        receivedBytes: 500,
        startedAt: DateTime.now(),
      );
      expect(item.progress, closeTo(0.5, 0.001));
    });

    test('progress clamped to 1.0', () {
      final item = DownloadItem(
        id: '1',
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        totalBytes: 100,
        receivedBytes: 200, // more than total
        startedAt: DateTime.now(),
      );
      expect(item.progress, 1.0);
    });

    test('copyWith updates status correctly', () {
      final item = DownloadItem(
        id: '1',
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        status: DownloadStatus.queued,
        startedAt: DateTime.now(),
      );

      final downloading = item.copyWith(status: DownloadStatus.downloading);
      expect(downloading.status, DownloadStatus.downloading);

      final completed = downloading.copyWith(
        status: DownloadStatus.completed,
        savePath: '/path/to/file.zip',
      );
      expect(completed.status, DownloadStatus.completed);
      expect(completed.savePath, '/path/to/file.zip');
    });

    test('copyWith preserves unchanged fields', () {
      final item = DownloadItem(
        id: '1',
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        totalBytes: 1000,
        status: DownloadStatus.downloading,
        startedAt: DateTime(2024, 1, 1),
      );

      final updated = item.copyWith(receivedBytes: 500);
      expect(updated.id, '1');
      expect(updated.url, 'https://example.com/file.zip');
      expect(updated.fileName, 'file.zip');
      expect(updated.totalBytes, 1000);
      expect(updated.receivedBytes, 500);
      expect(updated.status, DownloadStatus.downloading);
    });

    test('failed status stores correctly', () {
      final item = DownloadItem(
        id: '1',
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        startedAt: DateTime.now(),
      );

      final failed = item.copyWith(status: DownloadStatus.failed);
      expect(failed.status, DownloadStatus.failed);
    });

    test('serialization round-trip preserves data', () {
      final now = DateTime.now();
      final item = DownloadItem(
        id: 'test-id',
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        savePath: '/tmp/file.zip',
        mimeType: 'application/zip',
        totalBytes: 1024,
        receivedBytes: 512,
        status: DownloadStatus.downloading,
        startedAt: now,
      );

      final map = item.toMap();
      final restored = DownloadItem.fromMap(map);

      expect(restored.id, item.id);
      expect(restored.url, item.url);
      expect(restored.fileName, item.fileName);
      expect(restored.savePath, item.savePath);
      expect(restored.mimeType, item.mimeType);
      expect(restored.totalBytes, item.totalBytes);
      expect(restored.receivedBytes, item.receivedBytes);
      expect(restored.status, item.status);
    });
  });

  group('DownloadItem — edge cases', () {
    test('cancelled status', () {
      final item = DownloadItem(
        id: '1',
        url: 'https://example.com/file.zip',
        fileName: 'file.zip',
        startedAt: DateTime.now(),
      );
      final cancelled = item.copyWith(status: DownloadStatus.cancelled);
      expect(cancelled.status, DownloadStatus.cancelled);
    });

    test('equality based on id', () {
      final a = DownloadItem(
        id: 'same',
        url: 'https://a.com/x',
        fileName: 'x',
        startedAt: DateTime(2024),
      );
      final b = DownloadItem(
        id: 'same',
        url: 'https://b.com/y',
        fileName: 'y',
        startedAt: DateTime(2025),
      );
      expect(a, equals(b));
    });

    test('different ids are not equal', () {
      final a = DownloadItem(
        id: 'id1',
        url: 'https://a.com/x',
        fileName: 'x',
        startedAt: DateTime(2024),
      );
      final b = DownloadItem(
        id: 'id2',
        url: 'https://a.com/x',
        fileName: 'x',
        startedAt: DateTime(2024),
      );
      expect(a, isNot(equals(b)));
    });
  });
}
