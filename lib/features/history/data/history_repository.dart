import 'dart:convert';

import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/history/domain/history_item.dart';

/// Persists browsing history to SharedPreferences as JSON.
class HistoryRepository {
  const HistoryRepository(this._storage);

  final StorageService _storage;

  static const _key = 'history.items';

  /// Loads all persisted history items (newest first).
  List<HistoryItem> loadAll() {
    final raw = _storage.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final items = list
          .map((e) => _historyFromMap(e as Map<String, dynamic>))
          .toList();
      items.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
      return items;
    } catch (_) {
      return [];
    }
  }

  /// Saves the full list of history items.
  Future<void> saveAll(List<HistoryItem> items) async {
    final encoded = jsonEncode(items.map(_historyToMap).toList());
    await _storage.setString(_key, encoded);
  }

  /// Adds a history item.
  Future<void> add(HistoryItem item) async {
    final all = loadAll();
    all.insert(0, item);
    await saveAll(all);
  }

  /// Removes a single history item by id.
  Future<void> removeById(String id) async {
    final all = loadAll().where((h) => h.id != id).toList();
    await saveAll(all);
  }

  /// Clears all history.
  Future<void> clearAll() async {
    await _storage.remove(_key);
  }

  static Map<String, dynamic> _historyToMap(HistoryItem h) => {
    'id': h.id,
    'url': h.url,
    'title': h.title,
    'faviconUrl': h.faviconUrl,
    'visitedAt': h.visitedAt.toIso8601String(),
  };

  static HistoryItem _historyFromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'] as String,
      url: map['url'] as String,
      title: map['title'] as String,
      faviconUrl: map['faviconUrl'] as String?,
      visitedAt: DateTime.parse(map['visitedAt'] as String),
    );
  }
}
