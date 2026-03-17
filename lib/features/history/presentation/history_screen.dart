import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../browser/presentation/widgets/browser_empty_view.dart';
import 'history_controller.dart';

/// Full-page screen for viewing and managing browsing history.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyControllerProvider);
    final controller = ref.read(historyControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all',
              onPressed: () => controller.clearAll(),
            ),
        ],
      ),
      body: history.isEmpty
          ? const BrowserEmptyView.history()
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${item.url}\n${DateFormat.yMd().add_Hm().format(item.visitedAt)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete',
                    onPressed: () => controller.deleteHistoryItem(item.id),
                  ),
                  onTap: () => Navigator.pop(context, item.url),
                );
              },
            ),
    );
  }
}
