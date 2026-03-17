import 'package:flutter/material.dart';

import '../../domain/shield_stats.dart';

/// A compact tile showing a single shield statistic (e.g. "Ads blocked: 12").
class ShieldStatTile extends StatelessWidget {
  const ShieldStatTile({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    this.color,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color? color;

  /// Convenience factory for creating the standard trio of stat tiles.
  static List<ShieldStatTile> fromStats(
    ShieldStats stats, {
    required ColorScheme colorScheme,
  }) {
    return [
      ShieldStatTile(
        label: 'Ads blocked',
        count: stats.adsBlocked,
        icon: Icons.block,
        color: colorScheme.error,
      ),
      ShieldStatTile(
        label: 'Trackers blocked',
        count: stats.trackersBlocked,
        icon: Icons.visibility_off,
        color: colorScheme.tertiary,
      ),
      ShieldStatTile(
        label: 'Total blocked',
        count: stats.totalBlocked,
        icon: Icons.shield,
        color: colorScheme.primary,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveColor = color ?? cs.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: effectiveColor.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: effectiveColor.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: effectiveColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: effectiveColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
