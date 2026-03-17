import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../browser/presentation/widgets/browser_empty_view.dart';
import '../application/tabs_controller.dart';
import 'widgets/tab_card.dart';

/// Displays a grid of open tabs with controls to add, switch, and close.
class TabSwitcherScreen extends ConsumerWidget {
  const TabSwitcherScreen({super.key});

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
          Semantics(
            label: 'New private tab',
            child: IconButton(
              icon: const Icon(Icons.shield_outlined),
              tooltip: 'New private tab',
              onPressed: () {
                controller.createNewTab(isPrivate: true);
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
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
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.4,
              ),
              itemCount: tabsState.tabs.length,
              itemBuilder: (context, index) {
                final tab = tabsState.tabs[index];
                return TabCard(
                  tab: tab,
                  isActive: tab.id == tabsState.activeTabId,
                  onTap: () {
                    controller.switchTab(tab.id);
                    Navigator.of(context).pop();
                  },
                  onClose: () => controller.closeTab(tab.id),
                );
              },
            ),
    );
  }
}
