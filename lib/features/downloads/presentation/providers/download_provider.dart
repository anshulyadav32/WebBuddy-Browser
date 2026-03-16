import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/core/di/providers.dart';
import 'package:web_buddy/shared/data/database/app_database.dart';

/// Download status constants.
abstract class DownloadStatus {
  static const int pending = 0;
  static const int downloading = 1;
  static const int completed = 2;
  static const int failed = 3;
  static const int cancelled = 4;
}

/// Provider for all downloads.
final downloadListProvider = FutureProvider<List<Download>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllDownloads();
});

/// Download actions.
final downloadActionsProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return DownloadActions(db);
});

class DownloadActions {
  final AppDatabase _db;

  DownloadActions(this._db);

  Future<int> startDownload({
    required String url,
    required String fileName,
    required String filePath,
    int? fileSize,
    String? mimeType,
  }) {
    return _db.insertDownload(DownloadsCompanion.insert(
      url: url,
      fileName: fileName,
      filePath: filePath,
      fileSize: Value(fileSize ?? 0),
      mimeType: Value(mimeType),
      status: const Value(DownloadStatus.downloading),
    ));
  }

  Future<void> updateStatus(int id, int status, {int? downloadedBytes}) {
    return _db.updateDownloadStatus(id, status,
        downloadedBytes: downloadedBytes);
  }

  Future<void> removeDownload(int id) => _db.deleteDownload(id);
}
