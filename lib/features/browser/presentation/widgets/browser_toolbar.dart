import 'package:web_buddy/features/tabs/application/tabs_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../privacy/presentation/shields_controller.dart';
import '../browser_controller.dart';

/// Actions for the toolbar 3-dots menu
enum _ToolbarMenuAction {
  pageActions,
  siteInfo,
  settings,
  downloads,
  openInPrivateTab,
}

/// The address / omnibox toolbar with navigation controls.
class BrowserToolbar extends ConsumerStatefulWidget {
  const BrowserToolbar({
    super.key,
    this.tabCount = 1,
    this.isPrivateMode = false,
    this.onTabsTapped,
    this.onDownloadsTapped,
    this.onSettingsTapped,
    this.onSiteInfoTapped,
    this.onShieldsTapped,
    this.onPageActionsTapped,
  });

  final int tabCount;
  final bool isPrivateMode;
  final VoidCallback? onTabsTapped;
  final VoidCallback? onDownloadsTapped;
  final VoidCallback? onSettingsTapped;
  final VoidCallback? onSiteInfoTapped;
  final VoidCallback? onShieldsTapped;
  final VoidCallback? onPageActionsTapped;

  @override
  ConsumerState<BrowserToolbar> createState() => _BrowserToolbarState();
}

class _BrowserToolbarState extends ConsumerState<BrowserToolbar> {
  late final TextEditingController _urlController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmitted(String value) {
    _focusNode.unfocus();
    ref.read(browserControllerProvider.notifier).loadInput(value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(browserControllerProvider);
    final controller = ref.read(browserControllerProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    // Sync the text field only when the user isn't editing.
    if (!_focusNode.hasFocus) {
      final display = state.currentUrl;
      if (_urlController.text != display) {
        _urlController.text = display;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isPrivateMode ? cs.surface.withAlpha(230) : cs.surface,
        border: Border(
          bottom: BorderSide(
            color: widget.isPrivateMode
                ? cs.tertiary.withAlpha(100)
                : cs.outlineVariant,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: state.canGoBack ? () => controller.goBack() : null,
              tooltip: 'Back',
            ),
            // Forward
            IconButton(
              icon: const Icon(Icons.arrow_forward, size: 20),
              onPressed: state.canGoForward
                  ? () => controller.goForward()
                  : null,
              tooltip: 'Forward',
            ),
            const SizedBox(width: 4),

            // Private mode indicator
            if (widget.isPrivateMode)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.shield, size: 18, color: cs.tertiary),
              ),

            // Omnibox
            Expanded(
              child: TextField(
                controller: _urlController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.go,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableInteractiveSelection: true,
                autofillHints: const [AutofillHints.url],
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search or enter URL',
                  prefixIcon: Icon(
                    state.isLoading ? Icons.hourglass_top : Icons.search,
                    size: 18,
                  ),
                  suffixIcon: IconButton(
                    tooltip: state.isLoading ? 'Stop' : 'Reload',
                    icon: Icon(
                      state.isLoading ? Icons.close : Icons.refresh,
                      size: 18,
                    ),
                    onPressed: () => state.isLoading
                        ? controller.stopLoading()
                        : controller.reload(),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onSubmitted: _onSubmitted,
                onTap: () => _urlController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _urlController.text.length,
                ),
              ),
            ),
            const SizedBox(width: 4),
            _ShieldsIconButton(onTap: widget.onShieldsTapped),
            Semantics(
              label: 'Tabs',
              child: IconButton(
                tooltip: 'Tabs (${widget.tabCount})',
                onPressed: widget.onTabsTapped,
                icon: Container(
                  width: 24,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: cs.outline, width: 1.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.tabCount > 99 ? '99+' : '${widget.tabCount}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
            ),
            PopupMenuButton<_ToolbarMenuAction>(
              tooltip: 'More',
              onSelected: (action) {
                switch (action) {
                  case _ToolbarMenuAction.pageActions:
                    widget.onPageActionsTapped?.call();
                    break;
                  case _ToolbarMenuAction.siteInfo:
                    widget.onSiteInfoTapped?.call();
                    break;
                  case _ToolbarMenuAction.settings:
                    widget.onSettingsTapped?.call();
                    break;
                  case _ToolbarMenuAction.downloads:
                    widget.onDownloadsTapped?.call();
                    break;
                  case _ToolbarMenuAction.openInPrivateTab:
                    ref
                        .read(tabsControllerProvider.notifier)
                        .createNewTab(isPrivate: true, url: state.currentUrl);
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _ToolbarMenuAction.pageActions,
                  child: ListTile(
                    leading: Icon(Icons.menu_book_outlined),
                    title: Text('Page actions'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                PopupMenuItem(
                  value: _ToolbarMenuAction.siteInfo,
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Site info'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                PopupMenuItem(
                  value: _ToolbarMenuAction.openInPrivateTab,
                  child: ListTile(
                    leading: Icon(Icons.shield_outlined),
                    title: Text('Open in private tab'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: _ToolbarMenuAction.downloads,
                  child: ListTile(
                    leading: Icon(Icons.download_outlined),
                    title: Text('Downloads'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                PopupMenuItem(
                  value: _ToolbarMenuAction.settings,
                  child: ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Settings'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small shield icon that shows blocked-count badge.
class _ShieldsIconButton extends ConsumerWidget {
  const _ShieldsIconButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shieldsState = ref.watch(shieldsControllerProvider);
    final cs = Theme.of(context).colorScheme;
    final count = shieldsState.stats.totalBlocked;

    return IconButton(
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(fontSize: 9),
        ),
        child: Icon(
          shieldsState.isEffectivelyEnabled
              ? Icons.shield
              : Icons.shield_outlined,
          size: 20,
          color: shieldsState.isEffectivelyEnabled ? cs.primary : cs.outline,
        ),
      ),
      tooltip: 'Shields',
      onPressed: onTap,
    );
  }
}
