import 'package:web_buddy/features/browser/presentation/browser_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/features/tabs/domain/models/browser_tab_state.dart';

import '../../browser/presentation/widgets/browser_empty_view.dart';
import '../application/tabs_controller.dart';
import 'widgets/tab_card.dart';

/// Displays a grid of open tabs with controls to add, switch, and close.
class TabSwitcherScreen extends ConsumerWidget {
  const TabSwitcherScreen({super.key});

  Future<void> _showCreateGroupDialog(
    BuildContext context,
    TabsController controller,
    String tabId,
  ) async {
    final nameController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create tab group'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Group name',
            hintText: 'Work, Research, Shopping...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              controller.groupTabByName(tabId, nameController.text);
              Navigator.of(ctx).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabGrid(
    BuildContext context,
    WidgetRef ref,
    TabsController controller,
    TabsState tabsState,
    List<BrowserTabState> tabs,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: tabs.length,
      itemBuilder: (context, index) {
        final tab = tabs[index];
        final groupLabel = tab.groupId == null
            ? null
            : tabsState.groupNames[tab.groupId!];
        return TabCard(
          tab: tab,
          groupLabel: groupLabel,
          isActive: tab.id == tabsState.activeTabId,
          onTap: () {
            controller.switchTab(tab.id);
            Navigator.of(context).pop();
          },
          onClose: () => controller.closeTab(tab.id),
          onOpenInPrivate: () {
            controller.createNewTab(isPrivate: true);
            ref
                .read(browserControllerProvider.notifier)
                .loadInput(tab.currentUrl);
          },
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsState = ref.watch(tabsControllerProvider);
    final controller = ref.read(tabsControllerProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    final regularCount = tabsState.tabs.where((t) => !t.isPrivate).length;
    final privateCount = tabsState.privateTabCount;

    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Tabs'),
              TextSpan(
                text: '  $regularCount',
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.normal,
                ),
              ),
              if (privateCount > 0)
                TextSpan(
                  text: '  ·  $privateCount private',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.tertiary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          if (!tabsState.activeTab.isPrivate)
            Semantics(
              label: 'Create tab group from active tab',
              child: IconButton(
                icon: const Icon(Icons.folder_copy_outlined),
                tooltip: 'Group active tab',
                onPressed: () => _showCreateGroupDialog(
                  context,
                  controller,
                  tabsState.activeTab.id,
                ),
              ),
            ),
          Semantics(
            label: 'New private tab',
            child: IconButton(
              icon: const Icon(Icons.shield_outlined),
              tooltip: 'New private tab',
              onPressed: () {
                controller.createNewTab(isPrivate: true);
                Future.microtask(() => Navigator.of(context).pop());
              },
            ),
          ),
          Semantics(
            label: 'New tab',
            child: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'New tab',
              onPressed: () {
                controller.createNewTab();
                Future.microtask(() => Navigator.of(context).pop());
              },
            ),
          ),
        ],
      ),
      body: tabsState.tabs.isEmpty
          ? const BrowserEmptyView(
              icon: Icons.tab_outlined,
              title: 'No tabs',
              subtitle: 'Open a new tab to start browsing.',
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tabsState.groupedTabs.isNotEmpty)
                    ...tabsState.groupedTabs.entries.expand((entry) {
                      final name = tabsState.groupNames[entry.key] ?? 'Group';
                      return [
                        _sectionTitle(context, 'Group: $name'),
                        _buildTabGrid(
                          context,
                          ref,
                          controller,
                          tabsState,
                          entry.value,
                        ),
                      ];
                    }),
                  if (tabsState.ungroupedRegularTabs.isNotEmpty) ...[
                    _sectionTitle(context, 'Ungrouped tabs'),
                    _buildTabGrid(
                      context,
                      ref,
                      controller,
                      tabsState,
                      tabsState.ungroupedRegularTabs,
                    ),
                  ],
                  if (tabsState.privateTabs.isNotEmpty) ...[
                    _sectionTitle(context, 'Private tabs'),
                    _buildTabGrid(
                      context,
                      ref,
                      controller,
                      tabsState,
                      tabsState.privateTabs,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
