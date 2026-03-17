import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../browser/presentation/widgets/browser_empty_view.dart';
import 'bookmarks_controller.dart';

/// Full-page screen for viewing and managing bookmarks.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksControllerProvider);
    final controller = ref.read(bookmarksControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          if (bookmarks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all',
              onPressed: () => controller.clearAll(),
            ),
        ],
      ),
      body: bookmarks.isEmpty
          ? const BrowserEmptyView.bookmarks()
          : ListView.builder(
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                return ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: Text(
                    bookmark.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    bookmark.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remove bookmark',
                    onPressed: () => controller.removeBookmark(bookmark.url),
                  ),
                  onTap: () => Navigator.pop(context, bookmark.url),
                );
              },
            ),
    );
  }
}
