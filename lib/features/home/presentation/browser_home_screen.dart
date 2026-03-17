import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../browser/presentation/browser_controller.dart';
import '../../browser/presentation/widgets/browser_error_view.dart';
import '../../browser/presentation/widgets/browser_progress_bar.dart';
import '../../browser/presentation/widgets/browser_toolbar.dart';
import '../../browser/presentation/widgets/browser_webview.dart';
import '../../browser/presentation/widgets/find_in_page_bar.dart';
import '../../browser/presentation/widgets/page_actions_sheet.dart';
import '../../downloads/presentation/downloads_screen.dart';
import '../../privacy/presentation/widgets/shields_panel.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../settings/presentation/site_info_sheet.dart';
import '../../tabs/application/tabs_controller.dart';
import '../../tabs/presentation/tab_switcher_screen.dart';

/// Main browser screen with toolbar, progress bar, and webview.
class BrowserHomeScreen extends ConsumerStatefulWidget {
  const BrowserHomeScreen({super.key});

  @override
  ConsumerState<BrowserHomeScreen> createState() => _BrowserHomeScreenState();
}

class _BrowserHomeScreenState extends ConsumerState<BrowserHomeScreen> {
  bool _showFindBar = false;

  void _toggleFindBar() {
    setState(() => _showFindBar = !_showFindBar);
    if (!_showFindBar) {
      ref.read(browserControllerProvider.notifier).clearFind();
    }
  }

  void _showPageActions() {
    final state = ref.read(browserControllerProvider);
    showModalBottomSheet(
      context: context,
      builder: (_) => PageActionsSheet(
        url: state.currentUrl,
        title: state.title,
        onFindInPage: _toggleFindBar,
        onReload: () => ref.read(browserControllerProvider.notifier).reload(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabsState = ref.watch(tabsControllerProvider);
    final browserState = ref.watch(browserControllerProvider);
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: padding.bottom),
          child: Column(
            children: [
              BrowserToolbar(
                tabCount: tabsState.tabs.length,
                isPrivateMode: tabsState.isActiveTabPrivate,
                onTabsTapped: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TabSwitcherScreen(),
                    ),
                  );
                },
                onDownloadsTapped: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DownloadsScreen()),
                  );
                },
                onSettingsTapped: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                onSiteInfoTapped: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) =>
                        SiteInfoSheet(currentUrl: browserState.currentUrl),
                  );
                },
                onShieldsTapped: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => ShieldsPanel(
                      onReload: () {
                        ref.read(browserControllerProvider.notifier).reload();
                      },
                    ),
                  );
                },
                onPageActionsTapped: _showPageActions,
              ),
              const BrowserProgressBar(),
              // Find-in-page bar
              if (_showFindBar)
                FindInPageBar(
                  onSearch: (query) {
                    ref
                        .read(browserControllerProvider.notifier)
                        .findInPage(query);
                  },
                  onClose: _toggleFindBar,
                  onClear: () {
                    ref.read(browserControllerProvider.notifier).clearFind();
                  },
                ),
              // Main content: error view or webview
              Expanded(
                child: browserState.hasError
                    ? BrowserErrorView(
                        url: browserState.currentUrl,
                        errorDescription: browserState.errorDescription,
                        errorCode: browserState.errorCode,
                        onRetry: () {
                          ref.read(browserControllerProvider.notifier).reload();
                        },
                      )
                    : const BrowserWebView(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
