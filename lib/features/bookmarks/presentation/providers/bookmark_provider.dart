import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/core/di/providers.dart';
import 'package:web_buddy/shared/data/database/app_database.dart';

/// Provider for the list of bookmarks with real-time updates.
final bookmarkListProvider = StreamProvider<List<Bookmark>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.bookmarks).watch();
});

/// Provider for bookmarks in a specific folder.
final bookmarksInFolderProvider =
    FutureProvider.family<List<Bookmark>, int?>((ref, folderId) {
  final db = ref.watch(databaseProvider);
  return db.getBookmarksInFolder(folderId);
});

/// Whether a URL is bookmarked.
final isBookmarkedProvider = FutureProvider.family<bool, String>((ref, url) {
  final db = ref.watch(databaseProvider);
  return db.isBookmarked(url);
});

/// Bookmark actions notifier.
final bookmarkActionsProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return BookmarkActions(db);
});

class BookmarkActions {
  final AppDatabase _db;

  BookmarkActions(this._db);

  Future<int> addBookmark({
    required String title,
    required String url,
    String? favicon,
    int? parentFolderId,
  }) {
    return _db.insertBookmark(BookmarksCompanion.insert(
      title: Value(title),
      url: url,
      favicon: Value(favicon),
      parentFolderId: Value(parentFolderId),
    ));
  }

  Future<int> addFolder({
    required String title,
    int? parentFolderId,
  }) {
    return _db.insertBookmark(BookmarksCompanion.insert(
      title: Value(title),
      url: '',
      isFolder: const Value(true),
      parentFolderId: Value(parentFolderId),
    ));
  }

  Future<void> removeBookmark(int id) => _db.deleteBookmark(id);

  Future<void> toggleBookmark({
    required String url,
    required String title,
    String? favicon,
  }) async {
    final isBookmarked = await _db.isBookmarked(url);
    if (isBookmarked) {
      final bookmarks = await _db.getAllBookmarks();
      final existing = bookmarks.where((b) => b.url == url).firstOrNull;
      if (existing != null) {
        await _db.deleteBookmark(existing.id);
      }
    } else {
      await addBookmark(title: title, url: url, favicon: favicon);
    }
  }
}
