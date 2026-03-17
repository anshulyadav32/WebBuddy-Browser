import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../settings/presentation/settings_controller.dart';
import '../data/history_repository.dart';
import '../domain/history_item.dart';

// ── Providers ────────────────────────────────────────────────────────

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.watch(storageServiceProvider));
});

final historyControllerProvider =
    StateNotifierProvider<HistoryController, List<HistoryItem>>((ref) {
      final repo = ref.watch(historyRepositoryProvider);
      return HistoryController(repo);
    });

// ── Controller ───────────────────────────────────────────────────────

class HistoryController extends StateNotifier<List<HistoryItem>> {
  HistoryController(this._repo) : super(_repo.loadAll());

  final HistoryRepository _repo;

  /// Adds a history item.
  Future<void> addHistoryItem({
    required String url,
    required String title,
  }) async {
    final item = HistoryItem(
      id: const Uuid().v4(),
      url: url,
      title: title,
      visitedAt: DateTime.now(),
    );
    await _repo.add(item);
    state = _repo.loadAll();
  }

  /// Removes a single history item by id.
  Future<void> deleteHistoryItem(String id) async {
    await _repo.removeById(id);
    state = _repo.loadAll();
  }

  /// Clears all history.
  Future<void> clearAll() async {
    await _repo.clearAll();
    state = [];
  }
}
