import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/core/extensions/string_extensions.dart';
import 'package:web_buddy/features/tabs/presentation/providers/tab_provider.dart';

/// Grid-based tab switcher similar to mobile browser tab views.
class TabSwitcherPage extends ConsumerWidget {
  const TabSwitcherPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(browserSessionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${session.tabCount} Tabs'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ref.read(browserSessionProvider.notifier).addTab();
              Navigator.of(context).pop();
            },
            tooltip: 'New Tab',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'close_all':
                  ref.read(browserSessionProvider.notifier).closeAllTabs();
                  Navigator.of(context).pop();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'close_all', child: Text('Close All Tabs')),
            ],
          ),
        ],
      ),
      body: session.tabs.isEmpty
          ? Center(
              child: Text(
                'No tabs open',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: session.tabs.length,
              itemBuilder: (context, index) {
                final tab = session.tabs[index];
                final isActive = tab.id == session.activeTabId;

                return GestureDetector(
                  onTap: () {
                    ref
                        .read(browserSessionProvider.notifier)
                        .setActiveTab(tab.id);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: isActive ? 2 : 1,
                      ),
                      color: theme.cardTheme.color ?? theme.cardColor,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tab header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          color: isActive
                              ? theme.colorScheme.primaryContainer
                              : null,
                          child: Row(
                            children: [
                              if (tab.isIncognito)
                                const Icon(Icons.visibility_off, size: 14)
                              else
                                const Icon(Icons.language, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  tab.title.truncate(20),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  ref
                                      .read(browserSessionProvider.notifier)
                                      .closeTab(tab.id);
                                },
                                child: const Icon(Icons.close, size: 16),
                              ),
                            ],
                          ),
                        ),
                        // Tab preview area
                        Expanded(
                          child: Container(
                            color: theme.scaffoldBackgroundColor,
                            child: Center(
                              child: tab.isNewTab
                                  ? Icon(
                                      Icons.language,
                                      size: 32,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.2),
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.web,
                                          size: 32,
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Text(
                                            Uri.tryParse(tab.url)?.host ??
                                                tab.url,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: theme
                                                  .colorScheme.onSurface
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
