
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
            // Reload / Stop
            IconButton(
              icon: Icon(
                state.isLoading ? Icons.close : Icons.refresh,
                size: 20,
              ),
              onPressed: () => state.isLoading
                  ? controller.stopLoading()
                  : controller.reload(),
              tooltip: state.isLoading ? 'Stop' : 'Reload',
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
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search or enter URL',
                  prefixIcon: Icon(
                    state.isLoading ? Icons.hourglass_top : Icons.search,
                    size: 18,
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

            // Trailing buttons in a Flexible, horizontally scrollable Row
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tabs button
                    GestureDetector(
                      onTap: widget.onTabsTapped,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: cs.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.tabCount}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Shields button
                    _ShieldsIconButton(onTap: widget.onShieldsTapped),



                    // Page actions + Site info + Settings + Downloads in 3-dots menu
                    PopupMenuButton<_ToolbarMenuAction>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      tooltip: 'More actions',
                      onSelected: (value) {
                        switch (value) {
                          case _ToolbarMenuAction.pageActions:
                            if (widget.onPageActionsTapped != null) widget.onPageActionsTapped!();
                            break;
                          case _ToolbarMenuAction.siteInfo:
                            if (widget.onSiteInfoTapped != null) widget.onSiteInfoTapped!();
                            break;
                          case _ToolbarMenuAction.settings:
                            if (widget.onSettingsTapped != null) widget.onSettingsTapped!();
                            break;
                          case _ToolbarMenuAction.downloads:
                            if (widget.onDownloadsTapped != null) widget.onDownloadsTapped!();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _ToolbarMenuAction.pageActions,
                          child: Row(
                            children: const [
                              Icon(Icons.more_vert, size: 18),
                              SizedBox(width: 8),
                              Text('Page actions'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: _ToolbarMenuAction.siteInfo,
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline, size: 18),
                              SizedBox(width: 8),
                              Text('Site info'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: _ToolbarMenuAction.settings,
                          child: Row(
                            children: const [
                              Icon(Icons.settings, size: 18),
                              SizedBox(width: 8),
                              Text('Settings'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: _ToolbarMenuAction.downloads,
                          child: Row(
                            children: const [
                              Icon(Icons.download, size: 18),
                              SizedBox(width: 8),
                              Text('Downloads'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
