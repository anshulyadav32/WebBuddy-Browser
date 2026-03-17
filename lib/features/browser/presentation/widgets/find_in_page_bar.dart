import 'package:flutter/material.dart';

/// A find-in-page toolbar that slides in below the browser toolbar.
///
/// **Platform limitations**: Find-in-page uses `window.find()` via
/// JavaScript, which is a non-standard API. It works reliably on
/// macOS/iOS WKWebView and desktop Chromium WebViews. Android WebView
/// support is inconsistent. This is a best-effort feature.
class FindInPageBar extends StatefulWidget {
  const FindInPageBar({
    super.key,
    required this.onSearch,
    required this.onClose,
    this.onClear,
  });

  /// Called with the search query each time the user submits or taps next.
  final ValueChanged<String> onSearch;

  /// Called when the bar is dismissed.
  final VoidCallback onClose;

  /// Called when the query is cleared.
  final VoidCallback? onClear;

  @override
  State<FindInPageBar> createState() => _FindInPageBarState();
}

class _FindInPageBarState extends State<FindInPageBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    // Auto-focus when the bar appears.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmitted(String query) {
    if (query.isNotEmpty) {
      widget.onSearch(query);
    }
  }

  void _onNext() {
    if (_controller.text.isNotEmpty) {
      widget.onSearch(_controller.text);
    }
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: 'Find in page',
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Find in page',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          tooltip: 'Clear',
                          onPressed: _onClear,
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onSubmitted: _onSubmitted,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            tooltip: 'Find next',
            onPressed: _controller.text.isNotEmpty ? _onNext : null,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Close find bar',
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }
}
