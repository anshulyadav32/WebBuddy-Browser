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
    this.onSettingsTapped,
    this.onPageActionsTapped,
  });

  final int tabCount;
  final bool isPrivateMode;
  final VoidCallback? onTabsTapped;
  final VoidCallback? onSettingsTapped;
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
        child: IconButtonTheme(
          data: IconButtonThemeData(
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(34, 34),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: state.canGoBack ? () => controller.goBack() : null,
                tooltip: 'Back',
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, size: 20),
                onPressed: state.canGoForward
                    ? () => controller.goForward()
                    : null,
                tooltip: 'Forward',
              ),
              const SizedBox(width: 4),
              if (widget.isPrivateMode)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(Icons.shield, size: 18, color: cs.tertiary),
                ),
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
                      icon: Icon(
                        state.isLoading ? Icons.close : Icons.refresh,
                        size: 18,
                      ),
                      tooltip: state.isLoading ? 'Stop' : 'Reload',
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
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                tooltip: 'Page actions',
                onPressed: widget.onPageActionsTapped,
              ),
              IconButton(
                icon: const Icon(Icons.settings, size: 20),
                tooltip: 'Settings',
                onPressed: widget.onSettingsTapped,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
