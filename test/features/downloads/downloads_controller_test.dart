import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/downloads/data/download_service.dart';
import 'package:web_buddy/features/downloads/data/downloads_repository.dart';
import 'package:web_buddy/features/downloads/domain/download_item.dart';
import 'package:web_buddy/features/downloads/presentation/downloads_controller.dart';

/// A fake DownloadService that synchronously returns items without HTTP.
class FakeDownloadService extends DownloadService {
  FakeDownloadService() : super(dio: null);

  int _counter = 0;
  final List<String> cancelledIds = [];

  @override
  Future<DownloadItem> startDownload(
    String url, {
    DownloadProgressCallback? onProgress,
    DownloadCompleteCallback? onComplete,
  }) async {
    _counter++;
    return DownloadItem(
      id: 'dl-$_counter',
      url: url,
      fileName: 'file_$_counter.pdf',
      status: DownloadStatus.downloading,
      startedAt: DateTime(2025, 1, _counter),
    );
  }

  @override
  void cancelDownload(String downloadId) {
    cancelledIds.add(downloadId);
  }
}

void main() {
  group('DownloadsController', () {
    late DownloadsRepository repo;
    late FakeDownloadService fakeService;
    late DownloadsController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = DownloadsRepository(StorageService(prefs));
      fakeService = FakeDownloadService();
      controller = DownloadsController(repo, fakeService);
    });

    test('initial state is empty', () {
      expect(controller.state, isEmpty);
    });

    test('enqueueDownload adds item to state', () async {
      await controller.enqueueDownload('https://example.com/file.pdf');

      expect(controller.state.length, 1);
      expect(controller.state.first.url, 'https://example.com/file.pdf');
      expect(controller.state.first.status, DownloadStatus.downloading);
    });

    test('enqueueDownload persists to repository', () async {
      await controller.enqueueDownload('https://example.com/file.pdf');

      final persisted = repo.loadAll();
      expect(persisted.length, 1);
      expect(persisted.first.id, 'dl-1');
    });

    test('removeDownload removes item from state', () async {
      await controller.enqueueDownload('https://example.com/file.pdf');
      controller.removeDownload('dl-1');

      expect(controller.state, isEmpty);
    });

    test('removeDownload cancels if still active', () async {
      await controller.enqueueDownload('https://example.com/file.pdf');
      controller.removeDownload('dl-1');

      expect(fakeService.cancelledIds, contains('dl-1'));
    });

    test('cancelDownload sets status to cancelled', () async {
      await controller.enqueueDownload('https://example.com/file.pdf');
      controller.cancelDownload('dl-1');

      expect(controller.state.first.status, DownloadStatus.cancelled);
      expect(fakeService.cancelledIds, contains('dl-1'));
    });

    test('clearAll empties the list', () async {
      await controller.enqueueDownload('https://example.com/a.pdf');
      await controller.enqueueDownload('https://example.com/b.pdf');

      controller.clearAll();

      expect(controller.state, isEmpty);
    });

    test('clearFinished keeps active downloads only', () async {
      await controller.enqueueDownload('https://example.com/a.pdf');
      await controller.enqueueDownload('https://example.com/b.pdf');

      // Mark first as completed.
      controller.state = [
        controller.state[0].copyWith(status: DownloadStatus.completed),
        controller.state[1],
      ];

      controller.clearFinished();

      expect(controller.state.length, 1);
      expect(controller.state.first.id, 'dl-2');
      expect(controller.state.first.status, DownloadStatus.downloading);
    });

    test('multiple enqueue builds ordered list', () async {
      await controller.enqueueDownload('https://example.com/a.pdf');
      await controller.enqueueDownload('https://example.com/b.pdf');
      await controller.enqueueDownload('https://example.com/c.pdf');

      expect(controller.state.length, 3);
      expect(controller.state[0].id, 'dl-1');
      expect(controller.state[1].id, 'dl-2');
      expect(controller.state[2].id, 'dl-3');
    });
  });
}
