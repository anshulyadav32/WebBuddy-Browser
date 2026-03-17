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
  void loadBookmarks() {
    state = _repo.loadAll();
  }

  /// Returns whether the given URL is bookmarked.
  bool isBookmarked(String url) => state.any((b) => b.url == url);

  /// Toggles a bookmark for the given URL.
  ///
  /// If the URL is already bookmarked, removes it.
  /// If not, adds it using the provided [title] (falls back to [url]).
  Future<void> toggleBookmark(String url, {String? title}) async {
    if (isBookmarked(url)) {
      await _repo.removeByUrl(url);
    } else {
      final bookmark = Bookmark(
        id: const Uuid().v4(),
        url: url,
        title: (title != null && title.isNotEmpty) ? title : url,
        createdAt: DateTime.now(),
      );
      await _repo.add(bookmark);
    }
    state = _repo.loadAll();
  }

  /// Removes a bookmark by URL.
  Future<void> removeBookmark(String url) async {
    await _repo.removeByUrl(url);
    state = _repo.loadAll();
  }

  /// Clears all bookmarks.
  Future<void> clearAll() async {
    await _repo.clearAll();
    state = [];
  }
}
