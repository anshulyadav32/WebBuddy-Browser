import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../browser/presentation/widgets/browser_progress_bar.dart';
import '../../browser/presentation/widgets/browser_toolbar.dart';
import '../../browser/presentation/widgets/browser_webview.dart';
import '../../downloads/presentation/downloads_screen.dart';
import '../../tabs/application/tabs_controller.dart';
import '../../tabs/presentation/tab_switcher_screen.dart';

/// Main browser screen with toolbar, progress bar, and webview.
class BrowserHomeScreen extends ConsumerWidget {
  const BrowserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsState = ref.watch(tabsControllerProvider);

    return Scaffold(
      body: Column(
        children: [
          BrowserToolbar(
            tabCount: tabsState.tabs.length,
            onTabsTapped: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TabSwitcherScreen(),
                ),
              );
            },
            onDownloadsTapped: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DownloadsScreen(),
                ),
              );
            },
          ),
          const BrowserProgressBar(),
          const Expanded(child: BrowserWebView()),
        ],
      ),
    );
  }
}
