import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shields_controller.dart';
import 'blocked_request_tile.dart';
import 'shield_stat_tile.dart';

/// A modal panel displaying shields status, stats, and blocked request log.
///
/// Shown when the user taps the shield icon in the browser toolbar.
class ShieldsPanel extends ConsumerWidget {
  const ShieldsPanel({super.key, this.onReload});

  /// Called when the user toggles shields and the page should reload.
  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shieldsState = ref.watch(shieldsControllerProvider);
    final controller = ref.read(shieldsControllerProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ────────────────────────────────────
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header ─────────────────────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.shield,
                    size: 24,
                    color: shieldsState.isEffectivelyEnabled
                        ? cs.primary
                        : cs.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shields', style: textTheme.titleMedium),
                        if (shieldsState.currentDomain != null)
                          Text(
                            shieldsState.currentDomain!,
                            style: textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Per-site toggle.
                  Switch.adaptive(
                    value: shieldsState.currentSiteEnabled,
                    onChanged: shieldsState.globalEnabled
                        ? (_) async {
                            final shouldReload = await controller
                                .toggleCurrentSiteShield();
                            if (shouldReload && context.mounted) {
                              Navigator.pop(context);
                              onReload?.call();
                            }
                          }
                        : null,
                  ),
                ],
              ),

              // ── Status message ────────────────────────────────
              const SizedBox(height: 8),
              _buildStatusMessage(shieldsState, cs, textTheme),

              // ── Stats ──────────────────────────────────────────
              if (shieldsState.isEffectivelyEnabled) ...[
                const SizedBox(height: 16),
                Row(
                  children:
                      ShieldStatTile.fromStats(
                            shieldsState.stats,
                            colorScheme: cs,
                          )
                          .map(
                            (tile) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: tile,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],

              // ── Blocked requests log ───────────────────────────
              if (shieldsState.blockedRequests.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Blocked requests', style: textTheme.titleSmall),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withAlpha(80),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: shieldsState.blockedRequests.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: cs.outlineVariant),
                    itemBuilder: (_, index) {
                      // Show most recent first.
                      final request =
                          shieldsState.blockedRequests[shieldsState
                                  .blockedRequests
                                  .length -
                              1 -
                              index];
                      return BlockedRequestTile(request: request);
                    },
                  ),
                ),
              ],

              // ── Platform caveat ────────────────────────────────
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(60),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: cs.outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Shields block navigation-level requests and hide '
                        'cosmetic ad elements. Sub-resource blocking (scripts, '
                        'images) is limited by platform WebView capabilities.',
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage(
    ShieldsState shieldsState,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    String message;
    Color color;

    if (!shieldsState.globalEnabled) {
      message = 'Shields are disabled globally in Settings.';
      color = cs.error;
    } else if (!shieldsState.currentSiteEnabled) {
      message = 'Shields are down for this site.';
      color = cs.error;
    } else if (!shieldsState.isInitialised) {
      message = 'Loading filter lists\u2026';
      color = cs.onSurfaceVariant;
    } else {
      message = 'Shields are up — protecting this site.';
      color = cs.primary;
    }

    return Row(
      children: [
        Icon(
          shieldsState.isEffectivelyEnabled
              ? Icons.check_circle
              : Icons.warning_amber,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            message,
            style: textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
