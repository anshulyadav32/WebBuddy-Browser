import 'dart:convert';

import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/bookmarks/domain/bookmark.dart';

/// Persists bookmarks to SharedPreferences as JSON.
class BookmarksRepository {
  const BookmarksRepository(this._storage);

  final StorageService _storage;

  static const _key = 'bookmarks.items';

  /// Loads all persisted bookmarks.
  List<Bookmark> loadAll() {
    final raw = _storage.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _bookmarkFromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves the full list of bookmarks.
  Future<void> saveAll(List<Bookmark> items) async {
    final encoded = jsonEncode(items.map(_bookmarkToMap).toList());
    await _storage.setString(_key, encoded);
  }

  /// Adds a bookmark. If a bookmark with the same URL already exists,
  /// it is replaced.
  Future<void> add(Bookmark bookmark) async {
    final all = loadAll().where((b) => b.url != bookmark.url).toList();
    all.add(bookmark);
    await saveAll(all);
  }

  /// Removes a bookmark by URL.
  Future<void> removeByUrl(String url) async {
    final all = loadAll().where((b) => b.url != url).toList();
    await saveAll(all);
  }

  /// Whether a URL is bookmarked.
  bool isBookmarked(String url) {
    return loadAll().any((b) => b.url == url);
  }

  /// Clears all bookmarks.
  Future<void> clearAll() async {
    await _storage.remove(_key);
  }

  static Map<String, dynamic> _bookmarkToMap(Bookmark b) => {
    'id': b.id,
    'url': b.url,
    'title': b.title,
    'faviconUrl': b.faviconUrl,
    'folder': b.folder,
    'createdAt': b.createdAt.toIso8601String(),
  };

  static Bookmark _bookmarkFromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as String,
      url: map['url'] as String,
      title: map['title'] as String,
      faviconUrl: map['faviconUrl'] as String?,
      folder: map['folder'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
