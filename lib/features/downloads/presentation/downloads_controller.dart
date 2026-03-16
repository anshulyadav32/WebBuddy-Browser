import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/storage_service.dart';
import '../../settings/presentation/settings_controller.dart';
import '../data/download_service.dart';
import '../data/downloads_repository.dart';
import '../domain/download_item.dart';

// ── Providers ────────────────────────────────────────────────────────

final downloadsRepositoryProvider = Provider<DownloadsRepository>((ref) {
  return DownloadsRepository(ref.watch(storageServiceProvider));
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

final downloadsControllerProvider =
    StateNotifierProvider<DownloadsController, List<DownloadItem>>((ref) {
      final repo = ref.watch(downloadsRepositoryProvider);
      final service = ref.watch(downloadServiceProvider);
      return DownloadsController(repo, service);
    });

// ── Controller ───────────────────────────────────────────────────────

class DownloadsController extends StateNotifier<List<DownloadItem>> {
  DownloadsController(this._repo, this._service) : super(_repo.loadAll());

  final DownloadsRepository _repo;
  final DownloadService _service;

  /// Starts a download for the given [url].
  Future<void> enqueueDownload(String url) async {
    final item = await _service.startDownload(
      url,
      onProgress: _onProgress,
      onComplete: _onComplete,
    );

    state = [...state, item];
    await _repo.saveAll(state);
  }

  void _onProgress(String id, int received, int total) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(
            receivedBytes: received,
            totalBytes: total > 0 ? total : null,
            status: DownloadStatus.downloading,
          )
        else
          item,
    ];
    // Don't persist on every progress tick for performance.
  }

  void _onComplete(String id, DownloadStatus status, String? savePath) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(status: status, savePath: savePath)
        else
          item,
    ];
    _repo.saveAll(state);
  }

  /// Cancels an in-progress download.
  void cancelDownload(String id) {
    _service.cancelDownload(id);
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(status: DownloadStatus.cancelled)
        else
          item,
    ];
    _repo.saveAll(state);
  }

  /// Removes a single download item from the list.
  void removeDownload(String id) {
    _service.cancelDownload(id); // Cancel if still running.
    state = state.where((item) => item.id != id).toList();
    _repo.saveAll(state);
  }

  /// Clears all completed, failed, and cancelled downloads.
  void clearFinished() {
    state = state
        .where(
          (item) =>
              item.status == DownloadStatus.downloading ||
              item.status == DownloadStatus.queued,
        )
        .toList();
    _repo.saveAll(state);
  }

  /// Clears all downloads.
  void clearAll() {
    // Cancel any in-progress downloads.
    for (final item in state) {
      if (item.status == DownloadStatus.downloading) {
        _service.cancelDownload(item.id);
      }
    }
    state = [];
    _repo.clearAll();
  }
}
