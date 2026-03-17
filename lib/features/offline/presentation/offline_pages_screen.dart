import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../browser/presentation/browser_controller.dart';
import '../../browser/presentation/widgets/browser_empty_view.dart';
import '../domain/offline_page.dart';
import 'offline_pages_controller.dart';

class OfflinePagesScreen extends ConsumerWidget {
  const OfflinePagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(offlinePagesControllerProvider);
    final controller = ref.read(offlinePagesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline pages'),
        actions: [
          if (pages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all',
              onPressed: () => controller.clearAll(),
            ),
        ],
      ),
      body: pages.isEmpty
          ? const BrowserEmptyView(
              icon: Icons.offline_pin_outlined,
              title: 'No offline pages yet',
              subtitle: 'Saved pages will appear here for offline reading.',
            )
          : ListView.separated(
              itemCount: pages.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final page = pages[index];
                return _OfflinePageTile(
                  page: page,
                  onOpen: () async {
                    await _openOfflinePage(context, ref, page);
                  },
                  onDelete: () => controller.remove(page.id),
                );
              },
            ),
    );
  }

  Future<void> _openOfflinePage(
    BuildContext context,
    WidgetRef ref,
    OfflinePage page,
  ) async {
    final file = File(page.filePath);
    if (!file.existsSync()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offline file not found on disk.')),
        );
      }
      return;
    }

    await ref
        .read(browserControllerProvider.notifier)
        .loadInput(Uri.file(page.filePath).toString());
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}

class _OfflinePageTile extends StatelessWidget {
  const _OfflinePageTile({
    required this.page,
    required this.onOpen,
    required this.onDelete,
  });

  final OfflinePage page;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.offline_pin_rounded),
      title: Text(page.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(page.url, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onOpen,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Delete offline page',
        onPressed: onDelete,
      ),
    );
  }
}
