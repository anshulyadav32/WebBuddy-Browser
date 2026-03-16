import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/core/di/providers.dart';
import 'package:web_buddy/shared/data/database/app_database.dart';

/// Provider for recent history entries.
final historyListProvider = FutureProvider<List<HistoryEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getRecentHistory(limit: 200);
});

/// Search history provider.
final historySearchProvider =
    FutureProvider.family<List<HistoryEntry>, String>((ref, query) {
  final db = ref.watch(databaseProvider);
  return db.searchHistory(query);
});

/// History actions.
final historyActionsProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return HistoryActions(db);
});

class HistoryActions {
  final AppDatabase _db;

  HistoryActions(this._db);

  Future<void> addEntry({
    required String title,
    required String url,
    String? favicon,
  }) {
    return _db.insertHistoryEntry(HistoryEntriesCompanion.insert(
      title: Value(title),
      url: url,
      favicon: Value(favicon),
    )).then((_) {});
  }

  Future<void> deleteEntry(int id) => _db.deleteHistoryEntry(id);

  Future<void> clearAll() => _db.clearHistory();

  Future<void> clearBefore(DateTime date) => _db.clearHistoryBefore(date);
}
