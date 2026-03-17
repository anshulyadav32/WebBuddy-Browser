import 'dart:convert';

import '../../../core/services/storage_service.dart';
import '../domain/offline_page.dart';

class OfflinePagesRepository {
  const OfflinePagesRepository(this._storage);

  final StorageService _storage;

  static const _key = 'offline.pages';

  List<OfflinePage> loadAll() {
    final raw = _storage.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => OfflinePage.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<OfflinePage> pages) async {
    final encoded = jsonEncode(pages.map((e) => e.toMap()).toList());
    await _storage.setString(_key, encoded);
  }

  Future<void> clearAll() async {
    await _storage.remove(_key);
  }
}
