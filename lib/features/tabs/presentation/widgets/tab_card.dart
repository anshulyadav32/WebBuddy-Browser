import 'package:flutter/material.dart';

import '../../domain/models/browser_tab_state.dart';

/// A card representing a single browser tab in the tab switcher.
class TabCard extends StatelessWidget {
  const TabCard({
    super.key,
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  final BrowserTabState tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? cs.primaryContainer
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: cs.primary, width: 2)
              : Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (tab.isPrivate)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(Icons.lock, size: 14, color: cs.primary),
                  ),
                Expanded(
                  child: Text(
                    tab.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close, size: 18, color: cs.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              tab.currentUrl,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
