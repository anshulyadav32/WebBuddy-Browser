import 'dart:convert';

import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/downloads/domain/download_item.dart';

/// Persists download metadata to SharedPreferences.
class DownloadsRepository {
  const DownloadsRepository(this._storage);

  final StorageService _storage;

  static const _key = 'downloads.items';

  /// Loads all persisted download items.
  List<DownloadItem> loadAll() {
    final raw = _storage.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => DownloadItem.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves the full list of download items.
  Future<void> saveAll(List<DownloadItem> items) async {
    final encoded = jsonEncode(items.map((e) => e.toMap()).toList());
    await _storage.setString(_key, encoded);
  }

  /// Clears all persisted download items.
  Future<void> clearAll() async {
    await _storage.remove(_key);
  }
}
