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
    required this.onOpenInPrivate,
  });

  final BrowserTabState tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final VoidCallback onOpenInPrivate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Active + private = tertiary colours; active = primary; private = muted tertiary
    final Color bgColor;
    final Color borderColor;
    final double borderWidth;
    if (isActive && tab.isPrivate) {
      bgColor = cs.tertiaryContainer;
      borderColor = cs.tertiary;
      borderWidth = 2;
    } else if (isActive) {
      bgColor = cs.primaryContainer;
      borderColor = cs.primary;
      borderWidth = 2;
    } else if (tab.isPrivate) {
      bgColor = cs.surfaceContainerHighest.withAlpha(200);
      borderColor = cs.tertiary.withAlpha(100);
      borderWidth = 1;
    } else {
      bgColor = cs.surfaceContainerHighest;
      borderColor = cs.outlineVariant;
      borderWidth = 1;
    }

    return Semantics(
      label:
          '${tab.isPrivate ? "Private tab, " : ""}${tab.title}${isActive ? ", active" : ""}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: borderWidth),
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
                      child: Icon(
                        Icons.lock,
                        size: 14,
                        color: tab.isPrivate && isActive
                            ? cs.onTertiaryContainer
                            : cs.tertiary,
                      ),
                    ),
                  if (isActive)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: tab.isPrivate ? cs.tertiary : cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      tab.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Semantics(
                    label: 'Close tab',
                    button: true,
                    child: GestureDetector(
                      onTap: onClose,
                      child: Icon(Icons.close, size: 18, color: cs.onSurface),
                    ),
                  ),
                  Semantics(
                    label: 'Open in Private Tab',
                    button: true,
                    child: GestureDetector(
                      onTap: onOpenInPrivate,
                      child: Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color: cs.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                tab.currentUrl,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (tab.isLoading) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: tab.progress > 0 ? tab.progress : null,
                    minHeight: 2,
                    backgroundColor: cs.outlineVariant.withAlpha(60),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
