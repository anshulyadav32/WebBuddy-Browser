import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';

import '../domain/download_item.dart';
import 'downloads_controller.dart';
import 'widgets/download_tile.dart';

/// Screen showing all downloads with progress and actions.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsControllerProvider);
    final controller = ref.read(downloadsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (downloads.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'clear_finished':
                    controller.clearFinished();
                  case 'clear_all':
                    controller.clearAll();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'clear_finished',
                  child: Text('Clear finished'),
                ),
                PopupMenuItem(value: 'clear_all', child: Text('Clear all')),
              ],
            ),
        ],
      ),
      body: downloads.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No downloads yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: downloads.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                // Reverse chronological order.
                final item = downloads[downloads.length - 1 - index];
                return DownloadTile(
                  item: item,
                  onOpen:
                      item.status == DownloadStatus.completed &&
                          item.savePath != null
                      ? () => _openFile(item.savePath!)
                      : null,
                  onCancel: item.status == DownloadStatus.downloading
                      ? () => controller.cancelDownload(item.id)
                      : null,
                  onDelete: () => controller.removeDownload(item.id),
                );
              },
            ),
    );
  }

  void _openFile(String path) {
    OpenFile.open(path);
  }
}
