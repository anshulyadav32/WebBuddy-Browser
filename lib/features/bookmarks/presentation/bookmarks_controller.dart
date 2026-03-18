import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../settings/presentation/settings_controller.dart';
import '../data/bookmarks_repository.dart';
import '../domain/bookmark.dart';

// ── Providers ────────────────────────────────────────────────────────

final bookmarksRepositoryProvider = Provider<BookmarksRepository>((ref) {
  return BookmarksRepository(ref.watch(storageServiceProvider));
});

final bookmarksControllerProvider =
    StateNotifierProvider<BookmarksController, List<Bookmark>>((ref) {
      final repo = ref.watch(bookmarksRepositoryProvider);
      return BookmarksController(repo);
    });

// ── Controller ───────────────────────────────────────────────────────

class BookmarksController extends StateNotifier<List<Bookmark>> {
  BookmarksController(this._repo) : super(_repo.loadAll());

  final BookmarksRepository _repo;

  /// Reloads bookmarks from the repository.
  Future<void> loadBookmarks() async {
    state = await _repo.getAllBookmarks();
  }

  /// Returns whether the given URL is bookmarked.
  Future<bool> isBookmarked(String url) async => _repo.exists(url);

  /// Legacy sync helper for existing internal checks.
  bool isBookmarkedSync(String url) => state.any((b) => b.url == url);

  /// Adds a bookmark and refreshes state.
  Future<void> addBookmark(Bookmark bookmark) async {
    await _repo.saveBookmark(bookmark);
    await loadBookmarks();
  }

  /// Toggles a bookmark for the given URL.
  ///
  /// If the URL is already bookmarked, removes it.
  /// If not, adds it using the provided [title] (falls back to [url]).
  Future<void> toggleBookmark({
    required String title,
    required String url,
  }) async {
    if (await isBookmarked(url)) {
      await removeBookmarkByUrl(url);
    } else {
      final bookmark = Bookmark(
        id: const Uuid().v4(),
        url: url,
        title: title.isNotEmpty ? title : url,
        createdAt: DateTime.now(),
      );
      await addBookmark(bookmark);
    }
  }

  /// Legacy API retained for compatibility with existing callers/tests.
  Future<void> toggleBookmarkLegacy(String url, {String? title}) async {
    await toggleBookmark(
      url: url,
      title: (title != null && title.isNotEmpty) ? title : url,
    );
  }

  /// Removes a bookmark by URL.
  Future<void> removeBookmarkByUrl(String url) async {
    await _repo.deleteBookmark(url);
    await loadBookmarks();
  }

  /// Legacy API retained for compatibility with existing callers/tests.
  Future<void> removeBookmark(String url) => removeBookmarkByUrl(url);

  /// Clears all bookmarks.
  Future<void> clearAllBookmarks() async {
    await _repo.clearAll();
    state = [];
  }

  /// Legacy API retained for compatibility with existing callers/tests.
  Future<void> clearAll() => clearAllBookmarks();
}
