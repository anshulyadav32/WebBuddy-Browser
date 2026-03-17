import 'package:flutter/material.dart';

/// A reusable polished empty-state view.
///
/// Used for new-tab pages, empty bookmarks, empty history,
/// empty downloads, and empty blocked-requests lists.
class BrowserEmptyView extends StatelessWidget {
  const BrowserEmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  // ── Convenience named constructors ─────────────────────────────

  const BrowserEmptyView.newTab({super.key})
      : icon = Icons.explore_outlined,
        title = 'Start exploring',
        subtitle = 'Type a URL or search term in the address bar above.',
        actionLabel = null,
        onAction = null;

  const BrowserEmptyView.bookmarks({super.key, this.onAction})
      : icon = Icons.bookmark_outline_rounded,
        title = 'No bookmarks yet',
        subtitle = 'Pages you bookmark will appear here.',
        actionLabel = null;

  const BrowserEmptyView.history({super.key, this.onAction})
      : icon = Icons.history_rounded,
        title = 'No history yet',
        subtitle = 'Pages you visit will appear here.',
        actionLabel = null;

  const BrowserEmptyView.downloads({super.key, this.onAction})
      : icon = Icons.download_outlined,
        title = 'No downloads yet',
        subtitle = 'Files you download will appear here.',
        actionLabel = null;

  const BrowserEmptyView.blockedRequests({super.key, this.onAction})
      : icon = Icons.shield_outlined,
        title = 'No blocked requests',
        subtitle = 'Trackers and ads blocked by Shields will appear here.',
        actionLabel = null;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withAlpha(80),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: cs.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
