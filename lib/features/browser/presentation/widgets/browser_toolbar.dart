import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/core/theme/app_theme.dart';
import 'package:web_buddy/features/browser/presentation/widgets/shields_badge.dart';
import 'package:web_buddy/features/search/presentation/providers/search_provider.dart';
import 'package:web_buddy/features/settings/presentation/providers/settings_provider.dart';
import 'package:web_buddy/features/tabs/presentation/providers/tab_provider.dart';

/// Navigation action provider — toolbar writes, WebViewContainer reads.
final navigationActionProvider =
    StateProvider.family<String?, String>((ref, tabId) => null);

/// Browser toolbar with address bar, navigation controls, and menu.
class BrowserToolbar extends ConsumerStatefulWidget {
  const BrowserToolbar({super.key});

  @override
  ConsumerState<BrowserToolbar> createState() => _BrowserToolbarState();
}

class _BrowserToolbarState extends ConsumerState<BrowserToolbar> {
  late TextEditingController _urlController;
  late FocusNode _urlFocusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _urlFocusNode = FocusNode();
    _urlFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _urlFocusNode.removeListener(_onFocusChange);
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isEditing = _urlFocusNode.hasFocus;
    });
    if (_urlFocusNode.hasFocus) {
      _urlController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _urlController.text.length,
      );
    }
  }

  void _onSubmitted(String value) {
    _urlFocusNode.unfocus();
    final settings = ref.read(settingsProvider);
    final url = resolveOmniboxInput(value, settings.searchEngineId);
    final session = ref.read(browserSessionProvider);
    final activeTab = session.activeTab;
    if (activeTab != null) {
      ref.read(browserSessionProvider.notifier).updateTab(
        activeTab.id,
        (tab) => tab.copyWith(url: url, isLoading: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final browserTheme = theme.extension<BrowserThemeExtension>();
    final session = ref.watch(browserSessionProvider);
    final activeTab = session.activeTab;

    // Update URL bar text when active tab changes
    if (!_isEditing && activeTab != null) {
      final displayUrl =
          activeTab.url == 'about:blank' ? '' : activeTab.url;
      if (_urlController.text != displayUrl) {
        _urlController.text = displayUrl;
      }
    }

    return Container(
      color: browserTheme?.toolbarColor ?? theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Back button
          _NavButton(
            icon: Icons.arrow_back,
            enabled: activeTab?.canGoBack ?? false,
            onPressed: () {
              if (activeTab != null) {
                ref.read(navigationActionProvider(activeTab.id).notifier).state = 'back';
              }
            },
            tooltip: 'Back',
          ),

          // Forward button
          _NavButton(
            icon: Icons.arrow_forward,
            enabled: activeTab?.canGoForward ?? false,
            onPressed: () {
              if (activeTab != null) {
                ref.read(navigationActionProvider(activeTab.id).notifier).state = 'forward';
              }
            },
            tooltip: 'Forward',
          ),

          // Refresh / Stop
          _NavButton(
            icon: activeTab?.isLoading == true ? Icons.close : Icons.refresh,
            enabled: activeTab != null && !activeTab.isNewTab,
            onPressed: () {
              if (activeTab != null) {
                final action = activeTab.isLoading ? 'stop' : 'refresh';
                ref.read(navigationActionProvider(activeTab.id).notifier).state = action;
              }
            },
            tooltip: activeTab?.isLoading == true ? 'Stop' : 'Refresh',
          ),

          const SizedBox(width: 4),

          // Address bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: browserTheme?.addressBarColor ??
                    theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // Security indicator
                  if (!_isEditing && activeTab != null && !activeTab.isNewTab)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Icon(
                        activeTab.url.startsWith('https')
                            ? Icons.lock
                            : Icons.lock_open,
                        size: 16,
                        color: activeTab.url.startsWith('https')
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),

                  // URL input
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      focusNode: _urlFocusNode,
                      style: theme.textTheme.bodyMedium,
                      textInputAction: TextInputAction.go,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: const InputDecoration(
                        hintText: 'Search or enter URL',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                      ),
                      onSubmitted: _onSubmitted,
                      onChanged: (value) {
                        ref.read(omniboxQueryProvider.notifier).state = value;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Shields badge
          if (activeTab != null && !activeTab.isNewTab)
            ShieldsBadge(tabId: activeTab.id),

          // Tab count / switcher button
          _TabCountButton(count: session.tabCount),

          // Menu button
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) => _handleMenuSelection(value, context),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'new_tab', child: Text('New Tab')),
              const PopupMenuItem(
                  value: 'incognito', child: Text('New Incognito Tab')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                  value: 'bookmarks', child: Text('Bookmarks')),
              const PopupMenuItem(value: 'history', child: Text('History')),
              const PopupMenuItem(
                  value: 'downloads', child: Text('Downloads')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                  value: 'find', child: Text('Find in Page')),
              const PopupMenuItem(value: 'share', child: Text('Share')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                  value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'new_tab':
        ref.read(browserSessionProvider.notifier).addTab();
      case 'incognito':
        ref.read(incognitoSessionProvider.notifier).addTab();
        // TODO: Navigate to incognito browser view
      case 'bookmarks':
        Navigator.of(context).pushNamed('/bookmarks');
      case 'history':
        Navigator.of(context).pushNamed('/history');
      case 'downloads':
        Navigator.of(context).pushNamed('/downloads');
      case 'find':
        // TODO: Implement find-in-page overlay
        break;
      case 'share':
        // Handled by share_plus in a dedicated method
        break;
      case 'settings':
        Navigator.of(context).pushNamed('/settings');
    }
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onPressed;
  final String tooltip;

  const _NavButton({
    required this.icon,
    required this.enabled,
    this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: enabled ? onPressed : null,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      splashRadius: 18,
    );
  }
}

class _TabCountButton extends ConsumerWidget {
  final int count;

  const _TabCountButton({required this.count});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/tabs');
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          count > 99 ? ':D' : count.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
