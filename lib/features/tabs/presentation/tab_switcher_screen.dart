import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/tabs_controller.dart';
import 'widgets/tab_card.dart';

/// Displays a grid of open tabs with controls to add, switch, and close.
class TabSwitcherScreen extends ConsumerWidget {
  const TabSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsState = ref.watch(tabsControllerProvider);
    final controller = ref.read(tabsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New tab',
            onPressed: () {
              controller.createNewTab();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: GridView.builder(
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
