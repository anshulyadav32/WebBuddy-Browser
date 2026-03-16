import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../browser_controller.dart';

/// A thin loading progress bar shown beneath the toolbar.
class BrowserProgressBar extends ConsumerWidget {
  const BrowserProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(browserControllerProvider);

    if (!state.isLoading) return const SizedBox.shrink();

    return LinearProgressIndicator(
      value: state.progress > 0 ? state.progress : null,
      minHeight: 2.5,
      backgroundColor: Colors.transparent,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
