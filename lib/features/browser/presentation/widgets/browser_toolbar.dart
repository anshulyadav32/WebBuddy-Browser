import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../browser_controller.dart';

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
  });

  final int tabCount;
  final bool isPrivateMode;
  final VoidCallback? onTabsTapped;
  final VoidCallback? onDownloadsTapped;
  final VoidCallback? onSettingsTapped;
  final VoidCallback? onSiteInfoTapped;

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

            // Downloads button
            IconButton(
              icon: const Icon(Icons.download, size: 20),
              tooltip: 'Downloads',
              onPressed: widget.onDownloadsTapped,
            ),

            // Site info button
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              tooltip: 'Site info',
              onPressed: widget.onSiteInfoTapped,
            ),

            // Settings button
            IconButton(
              icon: const Icon(Icons.settings, size: 20),
              tooltip: 'Settings',
              onPressed: widget.onSettingsTapped,
            ),
          ],
        ),
      ),
    );
  }
}
