import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/core/extensions/string_extensions.dart';
import 'package:web_buddy/core/theme/app_theme.dart';
import 'package:web_buddy/features/tabs/presentation/providers/tab_provider.dart';

/// Desktop-style tab bar strip shown above the toolbar.
class TabBarStrip extends ConsumerWidget {
  const TabBarStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(browserSessionProvider);
    final theme = Theme.of(context);
    final browserTheme = theme.extension<BrowserThemeExtension>();

    return Container(
      height: 36,
      color: browserTheme?.tabBarColor ?? theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              itemCount: session.tabs.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                ref
                    .read(browserSessionProvider.notifier)
                    .reorderTabs(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final tab = session.tabs[index];
                final isActive = tab.id == session.activeTabId;

                return ReorderableDragStartListener(
                  key: ValueKey(tab.id),
                  index: index,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(browserSessionProvider.notifier)
                        .setActiveTab(tab.id),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 200,
                        minWidth: 100,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? browserTheme?.activeTabColor
                            : browserTheme?.inactiveTabColor,
                        border: Border(
                          bottom: BorderSide(
                            color: isActive
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (tab.isLoading)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            )
                          else if (tab.isIncognito)
                            const Icon(Icons.visibility_off, size: 14)
                          else
                            const Icon(Icons.language, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tab.title.truncate(20),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    isActive ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => ref
                                .read(browserSessionProvider.notifier)
                                .closeTab(tab.id),
                            child: const Icon(Icons.close, size: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // New tab button
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () =>
                ref.read(browserSessionProvider.notifier).addTab(),
            tooltip: 'New Tab',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
