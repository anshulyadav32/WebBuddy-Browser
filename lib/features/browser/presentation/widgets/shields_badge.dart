import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/features/privacy/presentation/providers/privacy_provider.dart';

/// Badge showing the number of blocked requests for a tab.
class ShieldsBadge extends ConsumerWidget {
  final String tabId;

  const ShieldsBadge({super.key, required this.tabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedCount = ref.watch(blockedCountProvider(tabId));
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        _showShieldsPanel(context, ref);
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield,
              size: 18,
              color: blockedCount > 0
                  ? Colors.green
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            if (blockedCount > 0) ...[
              const SizedBox(width: 2),
              Text(
                blockedCount > 999 ? '999+' : blockedCount.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showShieldsPanel(BuildContext context, WidgetRef ref) {
    final blockedUrls = ref.read(blockedUrlsProvider(tabId));
    final blockedCount = ref.read(blockedCountProvider(tabId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.shield, color: Colors.green, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Shields Up',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      Text(
                        '$blockedCount blocked',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: blockedUrls.isEmpty
                        ? const Center(
                            child: Text('No blocked requests on this page'),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: blockedUrls.length,
                            itemBuilder: (context, index) {
                              final item = blockedUrls[index];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.block,
                                    size: 16, color: Colors.red),
                                title: Text(
                                  item.url,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                subtitle: item.matchedRule != null
                                    ? Text(
                                        'Rule: ${item.matchedRule}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
