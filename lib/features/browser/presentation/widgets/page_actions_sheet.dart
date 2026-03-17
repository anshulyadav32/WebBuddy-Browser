import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/browser_snackbar_helper.dart';

/// A bottom sheet showing contextual actions for the current page.
///
/// Provides: copy URL, find in page, share (copies to clipboard with
/// a snackbar since `share_plus` is not a dependency), and refresh.
///
/// **Long-press link actions**: `webview_flutter` does not provide a
/// reliable API for intercepting long-press / context-menu events on
/// links or images. This feature would require a platform-specific
/// plugin or JavaScript-bridge approach. We therefore provide page-level
/// actions only.
class PageActionsSheet extends StatelessWidget {
  const PageActionsSheet({
    super.key,
    required this.url,
    required this.title,
    this.onFindInPage,
    this.onReload,
  });

  final String url;
  final String title;
  final VoidCallback? onFindInPage;
  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Page info header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.language, size: 24, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isNotEmpty ? title : 'Untitled',
                          style: textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          url,
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 24),

            // Actions
            _ActionTile(
              icon: Icons.copy_rounded,
              label: 'Copy link',
              semanticLabel: 'Copy page URL to clipboard',
              onTap: () {
                Clipboard.setData(ClipboardData(text: url));
                Navigator.of(context).pop();
                BrowserSnackbarHelper.show(context, 'Link copied to clipboard');
              },
            ),
            _ActionTile(
              icon: Icons.share_rounded,
              label: 'Share page',
              semanticLabel: 'Share current page',
              onTap: () {
                Clipboard.setData(ClipboardData(text: '$title\n$url'));
                Navigator.of(context).pop();
                BrowserSnackbarHelper.show(
                  context,
                  'Page link copied — paste it to share',
                );
              },
            ),
            if (onFindInPage != null)
              _ActionTile(
                icon: Icons.find_in_page_rounded,
                label: 'Find in page',
                semanticLabel: 'Search for text on this page',
                onTap: () {
                  Navigator.of(context).pop();
                  onFindInPage!();
                },
              ),
            if (onReload != null)
              _ActionTile(
                icon: Icons.refresh_rounded,
                label: 'Reload',
                semanticLabel: 'Reload the current page',
                onTap: () {
                  Navigator.of(context).pop();
                  onReload!();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}
