
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/downloads/data/downloads_repository.dart';
import 'package:web_buddy/features/downloads/domain/download_item.dart';

void main() {
  group('DownloadsRepository', () {
    late SharedPreferences prefs;
    late DownloadsRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repo = DownloadsRepository(StorageService(prefs));
    });

    test('loadAll returns empty list when nothing persisted', () {
      expect(repo.loadAll(), isEmpty);
    });

    test('saveAll then loadAll round-trips', () async {
      final items = [
        DownloadItem(
          id: '1',
          url: 'https://example.com/file.pdf',
          fileName: 'file.pdf',
          savePath: '/tmp/file.pdf',
          totalBytes: 1024,
          receivedBytes: 1024,
          status: DownloadStatus.completed,
          startedAt: DateTime(2025, 1, 1),
        ),
        DownloadItem(
          id: '2',
          url: 'https://example.com/img.png',
          fileName: 'img.png',
          status: DownloadStatus.failed,
          startedAt: DateTime(2025, 1, 2),
        ),
      ];

      await repo.saveAll(items);
      final loaded = repo.loadAll();

      expect(loaded.length, 2);
      expect(loaded[0].id, '1');
      expect(loaded[0].fileName, 'file.pdf');
      expect(loaded[0].status, DownloadStatus.completed);
      expect(loaded[0].totalBytes, 1024);
      expect(loaded[1].id, '2');
      expect(loaded[1].status, DownloadStatus.failed);
    });

    test('clearAll removes data', () async {
      final items = [
        DownloadItem(
          id: '1',
          url: 'https://example.com/file.pdf',
          fileName: 'file.pdf',
          startedAt: DateTime(2025, 1, 1),
        ),
      ];
      await repo.saveAll(items);
      await repo.clearAll();

      expect(repo.loadAll(), isEmpty);
    });

    test('loadAll handles corrupt JSON gracefully', () async {
      await prefs.setString('downloads.items', 'not-json');
      expect(repo.loadAll(), isEmpty);
    });
  });
}
