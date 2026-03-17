import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../browser/presentation/browser_controller.dart';
import '../../browser/presentation/widgets/browser_error_view.dart';
import '../../browser/presentation/widgets/browser_progress_bar.dart';
import '../../browser/presentation/widgets/browser_toolbar.dart';
import '../../browser/presentation/widgets/browser_webview.dart';
import '../../browser/presentation/widgets/find_in_page_bar.dart';
import '../../browser/presentation/widgets/page_actions_sheet.dart';
import '../../downloads/presentation/downloads_screen.dart';
import '../../downloads/presentation/downloads_controller.dart';
import '../../history/presentation/history_screen.dart';
import '../../offline/presentation/offline_pages_controller.dart';
import '../../offline/presentation/offline_pages_screen.dart';
import '../../privacy/presentation/shields_controller.dart';
import '../../privacy/presentation/widgets/shields_panel.dart';
import '../../settings/presentation/settings_controller.dart';
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
        onSaveOffline: _savePageOffline,
        onShowSslInfo: _showSslInfo,
        onDeveloperConsole: _showDeveloperConsole,
        onInspectSiteData: _inspectSiteData,
        onInspectNetwork: _showNetworkInfo,
        onOpenOfflinePages: _openOfflinePages,
        onOpenDownloads: _openDownloads,
        onOpenSiteInfo: _openSiteInfo,
        onOpenShields: _openShieldsPanel,
        onOpenSettings: _openSettings,
        onSetDefaultHomePage: _setCurrentAsDefaultHomePage,
        onOpenHistory: _openHistory,
        longPressTargetUrl: state.lastLongPressUrl,
        longPressTargetType: state.lastLongPressType,
        onOpenLongPressTarget: state.lastLongPressUrl == null
            ? null
            : _openLongPressTarget,
        onDownloadLongPressTarget:
            (state.lastLongPressUrl == null ||
                state.lastLongPressType != 'image')
            ? null
            : _downloadLongPressTarget,
      ),
    );
  }

  Future<void> _savePageOffline() async {
    final browserState = ref.read(browserControllerProvider);
    final path = await ref
        .read(browserControllerProvider.notifier)
        .savePageForOffline();

    if (path != null) {
      await ref
          .read(offlinePagesControllerProvider.notifier)
          .addSavedPage(
            url: browserState.currentUrl,
            title: browserState.title,
            filePath: path,
          );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          path == null
              ? 'Could not save page for offline use.'
              : 'Saved offline page at $path',
        ),
      ),
    );
  }

  void _openOfflinePages() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OfflinePagesScreen()));
  }

  void _openDownloads() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DownloadsScreen()));
  }

  void _openSiteInfo() {
    final browserState = ref.read(browserControllerProvider);
    showModalBottomSheet(
      context: context,
      builder: (_) => SiteInfoSheet(currentUrl: browserState.currentUrl),
    );
  }

  void _openShieldsPanel() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ShieldsPanel(
        onReload: () {
          ref.read(browserControllerProvider.notifier).reload();
        },
      ),
    );
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  void _openHistory() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
  }

  Future<void> _setCurrentAsDefaultHomePage() async {
    final currentUrl = ref.read(browserControllerProvider).currentUrl;
    await ref.read(settingsControllerProvider.notifier).setHomePage(currentUrl);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Default home page set to $currentUrl')),
    );
  }

  void _showSslInfo() {
    final details = ref
        .read(browserControllerProvider.notifier)
        .getSslSummary();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              leading: Icon(Icons.verified_user_outlined),
              title: Text('Connection details'),
            ),
            ...details.entries.map(
              (entry) =>
                  ListTile(title: Text(entry.key), subtitle: Text(entry.value)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeveloperConsole() async {
    final scriptController = TextEditingController(text: "document.title");
    var output = '';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Developer console'),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: scriptController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'JavaScript',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (output.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(ctx).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      output,
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                final result = await ref
                    .read(browserControllerProvider.notifier)
                    .executeJavaScript(scriptController.text);
                setState(() => output = result);
              },
              child: const Text('Run'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _inspectSiteData() async {
    final details = await ref
        .read(browserControllerProvider.notifier)
        .inspectSiteData();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              leading: Icon(Icons.storage_rounded),
              title: Text('Cookies and storage'),
            ),
            ...details.entries.map(
              (entry) => ListTile(
                title: Text(entry.key),
                subtitle: SelectableText(entry.value),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: entry.value));
                  },
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Clear cookies and storage for current page'),
              onTap: () async {
                await ref
                    .read(browserControllerProvider.notifier)
                    .clearSiteData();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Site cookies/storage cleared (best-effort)',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNetworkInfo() {
    final shields = ref.read(shieldsControllerProvider);
    final state = ref.read(browserControllerProvider);
    final host = Uri.tryParse(state.currentUrl)?.host ?? 'Unknown';

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              leading: Icon(Icons.network_check),
              title: Text('Network insights'),
            ),
            ListTile(title: const Text('Host'), subtitle: Text(host)),
            ListTile(
              title: const Text('Total blocked requests'),
              subtitle: Text('${shields.stats.totalBlocked}'),
            ),
            ListTile(
              title: const Text('Blocked trackers'),
              subtitle: Text('${shields.stats.trackersBlocked}'),
            ),
            ListTile(
              title: const Text('Blocked ads'),
              subtitle: Text('${shields.stats.adsBlocked}'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLongPressTarget() async {
    final target = ref.read(browserControllerProvider).lastLongPressUrl;
    if (target == null || target.isEmpty) return;
    await ref.read(browserControllerProvider.notifier).loadInput(target);
  }

  Future<void> _downloadLongPressTarget() async {
    final target = ref.read(browserControllerProvider).lastLongPressUrl;
    if (target == null || target.isEmpty) return;
    await ref
        .read(downloadsControllerProvider.notifier)
        .enqueueDownload(target);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Download added to queue')));
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
