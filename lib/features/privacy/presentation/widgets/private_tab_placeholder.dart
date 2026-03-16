import 'package:flutter/material.dart';

/// A placeholder shown in new private tabs before any URL is loaded.
class PrivateTabPlaceholder extends StatelessWidget {
  const PrivateTabPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: cs.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield, size: 56, color: cs.tertiary),
              const SizedBox(height: 16),
              Text(
                'Private Browsing',
                style: textTheme.headlineSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your browsing history won\'t be saved in this tab.\n'
                'Cookies and site data will be cleared when all\n'
                'private tabs are closed.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(context, Icons.history, 'History is not recorded'),
                    const SizedBox(height: 8),
                    _infoRow(
                      context,
                      Icons.cookie_outlined,
                      'Cookies cleared on close',
                    ),
                    const SizedBox(height: 8),
                    _infoRow(
                      context,
                      Icons.bookmark_add_outlined,
                      'Bookmarks can still be saved',
                    ),
                    const SizedBox(height: 8),
                    _infoRow(
                      context,
                      Icons.download_outlined,
                      'Downloads are still saved to disk',
                    ),
                    const SizedBox(height: 8),
                    _infoRow(
                      context,
                      Icons.visibility,
                      'Your ISP can still see your traffic',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
