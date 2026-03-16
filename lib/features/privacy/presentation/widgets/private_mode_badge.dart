import 'package:flutter/material.dart';

/// A small badge indicating the browser is in private/incognito mode.
class PrivateModeBadge extends StatelessWidget {
  const PrivateModeBadge({super.key, this.compact = false});

  /// If true, shows only the icon without text.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.tertiary.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.tertiary.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, size: 14, color: cs.tertiary),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              'Private',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
