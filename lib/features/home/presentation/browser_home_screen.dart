import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../browser/presentation/browser_controller.dart';
import '../../browser/presentation/widgets/browser_progress_bar.dart';
import '../../browser/presentation/widgets/browser_toolbar.dart';
import '../../browser/presentation/widgets/browser_webview.dart';
import '../../downloads/presentation/downloads_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../settings/presentation/site_info_sheet.dart';
import '../../tabs/application/tabs_controller.dart';
import '../../tabs/presentation/tab_switcher_screen.dart';

/// Main browser screen with toolbar, progress bar, and webview.
class BrowserHomeScreen extends ConsumerWidget {
  const BrowserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsState = ref.watch(tabsControllerProvider);
    final browserState = ref.watch(browserControllerProvider);

    return Scaffold(
      body: Column(
        children: [
          BrowserToolbar(
            tabCount: tabsState.tabs.length,
            isPrivateMode: tabsState.isActiveTabPrivate,
            onTabsTapped: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TabSwitcherScreen()),
              );
            },
            onDownloadsTapped: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DownloadsScreen()),
              );
            },
            onSettingsTapped: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            onSiteInfoTapped: () {
              showModalBottomSheet(
                context: context,
                builder: (_) =>
                    SiteInfoSheet(currentUrl: browserState.currentUrl),
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
